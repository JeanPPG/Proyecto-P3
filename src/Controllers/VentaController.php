<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\VentaRepository;
use App\Entities\Venta;

class VentaController
{
    private VentaRepository $repo;

    public function __construct()
    {
        $this->repo = new VentaRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json; charset=utf-8');
        $method = $_SERVER['REQUEST_METHOD'];

        try {
            switch ($method) {
                case 'GET': {
                    if (isset($_GET['id'])) {
                        $venta = $this->repo->findById((int)$_GET['id']);
                        if (!$venta) {
                            http_response_code(404);
                            echo json_encode(['error' => 'Venta no encontrada']);
                            return;
                        }
                        echo json_encode($this->toArray($venta));
                    } else {
                        $list = array_map(fn(Venta $v) => $this->toArray($v), $this->repo->findAll());
                        echo json_encode($list);
                    }
                    return;
                }

                case 'POST': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $idCliente = (int)($payload['idCliente'] ?? 0);
                    if ($idCliente <= 0) {
                        http_response_code(400);
                        echo json_encode(['error' => 'idCliente es requerido']);
                        return;
                    }

                    $venta = new Venta(
                        0,
                        null,                
                        $idCliente,
                        0.0,
                        'BORRADOR'
                    );

                    $result = $this->repo->create($venta);

                    if (is_int($result)) {
                        echo json_encode(['success' => true, 'venta_id' => $result]);
                    } else {
                        echo json_encode(['success' => (bool)$result]);
                    }
                    return;
                }

                case 'PUT': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $id = (int)($payload['id'] ?? 0);
                    if ($id <= 0) {
                        http_response_code(400);
                        echo json_encode(['error' => 'id es requerido']);
                        return;
                    }

                    $existing = $this->repo->findById($id);
                    if (!$existing) {
                        http_response_code(404);
                        echo json_encode(['error' => 'Venta no encontrada']);
                        return;
                    }

                    $updated = new Venta(
                        $id,
                        $existing->getFecha(),
                        (int)($payload['idCliente'] ?? $existing->getIdCliente()),
                        (float)($payload['total'] ?? $existing->getTotal()), 
                        (string)($payload['estado'] ?? $existing->getEstado())
                    );

                    $ok = $this->repo->update($updated);

                    echo json_encode(['success' => (bool)$ok]);
                    return;
                }

                case 'DELETE': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $id = (int)($payload['id'] ?? 0);
                    if ($id <= 0) {
                        http_response_code(400);
                        echo json_encode(['error' => 'id es requerido']);
                        return;
                    }
                    $ok = $this->repo->delete($id);
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

    private function toArray(Venta $v): array
    {
        return [
            'id'        => $v->getId(),
            'fecha'     => $v->getFecha()->format('Y-m-d H:i:s'),
            'idCliente' => $v->getIdCliente(),
            'total'     => $v->getTotal(),
            'estado'    => $v->getEstado(),
        ];
    }
}
