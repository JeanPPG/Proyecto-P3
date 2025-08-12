<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Rol;
use PDO;
use PDOException;

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
            (int)$row['id'],
            (string)$row['nombre']
        );
    }

    public function findAll(): array
    {
        try {
            $stmt = $this->db->query('CALL sp_rol_list()');
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $items = [];
            foreach ($rows as $r) {
                $items[] = $this->hydrate($r);
            }
            return $items;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar roles: '.$e->getMessage(), 0, $e);
        }
    }

    public function findById(int $id): ?object
    {
        try {
            $stmt = $this->db->prepare('CALL sp_find_rol(?)');
            $stmt->execute([$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            if (!$row) {
                $stmt = $this->db->prepare('CALL sp_rol_find_by_id(?)');
                $stmt->execute([$id]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
            }

            return $row ? $this->hydrate($row) : null;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al buscar rol: '.$e->getMessage(), 0, $e);
        }
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Rol) {
            throw new \InvalidArgumentException('Expected instance of Rol');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_create_rol(?)');
            $ok = $stmt->execute([$entity->getNombre()]);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al crear rol: '.$e->getMessage(), 0, $e);
        }
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Rol) {
            throw new \InvalidArgumentException('Expected instance of Rol');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_update_rol(?, ?)');
            $ok = $stmt->execute([$entity->getId(), $entity->getNombre()]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al actualizar rol: '.$e->getMessage(), 0, $e);
        }
    }

    public function delete(int $id): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_delete_rol(?)');
            $ok = $stmt->execute([$id]);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al eliminar rol: '.$e->getMessage(), 0, $e);
        }
    }
}
