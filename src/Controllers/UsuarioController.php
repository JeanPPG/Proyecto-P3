<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\UsuarioRepository;
use App\Entities\Usuario;

class UsuarioController
{
    private UsuarioRepository $repo;

    public function __construct()
    {
        $this->repo = new UsuarioRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json; charset=utf-8');
        $method = $_SERVER['REQUEST_METHOD'];

        try {
            switch ($method) {
                case 'GET': {
                    if (isset($_GET['id'])) {
                        $id  = (int)$_GET['id'];
                        $usr = $this->repo->findById($id);
                        if (!$usr) {
                            http_response_code(404);
                            echo json_encode(['error' => 'Usuario no encontrado']);
                            return;
                        }
                        echo json_encode($this->toArray($usr));
                        return;
                    }
                    $list = array_map(fn(Usuario $u) => $this->toArray($u), $this->repo->findAll());
                    echo json_encode($list);
                    return;
                }

                case 'POST': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];

                    $username = trim((string)($payload['username'] ?? ''));
                    $password = (string)($payload['password'] ?? '');
                    $estado   = (string)($payload['estado'] ?? 'ACTIVO');

                    if ($username === '' || $password === '') {
                        http_response_code(400);
                        echo json_encode(['error' => 'username y password son requeridos']);
                        return;
                    }
                    if (!in_array($estado, ['ACTIVO','INACTIVO','BLOQUEADO'], true)) {
                        http_response_code(400);
                        echo json_encode(['error' => 'estado inválido']);
                        return;
                    }

                    $hash = $this->hashPassword($password);

                    $entity = new Usuario(0, $username, $hash, $estado);
                    $ok = $this->repo->create($entity);

                    echo json_encode(['success' => (bool)$ok]);
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
                        echo json_encode(['error' => 'Usuario no encontrado']);
                        return;
                    }

                    if (isset($payload['username'])) {
                        $u = trim((string)$payload['username']);
                        if ($u === '') {
                            http_response_code(400);
                            echo json_encode(['error' => 'username no puede estar vacío']);
                            return;
                        }
                        $existing->setUsername($u);
                    }

                    if (isset($payload['estado'])) {
                        $estado = (string)$payload['estado'];
                        if (!in_array($estado, ['ACTIVO','INACTIVO','BLOQUEADO'], true)) {
                            http_response_code(400);
                            echo json_encode(['error' => 'estado inválido']);
                            return;
                        }
                        $existing->setEstado($estado);
                    }

                    $ok = $this->repo->update($existing);
                    echo json_encode(['success' => (bool)$ok]);
                    return;
                }

                case 'PATCH': {
                    $payload = json_decode(file_get_contents('php://input'), true) ?? [];
                    $id = (int)($payload['id'] ?? 0);
                    if ($id <= 0) {
                        http_response_code(400);
                        echo json_encode(['error' => 'id es requerido']);
                        return;
                    }

                    if (array_key_exists('password', $payload)) {
                        $pwd = (string)$payload['password'];
                        if ($pwd === '') {
                            http_response_code(400);
                            echo json_encode(['error' => 'password no puede estar vacío']);
                            return;
                        }
                        $hash = $this->hashPassword($pwd);
                        $ok = $this->repo->setPassword($id, $hash);
                        echo json_encode(['success' => (bool)$ok, 'changed' => 'password']);
                        return;
                    }

                    if (array_key_exists('estado', $payload)) {
                        $estado = (string)$payload['estado'];
                        if (!in_array($estado, ['ACTIVO','INACTIVO','BLOQUEADO'], true)) {
                            http_response_code(400);
                            echo json_encode(['error' => 'estado inválido']);
                            return;
                        }
                        $ok = $this->repo->setEstado($id, $estado);
                        echo json_encode(['success' => (bool)$ok, 'changed' => 'estado']);
                        return;
                    }

                    http_response_code(400);
                    echo json_encode(['error' => 'Nada que actualizar (provee password o estado)']);
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

    private function toArray(Usuario $u): array
    {
        return [
            'id'       => $u->getId(),
            'username' => $u->getUsername(),
            'estado'   => $u->getEstado(),
        ];
    }

    private function hashPassword(string $plain): string
    {
        if (defined('PASSWORD_ARGON2ID')) {
            $hash = password_hash($plain, PASSWORD_ARGON2ID);
        } else {
            $hash = password_hash($plain, PASSWORD_BCRYPT);
        }
        if ($hash === false) {
            throw new \RuntimeException('No se pudo hashear la contraseña');
        }
        return $hash;
    }
}
