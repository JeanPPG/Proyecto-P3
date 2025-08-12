<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\DetalleVenta;
use PDO;
use PDOException;

class DetalleVentaRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): DetalleVenta
    {
        return new DetalleVenta(
            (int)$row['idVenta'],
            (int)$row['lineNumber'],
            (int)$row['idProducto'],
            (int)$row['cantidad'],
            (float)$row['precioUnitario']
        );
    }

    public function listByVenta(int $idVenta): array
    {
        try {
            $stmt = $this->db->prepare('CALL sp_detalle_venta_list(?)');
            $stmt->execute([$idVenta]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $out = [];
            foreach ($rows as $r) {
                $out[] = $this->hydrate($r);
            }
            return $out;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar detalles: '.$e->getMessage(), 0, $e);
        }
    }

    public function findOne(int $idVenta, int $lineNumber): ?DetalleVenta
    {
        try {
            $stmt = $this->db->prepare('CALL sp_find_detalle_venta(?, ?)');
            $stmt->execute([$idVenta, $lineNumber]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            return $row ? $this->hydrate($row) : null;
        } catch (PDOException $e) {
            if (stripos($e->getMessage(), 'sp_find_detalle_venta') !== false) {
                $stmt = $this->db->prepare('CALL sp_detalle_venta_find_by_id(?, ?)');
                $stmt->execute([$idVenta, $lineNumber]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
                return $row ? $this->hydrate($row) : null;
            }
            throw new \RuntimeException('Error al buscar detalle: '.$e->getMessage(), 0, $e);
        }
    }

    public function add(DetalleVenta $entity): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_detalle_venta_add(?, ?, ?, ?)');
            $ok = $stmt->execute([
                $entity->getIdVenta(),
                $entity->getIdProducto(),
                $entity->getCantidad(),
                $entity->getPrecioUnitario()  
            ]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al agregar detalle: '.$e->getMessage(), 0, $e);
        }
    }

    public function updateLine(DetalleVenta $entity): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_detalle_venta_update(?, ?, ?, ?, ?)');
            $ok = $stmt->execute([
                $entity->getIdVenta(),
                $entity->getLineNumber(),
                $entity->getIdProducto(),
                $entity->getCantidad(),
                $entity->getPrecioUnitario()
            ]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al actualizar detalle: '.$e->getMessage(), 0, $e);
        }
    }

    public function deleteByPk(int $idVenta, int $lineNumber): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_detalle_venta_delete(?, ?)');
            $ok = $stmt->execute([$idVenta, $lineNumber]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al eliminar detalle: '.$e->getMessage(), 0, $e);
        }
    }

   
    public function findAll(): array
    {
        throw new \BadMethodCallException('Usa listByVenta($idVenta) para obtener los detalles de una venta.');
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof DetalleVenta) {
            throw new \InvalidArgumentException('Se esperaba DetalleVenta');
        }
        return $this->add($entity);
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof DetalleVenta) {
            throw new \InvalidArgumentException('Se esperaba DetalleVenta');
        }
        return $this->updateLine($entity);
    }

    public function delete(int $id): bool
    {
        throw new \BadMethodCallException('Usa deleteByPk($idVenta, $lineNumber) para borrar una línea.');
    }

    public function findById(int $id): ?object
    {
        throw new \BadMethodCallException('Usa findOne($idVenta, $lineNumber) para buscar una línea.');
    }
}
