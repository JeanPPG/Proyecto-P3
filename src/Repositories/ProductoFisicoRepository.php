<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\ProductoFisico;
use PDO;
use PDOException;

class ProductoFisicoRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): ProductoFisico
    {
        return new ProductoFisico(
            (int)$row['id'],
            (string)$row['nombre'],
            isset($row['descripcion']) ? (string)$row['descripcion'] : null,
            (float)$row['precioUnitario'],
            (int)$row['stock'],
            (int)$row['idCategoria'],
            isset($row['peso']) ? (float)$row['peso'] : null,
            isset($row['alto']) ? (float)$row['alto'] : null,
            isset($row['ancho']) ? (float)$row['ancho'] : null,
            isset($row['profundidad']) ? (float)$row['profundidad'] : null
        );
    }

    public function findAll(): array
    {
        try {
            $stmt = $this->db->query('CALL sp_producto_fisico_list()');
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $items = [];
            foreach ($rows as $r) {
                $items[] = $this->hydrate($r);
            }
            return $items;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar productos físicos: '.$e->getMessage(), 0, $e);
        }
    }

    public function findById(int $id): ?object
    {
        try {
            $stmt = $this->db->prepare('CALL sp_find_producto_fisico(?)');
            $stmt->execute([$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            return $row ? $this->hydrate($row) : null;
        } catch (PDOException $e) {
            if (stripos($e->getMessage(), 'sp_find_producto_fisico') !== false) {
                $stmt = $this->db->prepare('CALL sp_producto_fisico_find_by_id(?)');
                $stmt->execute([$id]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
                return $row ? $this->hydrate($row) : null;
            }
            throw new \RuntimeException('Error al buscar producto físico: '.$e->getMessage(), 0, $e);
        }
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof ProductoFisico) {
            throw new \InvalidArgumentException('Expected instance of ProductoFisico');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_create_producto_fisico(?,?,?,?,?,?,?,?,?)');
            $ok = $stmt->execute([
                $entity->getNombre(),
                $entity->getDescripcion(),
                $entity->getPrecioUnitario(),
                $entity->getStock(),
                $entity->getIdCategoria(),
                $entity->getPeso(),
                $entity->getAlto(),
                $entity->getAncho(),
                $entity->getProfundidad()
            ]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al crear producto físico: '.$e->getMessage(), 0, $e);
        }
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof ProductoFisico) {
            throw new \InvalidArgumentException('Expected instance of ProductoFisico');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_update_producto_fisico(?,?,?,?,?,?,?,?,?,?)');
            $ok = $stmt->execute([
                $entity->getId(),
                $entity->getNombre(),
                $entity->getDescripcion(),
                $entity->getPrecioUnitario(),
                $entity->getStock(),
                $entity->getIdCategoria(),
                $entity->getPeso(),
                $entity->getAlto(),
                $entity->getAncho(),
                $entity->getProfundidad()
            ]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al actualizar producto físico: '.$e->getMessage(), 0, $e);
        }
    }

    public function delete(int $id): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_delete_producto_fisico(?)');
            $ok = $stmt->execute([$id]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al eliminar producto físico: '.$e->getMessage(), 0, $e);
        }
    }
}
