<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\ProductoDigital;
use PDO;
use PDOException;

class ProductoDigitalRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): ProductoDigital
    {
        return new ProductoDigital(
            (int)$row['id'],
            (string)$row['nombre'],
            $row['descripcion'] ?? null,
            (float)$row['precioUnitario'],
            (int)$row['stock'],
            (int)$row['idCategoria'],
            (string)$row['urlDescarga'],
            $row['licencia'] ?? null
        );
    }

    public function findAll(): array
    {
        try {
            $stmt = $this->db->query('CALL sp_producto_digital_list()');
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $items = [];
            foreach ($rows as $r) {
                $items[] = $this->hydrate($r);
            }
            return $items;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar productos digitales: '.$e->getMessage(), 0, $e);
        }
    }

    public function findById(int $id): ?object
    {
        try {
            $stmt = $this->db->prepare('CALL sp_find_producto_digital(?)');
            $stmt->execute([$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            return $row ? $this->hydrate($row) : null;
        } catch (PDOException $e) {
            if (stripos($e->getMessage(), 'sp_find_producto_digital') !== false) {
                $stmt = $this->db->prepare('CALL sp_producto_digital_find_by_id(?)');
                $stmt->execute([$id]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
                return $row ? $this->hydrate($row) : null;
            }
            throw new \RuntimeException('Error al buscar producto digital: '.$e->getMessage(), 0, $e);
        }
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof ProductoDigital) {
            throw new \InvalidArgumentException('Expected instance of ProductoDigital');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_create_producto_digital(?,?,?,?,?,?,?)');
            $ok = $stmt->execute([
                $entity->getNombre(),
                $entity->getDescripcion(),
                $entity->getPrecioUnitario(),
                $entity->getStock(),
                $entity->getIdCategoria(),
                $entity->getUrlDescarga(),
                $entity->getLicencia()
            ]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al crear producto digital: '.$e->getMessage(), 0, $e);
        }
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof ProductoDigital) {
            throw new \InvalidArgumentException('Expected instance of ProductoDigital');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_update_producto_digital(?,?,?,?,?,?,?,?)');
            $ok = $stmt->execute([
                $entity->getId(),
                $entity->getNombre(),
                $entity->getDescripcion(),
                $entity->getPrecioUnitario(),
                $entity->getStock(),
                $entity->getIdCategoria(),
                $entity->getUrlDescarga(),
                $entity->getLicencia()
            ]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al actualizar producto digital: '.$e->getMessage(), 0, $e);
        }
    }

    public function delete(int $id): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_delete_producto_digital(?)');
            $ok = $stmt->execute([$id]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al eliminar producto digital: '.$e->getMessage(), 0, $e);
        }
    }
}
