<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\ProductoDigitalRepository;
use App\Entities\ProductoDigital;

class ProductoDigitalController
{
    private ProductoDigitalRepository $repo;

    public function __construct()
    {
        $this->repo = new ProductoDigitalRepository();
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
                    $entity = new ProductoDigital(
                        0,
                        (string)($payload['nombre'] ?? ''),
                        (string)($payload['descripcion'] ?? ''),
                        (float)($payload['precioUnitario'] ?? 0),
                        (int)($payload['stock'] ?? 0),
                        (int)($payload['idCategoria'] ?? 0),
                        (string)($payload['urlDescarga'] ?? ''),
                        (string)($payload['licencia'] ?? '')
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
                        echo json_encode(['error' => 'Producto digital no encontrado']);
                        return;
                    }

                    $entity = new ProductoDigital(
                        $id,
                        (string)($payload['nombre'] ?? $existing->getNombre()),
                        (string)($payload['descripcion'] ?? $existing->getDescripcion()),
                        (float)($payload['precioUnitario'] ?? $existing->getPrecioUnitario()),
                        (int)($payload['stock'] ?? $existing->getStock()),
                        (int)($payload['idCategoria'] ?? $existing->getIdCategoria()),
                        (string)($payload['urlDescarga'] ?? $existing->getUrlDescarga()),
                        (string)($payload['licencia'] ?? $existing->getLicencia())
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

    private function toArray(ProductoDigital $p): array
    {
        return [
            'id'            => $p->getId(),
            'nombre'        => $p->getNombre(),
            'descripcion'   => $p->getDescripcion(),
            'precioUnitario'=> $p->getPrecioUnitario(),
            'stock'         => $p->getStock(),
            'idCategoria'   => $p->getIdCategoria(),
            'urlDescarga'   => $p->getUrlDescarga(),
            'licencia'      => $p->getLicencia(),
        ];
    }
}
