<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Permiso;
use PDO;

class PermisoRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): Permiso
    {
        return new Permiso(
            (int)$row['id_permiso'],
            $row['nombre'],
            $row['descripcion']
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_permiso_list();');
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $permisos = [];
        foreach ($rows as $r) {
            $permisos[] = $this->hydrate($r);
        }
        return $permisos;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Permiso) {
            throw new \InvalidArgumentException('Expected instance of Permiso');
        }

        $stmt = $this->db->prepare('CALL sp_create_permiso(:nombre, :descripcion);');
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
        if (!$entity instanceof Permiso) {
            throw new \InvalidArgumentException('Expected instance of Permiso');
        }

        $stmt = $this->db->prepare('CALL sp_update_permiso(:id_permiso, :nombre, :descripcion);');
        $ok = $stmt->execute([
            ':id_permiso' => $entity->getId(),
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
        $stmt = $this->db->prepare('CALL sp_delete_permiso(:id_permiso);');
        $ok = $stmt->execute([':id_permiso' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_permiso_find_by_id(:id_permiso);');
        $stmt->execute([':id_permiso' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
