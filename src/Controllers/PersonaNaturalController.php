<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Repositories\PersonaNaturalRepository;
use App\Entities\PersonaNatural;

final class PersonaNaturalController
{
    private PersonaNaturalRepository $repo;

    public function __construct()
    {
        $this->repo = new PersonaNaturalRepository();
    }

    public function handle(): void
    {
        header('Content-Type: application/json; charset=utf-8');

        $method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

        if ($method === 'GET') {
            if (isset($_GET['id'])) {
                $item = $this->repo->findById((int)$_GET['id']);
                echo json_encode($item ? $this->personaToArray($item) : null, JSON_UNESCAPED_UNICODE);
            } else {
                $list = array_map([$this, 'personaToArray'], $this->repo->findAll());
                echo json_encode($list, JSON_UNESCAPED_UNICODE);
            }
            return;
        }

        $payload = $this->readJson();

        if ($method === 'POST') {
            foreach (['email','telefono','direccion','nombres','apellidos','cedula'] as $f) {
                if (!isset($payload[$f]) || (is_string($payload[$f]) && trim($payload[$f])==='')) {
                    http_response_code(400);
                    echo json_encode(['error' => "Campo requerido: $f"]);
                    return;
                }
            }

            $entity = new PersonaNatural(
                0,
                (string)$payload['email'],
                (string)$payload['telefono'],
                (string)$payload['direccion'],
                'NATURAL',
                (string)$payload['nombres'],
                (string)$payload['apellidos'],
                (string)$payload['cedula']
            );

            $ok = $this->repo->create($entity);
            echo json_encode(['success' => (bool)$ok], JSON_UNESCAPED_UNICODE);
            return;
        }

        if ($method === 'PUT') {
            $id = (int)($payload['id'] ?? 0);
            if ($id <= 0) {
                http_response_code(400);
                echo json_encode(['error' => 'Falta id']);
                return;
            }

            $existing = $this->repo->findById($id);
            if (!$existing) {
                http_response_code(404);
                echo json_encode(['error' => 'Persona natural no encontrada']);
                return;
            }

            if (isset($payload['email']))     { $existing->setEmail((string)$payload['email']); }
            if (isset($payload['telefono']))  { $existing->setTelefono((string)$payload['telefono']); }
            if (isset($payload['direccion'])) { $existing->setDireccion((string)$payload['direccion']); }
            if (isset($payload['nombres']))   { $existing->setNombres((string)$payload['nombres']); }
            if (isset($payload['apellidos'])) { $existing->setApellidos((string)$payload['apellidos']); }
            if (isset($payload['cedula']))    { $existing->setCedula((string)$payload['cedula']); }

            $ok = $this->repo->update($existing);
            echo json_encode(['success' => (bool)$ok], JSON_UNESCAPED_UNICODE);
            return;
        }

        if ($method === 'DELETE') {
            $id = (int)($payload['id'] ?? 0);
            if ($id <= 0) {
                http_response_code(400);
                echo json_encode(['error' => 'Falta id']);
                return;
            }
            $ok = $this->repo->delete($id);
            echo json_encode(['success' => (bool)$ok], JSON_UNESCAPED_UNICODE);
            return;
        }

        http_response_code(405);
        echo json_encode(['error' => 'Método no permitido']);
    }

    /* ---------------- helpers ---------------- */

    private function readJson(): array
    {
        $raw = file_get_contents('php://input') ?: '';
        $data = json_decode($raw, true);
        return is_array($data) ? $data : [];
    }

    private function personaToArray(PersonaNatural $p): array
    {
        return [
            'id'        => $p->getId(),
            'email'     => $p->getEmail(),
            'telefono'  => $p->getTelefono(),
            'direccion' => $p->getDireccion(),
            'tipo'      => 'NATURAL',
            'nombres'   => $p->getNombres(),
            'apellidos' => $p->getApellidos(),
            'cedula'    => $p->getCedula(),
        ];
    }
}
