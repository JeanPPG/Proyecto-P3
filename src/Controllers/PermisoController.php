<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\PermisoRepository;
use App\Entities\Permiso;

class PermisoController
{
    private PermisoRepository $repo;

    public function __construct()
    {
        $this->repo = new PermisoRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json; charset=utf-8');
        $method = $_SERVER['REQUEST_METHOD'];

        try {
            switch ($method) {
                case 'GET': {
                    if (isset($_GET['id'])) {
                        $id = (int)$_GET['id'];
                        $perm = $this->repo->findById($id);
                        if (!$perm) {
                            http_response_code(404);
                            echo json_encode(['error' => 'Permiso no encontrado']);
                            return;
                        }
                        echo json_encode($this->toArray($perm));
                        return;
                    }
                    $list = array_map(fn(Permiso $p) => $this->toArray($p), $this->repo->findAll());
                    echo json_encode($list);
                    return;
                }

                case 'POST': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $codigo = trim((string)($payload['codigo'] ?? ''));

                    if ($codigo === '') {
                        http_response_code(400);
                        echo json_encode(['error' => 'codigo es requerido']);
                        return;
                    }

                    $entity = new Permiso(0, $codigo);
                    $ok = $this->repo->create($entity);
                    echo json_encode(['success' => (bool)$ok]);
                    return;
                }

                case 'PUT': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $id = (int)($payload['id'] ?? 0);
                    $codigo = isset($payload['codigo']) ? trim((string)$payload['codigo']) : '';

                    if ($id <= 0) {
                        http_response_code(400);
                        echo json_encode(['error' => 'id es requerido']);
                        return;
                    }
                    $existing = $this->repo->findById($id);
                    if (!$existing) {
                        http_response_code(404);
                        echo json_encode(['error' => 'Permiso no encontrado']);
                        return;
                    }
                    if ($codigo === '') {
                        http_response_code(400);
                        echo json_encode(['error' => 'codigo es requerido']);
                        return;
                    }

                    $existing->setCodigo($codigo);
                    $ok = $this->repo->update($existing);
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

    private function toArray(Permiso $p): array
    {
        return [
            'id'     => $p->getId(),
            'codigo' => $p->getCodigo(),
        ];
    }
}
