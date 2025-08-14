<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\RolRepository;
use App\Entities\Rol;

class RolController
{
    private RolRepository $repo;

    public function __construct()
    {
        $this->repo = new RolRepository();
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
                        $rol = $this->repo->findById($id);
                        if (!$rol) {
                            http_response_code(404);
                            echo json_encode(['error' => 'Rol no encontrado']);
                            return;
                        }
                        echo json_encode($this->toArray($rol));
                        return;
                    }
                    $list = array_map(fn(Rol $r) => $this->toArray($r), $this->repo->findAll());
                    echo json_encode($list);
                    return;
                }

                case 'POST': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $nombre = trim((string)($payload['nombre'] ?? ''));

                    if ($nombre === '') {
                        http_response_code(400);
                        echo json_encode(['error' => 'nombre es requerido']);
                        return;
                    }

                    $entity = new Rol(0, $nombre);
                    $ok = $this->repo->create($entity);
                    echo json_encode(['success' => (bool)$ok]);
                    return;
                }

                case 'PUT': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $id = (int)($payload['id'] ?? 0);
                    $nombre = isset($payload['nombre']) ? trim((string)$payload['nombre']) : '';

                    if ($id <= 0) {
                        http_response_code(400);
                        echo json_encode(['error' => 'id es requerido']);
                        return;
                    }
                    $existing = $this->repo->findById($id);
                    if (!$existing) {
                        http_response_code(404);
                        echo json_encode(['error' => 'Rol no encontrado']);
                        return;
                    }
                    if ($nombre === '') {
                        http_response_code(400);
                        echo json_encode(['error' => 'nombre es requerido']);
                        return;
                    }

                    $existing->setNombre($nombre);
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

    private function toArray(Rol $r): array
    {
        return [
            'id'     => $r->getId(),
            'nombre' => $r->getNombre(),
        ];
    }
}
