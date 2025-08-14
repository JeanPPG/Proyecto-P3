<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\ProductoFisicoRepository;
use App\Entities\ProductoFisico;

class ProductoFisicoController
{
    private ProductoFisicoRepository $repo;

    public function __construct()
    {
        $this->repo = new ProductoFisicoRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json; charset=utf-8');
        $method = $_SERVER['REQUEST_METHOD'];

        try {
            switch ($method) {
                case 'GET':
                    if (isset($_GET['id'])) {
                        $item = $this->repo->findById((int)$_GET['id']);
                        echo json_encode($item ? $this->toArray($item) : null);
                    } else {
                        $list = array_map(fn($e) => $this->toArray($e), $this->repo->findAll());
                        echo json_encode($list);
                    }
                    return;

                case 'POST': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $entity = new ProductoFisico(
                        0,
                        (string)($payload['nombre'] ?? ''),
                        (string)($payload['descripcion'] ?? ''),
                        (float)($payload['precioUnitario'] ?? 0),
                        (int)($payload['stock'] ?? 0),
                        (int)($payload['idCategoria'] ?? 0),
                        isset($payload['peso']) ? (float)$payload['peso'] : null,
                        isset($payload['alto']) ? (float)$payload['alto'] : null,
                        isset($payload['ancho']) ? (float)$payload['ancho'] : null,
                        isset($payload['profundidad']) ? (float)$payload['profundidad'] : null,
                    );

                    $ok = $this->repo->create($entity);
                    echo json_encode(['success' => $ok]);
                    return;
                }

                case 'PUT': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $id = (int)($payload['id'] ?? 0);
                    $existing = $this->repo->findById($id);
                    if (!$existing) {
                        http_response_code(404);
                        echo json_encode(['error' => 'Producto físico no encontrado']);
                        return;
                    }

                    $entity = new ProductoFisico(
                        $id,
                        (string)($payload['nombre'] ?? $existing->getNombre()),
                        (string)($payload['descripcion'] ?? $existing->getDescripcion()),
                        (float)($payload['precioUnitario'] ?? $existing->getPrecioUnitario()),
                        (int)($payload['stock'] ?? $existing->getStock()),
                        (int)($payload['idCategoria'] ?? $existing->getIdCategoria()),
                        array_key_exists('peso', $payload) ? (float)$payload['peso'] : $existing->getPeso(),
                        array_key_exists('alto', $payload) ? (float)$payload['alto'] : $existing->getAlto(),
                        array_key_exists('ancho', $payload) ? (float)$payload['ancho'] : $existing->getAncho(),
                        array_key_exists('profundidad', $payload) ? (float)$payload['profundidad'] : $existing->getProfundidad(),
                    );

                    $ok = $this->repo->update($entity);
                    echo json_encode(['success' => $ok]);
                    return;
                }

                case 'DELETE': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $id = (int)($payload['id'] ?? 0);
                    $ok = $this->repo->delete($id);
                    echo json_encode(['success' => $ok]);
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

    private function toArray(ProductoFisico $p): array
    {
        return [
            'id'            => $p->getId(),
            'nombre'        => $p->getNombre(),
            'descripcion'   => $p->getDescripcion(),
            'precioUnitario'=> $p->getPrecioUnitario(),
            'stock'         => $p->getStock(),
            'idCategoria'   => $p->getIdCategoria(),
            'peso'          => $p->getPeso(),
            'alto'          => $p->getAlto(),
            'ancho'         => $p->getAncho(),
            'profundidad'   => $p->getProfundidad(),
        ];
    }
}
