<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\PersonaNatural;
use PDO;

class PersonaNaturalRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }


    private function hydrate(array $row): PersonaNatural
    {
        return new PersonaNatural(
            (int)$row['id_persona_natural'],
            $row['nombre'],
            $row['apellido'],
            $row['cedula'],
            $row['direccion'],
            $row['telefono'],
            $row['email']
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_persona_natural_list();');
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $listado = [];
        foreach ($rows as $r) {
            $listado[] = $this->hydrate($r);
        }
        return $listado;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof PersonaNatural) {
            throw new \InvalidArgumentException('Expected instance of PersonaNatural');
        }

        $stmt = $this->db->prepare('CALL sp_create_persona_natural(:nombre, :apellido, :cedula, :direccion, :telefono, :email);');
        $ok = $stmt->execute([
            ':nombre' => $entity->getNombre(),
            ':apellido' => $entity->getApellido(),
            ':cedula' => $entity->getCedula(),
            ':direccion' => $entity->getDireccion(),
            ':telefono' => $entity->getTelefono(),
            ':email' => $entity->getEmail()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof PersonaNatural) {
            throw new \InvalidArgumentException('Expected instance of PersonaNatural');
        }

        $stmt = $this->db->prepare('CALL sp_update_persona_natural(:id_persona_natural, :nombre, :apellido, :cedula, :direccion, :telefono, :email);');
        $ok = $stmt->execute([
            ':id_persona_natural' => $entity->getId(),
            ':nombre' => $entity->getNombre(),
            ':apellido' => $entity->getApellido(),
            ':cedula' => $entity->getCedula(),
            ':direccion' => $entity->getDireccion(),
            ':telefono' => $entity->getTelefono(),
            ':email' => $entity->getEmail()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_delete_persona_natural(:id_persona_natural);');
        $ok = $stmt->execute([':id_persona_natural' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_persona_natural_find_by_id(:id_persona_natural);');
        $stmt->execute([':id_persona_natural' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
