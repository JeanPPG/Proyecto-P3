<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Rol;
use PDO;

class RolRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): Rol
    {
        return new Rol(
            (int)$row['id_rol'],
            $row['nombre'],
            $row['descripcion']
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_rol_list();');
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $roles = [];
        foreach ($rows as $r) {
            $roles[] = $this->hydrate($r);
        }
        return $roles;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Rol) {
            throw new \InvalidArgumentException('Expected instance of Rol');
        }

        $stmt = $this->db->prepare('CALL sp_create_rol(:nombre, :descripcion);');
        $ok = $stmt->execute([
            ':nombre' => $entity->getNombre(),
            ':descripcion' => $entity->getDescripcion()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Rol) {
            throw new \InvalidArgumentException('Expected instance of Rol');
        }

        $stmt = $this->db->prepare('CALL sp_update_rol(:id_rol, :nombre, :descripcion);');
        $ok = $stmt->execute([
            ':id_rol' => $entity->getId(),
            ':nombre' => $entity->getNombre(),
            ':descripcion' => $entity->getDescripcion()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_delete_rol(:id_rol);');
        $ok = $stmt->execute([':id_rol' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_rol_find_by_id(:id_rol);');
        $stmt->execute([':id_rol' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
