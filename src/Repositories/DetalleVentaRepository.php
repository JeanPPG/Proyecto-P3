<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\DetalleVenta;
use PDO;

class DetalleVentaRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    /** Mapear fila -> Entidad */
    private function hydrate(array $r): DetalleVenta
    {
        return new DetalleVenta(
            (int)$r['idVenta'],
            (int)$r['lineNumber'],
            (int)$r['idProducto'],
            (int)$r['cantidad'],
            (float)$r['precioUnitario']
        );
    }

    /** Listado global (si tienes SP global; si no, puedes lanzar excepción o devolver []) */
    public function findAll(): array
    {
        // Si NO tienes un SP global, puedes:
        // - devolver [] y no usar este método
        // - o crear sp_detalle_venta_list_all()
        $stmt = $this->db->query('CALL sp_detalle_venta_list_all()');
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
        while ($stmt->nextRowset()) {}
        $stmt->closeCursor();

        return array_map(fn($r) => $this->hydrate($r), $rows);
    }

    /** Lista por venta */
    public function listByVenta(int $idVenta): array
    {
        $stmt = $this->db->prepare('CALL sp_detalle_venta_list(:idVenta)');
        $stmt->execute([':idVenta' => $idVenta]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
        while ($stmt->nextRowset()) {}
        $stmt->closeCursor();

        return array_map(fn($r) => $this->hydrate($r), $rows);
    }

    /** Obtener una línea específica (PK compuesta) */
    public function findOne(int $idVenta, int $lineNumber): ?DetalleVenta
    {
        $stmt = $this->db->prepare('CALL sp_find_detalle_venta(:idVenta, :lineNumber)');
        $stmt->execute([':idVenta' => $idVenta, ':lineNumber' => $lineNumber]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
        while ($stmt->nextRowset()) {}
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }

    /** Compatibilidad con RepositoryInterface: findById no aplica; devolvemos null siempre */
    public function findById(int $id): ?object
    {
        // No aplica porque la PK es (idVenta, lineNumber)
        return null;
    }

    /** Insertar línea (autonumera lineNumber en el SP) */
    public function add(DetalleVenta $e): bool
    {
        $stmt = $this->db->prepare(
            'CALL sp_detalle_venta_add(:idVenta, :idProducto, :cantidad, :precioUnitario)'
        );
        $ok = $stmt->execute([
            ':idVenta'        => $e->getIdVenta(),
            ':idProducto'     => $e->getIdProducto(),
            ':cantidad'       => $e->getCantidad(),
            ':precioUnitario' => $e->getPrecioUnitario(), // puede ser NULL si tu SP lo permite
        ]);
        while ($stmt->nextRowset()) {}
        $stmt->closeCursor();
        return (bool)$ok;
    }

    /** Compatibilidad con RepositoryInterface::create */
    public function create(object $entity): bool
    {
        if (!$entity instanceof DetalleVenta) {
            throw new \InvalidArgumentException('Expected instance of DetalleVenta');
        }
        return $this->add($entity);
    }

    /** Actualizar línea */
    public function update(object $entity): bool
    {
        if (!$entity instanceof DetalleVenta) {
            throw new \InvalidArgumentException('Expected instance of DetalleVenta');
        }

        $stmt = $this->db->prepare(
            'CALL sp_detalle_venta_update(:idVenta, :lineNumber, :idProducto, :cantidad, :precioUnitario)'
        );
        $ok = $stmt->execute([
            ':idVenta'        => $entity->getIdVenta(),
            ':lineNumber'     => $entity->getLineNumber(),
            ':idProducto'     => $entity->getIdProducto(),
            ':cantidad'       => $entity->getCantidad(),
            ':precioUnitario' => $entity->getPrecioUnitario(), // puede ser NULL si tu SP lo permite
        ]);
        while ($stmt->nextRowset()) {}
        $stmt->closeCursor();
        return (bool)$ok;
    }

    /** Eliminar por PK compuesta */
    public function delete(int $idVenta, int $lineNumber = null): bool
    {
        // Permitimos firma (idVenta, lineNumber) para resolver tu error de "Too many arguments..."
        if ($lineNumber === null) {
            // Si te llaman con 1 solo parámetro por accidente, falla explícito:
            throw new \InvalidArgumentException('delete requiere (idVenta, lineNumber)');
        }

        $stmt = $this->db->prepare('CALL sp_detalle_venta_delete(:idVenta, :lineNumber)');
        $ok = $stmt->execute([
            ':idVenta'    => $idVenta,
            ':lineNumber' => $lineNumber
        ]);
        while ($stmt->nextRowset()) {}
        $stmt->closeCursor();
        return (bool)$ok;
    }
}
