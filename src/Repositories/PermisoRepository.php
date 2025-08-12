<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Permiso;
use PDO;
use PDOException;

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
            (int)$row['id'],
            (string)$row['codigo']
        );
    }

    public function findAll(): array
    {
        try {
            $stmt = $this->db->query('CALL sp_permiso_list()');
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $items = [];
            foreach ($rows as $r) {
                $items[] = $this->hydrate($r);
            }
            return $items;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar permisos: '.$e->getMessage(), 0, $e);
        }
    }

    public function findById(int $id): ?object
    {
        try {
            $stmt = $this->db->prepare('CALL sp_find_permiso(?)');
            $stmt->execute([$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            if (!$row) {
                $stmt = $this->db->prepare('CALL sp_permiso_find_by_id(?)');
                $stmt->execute([$id]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
            }

            return $row ? $this->hydrate($row) : null;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al buscar permiso: '.$e->getMessage(), 0, $e);
        }
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Permiso) {
            throw new \InvalidArgumentException('Expected instance of Permiso');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_create_permiso(?)');
            $ok = $stmt->execute([$entity->getCodigo()]);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al crear permiso: '.$e->getMessage(), 0, $e);
        }
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Permiso) {
            throw new \InvalidArgumentException('Expected instance of Permiso');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_update_permiso(?, ?)');
            $ok = $stmt->execute([$entity->getId(), $entity->getCodigo()]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al actualizar permiso: '.$e->getMessage(), 0, $e);
        }
    }

    public function delete(int $id): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_delete_permiso(?)');
            $ok = $stmt->execute([$id]);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al eliminar permiso: '.$e->getMessage(), 0, $e);
        }
    }
}
