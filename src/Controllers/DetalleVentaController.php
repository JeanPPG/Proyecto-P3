<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\DetalleVentaRepository;
use App\Entities\DetalleVenta;
use App\Config\Database;
use PDO;

class DetalleVentaController
{
    private DetalleVentaRepository $repo;

    public function __construct()
    {
        $this->repo = new DetalleVentaRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json; charset=utf-8');
        $method = $_SERVER['REQUEST_METHOD'];
        $action = $_GET['action'] ?? null;

        try {
            // ===== Acciones especiales =====
            if ($action === 'recalcular') {
                $idVenta = $method === 'GET'
                    ? (int)($_GET['idVenta'] ?? 0)
                    : (int)((json_decode(file_get_contents('php://input'), true) ?? [])['idVenta'] ?? 0);

                if ($idVenta <= 0) {
                    http_response_code(400);
                    echo json_encode(['error' => 'idVenta es requerido']);
                    return;
                }

                $pdo = Database::getConnection();
                $stmt = $pdo->prepare('CALL sp_venta_recalcular_total(:idVenta)');
                $stmt->execute([':idVenta' => $idVenta]);
                $venta = $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
                while ($stmt->nextRowset()) { /* consume extra sets */ }
                $stmt->closeCursor();

                echo json_encode([
                    'success' => (bool)$venta,
                    'venta'   => $venta ?: null
                ]);
                return;
            }

            // ===== CRUD =====
            switch ($method) {
                case 'GET': {
                    // Permite:
                    // 1) Global:          /api/detalle_venta.php
                    // 2) Por venta:       /api/detalle_venta.php?idVenta=1
                    // 3) Línea específica:/api/detalle_venta.php?idVenta=1&lineNumber=2
                    $idVenta = isset($_GET['idVenta']) ? (int)$_GET['idVenta'] : 0;

                    if ($idVenta <= 0) {
                        // Listado global
                        $all = array_map(
                            fn(DetalleVenta $d) => $this->toArray($d),
                            $this->repo->findAll()           // <-- importante: repo debe tener findAll()
                        );
                        echo json_encode($all);
                        return;
                    }

                    if (isset($_GET['lineNumber'])) {
                        $line = (int)$_GET['lineNumber'];
                        $item = $this->repo->findOne($idVenta, $line);
                        if (!$item) {
                            http_response_code(404);
                            echo json_encode(['error' => 'Detalle no encontrado']);
                            return;
                        }
                        echo json_encode($this->toArray($item));
                        return;
                    }

                    $list = array_map(
                        fn(DetalleVenta $d) => $this->toArray($d),
                        $this->repo->listByVenta($idVenta)
                    );
                    echo json_encode($list);
                    return;
                }

                case 'POST': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];

                    $idVenta       = (int)($payload['idVenta'] ?? 0);
                    $idProducto    = (int)($payload['idProducto'] ?? 0);
                    $cantidad      = (int)($payload['cantidad'] ?? 0);
                    $precioUnitario = array_key_exists('precioUnitario', $payload)
                        ? (float)$payload['precioUnitario']
                        : 0.0; // null/0 → que el SP tome precio de Producto si aplica

                    if ($idVenta <= 0 || $idProducto <= 0 || $cantidad <= 0) {
                        http_response_code(400);
                        echo json_encode(['error' => 'idVenta, idProducto y cantidad son requeridos y > 0']);
                        return;
                    }

                    $entity = new DetalleVenta($idVenta, 0, $idProducto, $cantidad, $precioUnitario);
                    $ok = $this->repo->add($entity);
                    echo json_encode(['success' => (bool)$ok]);
                    return;
                }

                case 'PUT': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $idVenta    = (int)($payload['idVenta'] ?? 0);
                    $lineNumber = (int)($payload['lineNumber'] ?? 0);

                    if ($idVenta <= 0 || $lineNumber <= 0) {
                        http_response_code(400);
                        echo json_encode(['error' => 'idVenta y lineNumber son requeridos']);
                        return;
                    }

                    $existing = $this->repo->findOne($idVenta, $lineNumber);
                    if (!$existing) {
                        http_response_code(404);
                        echo json_encode(['error' => 'Detalle no encontrado']);
                        return;
                    }

                    $idProducto     = (int)($payload['idProducto'] ?? $existing->getIdProducto());
                    $cantidad       = (int)($payload['cantidad'] ?? $existing->getCantidad());
                    $precioUnitario = array_key_exists('precioUnitario', $payload)
                        ? (float)$payload['precioUnitario']
                        : $existing->getPrecioUnitario();

                    $entity = new DetalleVenta($idVenta, $lineNumber, $idProducto, $cantidad, $precioUnitario);
                    $ok = $this->repo->update($entity);
                    echo json_encode(['success' => (bool)$ok]);
                    return;
                }

                case 'DELETE': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $idVenta    = (int)($payload['idVenta'] ?? 0);
                    $lineNumber = (int)($payload['lineNumber'] ?? 0);

                    if ($idVenta <= 0 || $lineNumber <= 0) {
                        http_response_code(400);
                        echo json_encode(['error' => 'idVenta y lineNumber son requeridos']);
                        return;
                    }

                    // Asegúrate que tu repo tenga delete(int $idVenta, int $lineNumber)
                    $ok = $this->repo->delete($idVenta, $lineNumber);
                    echo json_encode(['success' => (bool)$ok]);
                    return;
                }
            }

            http_response_code(405);
            echo json_encode(['error' => 'Método no permitido']);
        } catch (\Throwable $e) {
            http_response_code(400);
            echo json_encode(['error' => $e->getMessage()]);
        }
    }

    private function toArray(DetalleVenta $d): array
    {
        return [
            'idVenta'        => $d->getIdVenta(),
            'lineNumber'     => $d->getLineNumber(),
            'idProducto'     => $d->getIdProducto(),
            'cantidad'       => $d->getCantidad(),
            'precioUnitario' => $d->getPrecioUnitario(),
            'subtotal'       => $d->getSubtotal(),
        ];
    }
}
