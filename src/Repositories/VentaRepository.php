<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Venta;
use PDO;
use PDOException;

class VentaRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): Venta
    {
        $fecha = isset($row['fecha']) ? new \DateTime((string)$row['fecha']) : new \DateTime();

        return new Venta(
            (int)$row['id'],
            $fecha,
            (int)$row['idCliente'],
            isset($row['total']) ? (float)$row['total'] : 0.0,
            isset($row['estado']) ? (string)$row['estado'] : 'BORRADOR'
        );
    }

    public function findAll(): array
    {
        try {
            $stmt = $this->db->query('CALL sp_venta_list()');
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $items = [];
            foreach ($rows as $r) {
                $items[] = $this->hydrate($r);
            }
            return $items;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar ventas: '.$e->getMessage(), 0, $e);
        }
    }

    public function findById(int $id): ?object
    {
        try {
            $stmt = $this->db->prepare('CALL sp_find_venta(?)');
            $stmt->execute([$id]);

            $header = $stmt->fetch(PDO::FETCH_ASSOC);
            if (!$header) {
                while ($stmt->nextRowset()) { }
                $stmt->closeCursor();
                return null;
            }
            $venta = $this->hydrate($header);

           
            if ($stmt->nextRowset()) {
                $stmt->fetchAll(PDO::FETCH_ASSOC);
            }
            while ($stmt->nextRowset()) {  }

            $stmt->closeCursor();
            return $venta;
        } catch (PDOException $e) {
            if (stripos($e->getMessage(), 'sp_find_venta') !== false) {
                $stmt = $this->db->prepare('CALL sp_venta_find_by_id(?)');
                $stmt->execute([$id]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
                return $row ? $this->hydrate($row) : null;
            }
            throw new \RuntimeException('Error al buscar venta: '.$e->getMessage(), 0, $e);
        }
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Venta) {
            throw new \InvalidArgumentException('Expected instance of Venta');
        }
        try {
            $stmt = $this->db->prepare('CALL sp_create_venta(?)');
            $ok = $stmt->execute([$entity->getIdCliente()]);
            // $row = $stmt->fetch(PDO::FETCH_ASSOC); $newId = $row['venta_id'] ?? null;
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al crear venta: '.$e->getMessage(), 0, $e);
        }
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Venta) {
            throw new \InvalidArgumentException('Expected instance of Venta');
        }
        try {
            $stmt = $this->db->prepare('CALL sp_venta_update_header(?,?,?)');
            $ok = $stmt->execute([
                $entity->getId(),
                $entity->getIdCliente(),
                $entity->getEstado()
            ]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al actualizar venta: '.$e->getMessage(), 0, $e);
        }
    }

    public function delete(int $id): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_delete_venta(?)');
            $ok = $stmt->execute([$id]);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al eliminar venta: '.$e->getMessage(), 0, $e);
        }
    }


    public function addDetalle(int $idVenta, int $idProducto, int $cantidad, ?float $precioUnitario = null): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_venta_add_detalle(?,?,?,?)');
            $ok = $stmt->execute([$idVenta, $idProducto, $cantidad, $precioUnitario]);
            do { $stmt->fetchAll(PDO::FETCH_ASSOC); } while ($stmt->nextRowset());
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al agregar detalle: '.$e->getMessage(), 0, $e);
        }
    }

    public function recalcTotal(int $idVenta): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_venta_recalcular_total(?)');
            $ok = $stmt->execute([$idVenta]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al recalcular total: '.$e->getMessage(), 0, $e);
        }
    }
}

