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
    private ProductoRepository $productoRepository;

    public function __construct()
    {
        $this->db = Database::getConnection();
        $this->productoRepository = new ProductoRepository();
    }

    private function hydrate(array $row): DetalleVenta
    {
        $producto = $this->productoRepository->findById((int)$row['id_producto']);

        return new DetalleVenta(
            (int)$row['id_detalle_venta'],
            (int)$row['id_venta'],
            $producto,
            (int)$row['cantidad'],
            (float)$row['subtotal']
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_detalle_venta_list();');
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $detalles = [];
        foreach ($rows as $r) {
            $detalles[] = $this->hydrate($r);
        }
        return $detalles;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof DetalleVenta) {
            throw new \InvalidArgumentException('Expected instance of DetalleVenta');
        }

        $stmt = $this->db->prepare('CALL sp_create_detalle_venta(:id_venta, :id_producto, :cantidad, :subtotal);');
        $ok = $stmt->execute([
            ':id_venta' => $entity->getIdVenta(),
            ':id_producto' => $entity->getProducto()->getId(),
            ':cantidad' => $entity->getCantidad(),
            ':subtotal' => $entity->getSubtotal()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof DetalleVenta) {
            throw new \InvalidArgumentException('Expected instance of DetalleVenta');
        }

        $stmt = $this->db->prepare('CALL sp_update_detalle_venta(:id_detalle_venta, :id_venta, :id_producto, :cantidad, :subtotal);');
        $ok = $stmt->execute([
            ':id_detalle_venta' => $entity->getId(),
            ':id_venta' => $entity->getIdVenta(),
            ':id_producto' => $entity->getProducto()->getId(),
            ':cantidad' => $entity->getCantidad(),
            ':subtotal' => $entity->getSubtotal()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_delete_detalle_venta(:id_detalle_venta);');
        $ok = $stmt->execute([':id_detalle_venta' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_detalle_venta_find_by_id(:id_detalle_venta);');
        $stmt->execute([':id_detalle_venta' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
