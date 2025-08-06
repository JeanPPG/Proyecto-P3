<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Factura;
use PDO;

class FacturaRepository implements RepositoryInterface
{
    private PDO $db;
    private VentasRepository $ventasRepository;

    public function __construct()
    {
        $this->db = Database::getConnection();
        $this->ventasRepository = new VentasRepository();
    }

    private function hydrate(array $row): Factura
    {
        $venta = $this->ventasRepository->findById((int)$row['id_venta']);

        return new Factura(
            (int)$row['id_factura'],
            $venta,
            $row['fecha_emision'],
            (float)$row['total']
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_factura_list();');
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $facturas = [];
        foreach ($rows as $r) {
            $facturas[] = $this->hydrate($r);
        }
        return $facturas;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Factura) {
            throw new \InvalidArgumentException('Expected instance of Factura');
        }

        $stmt = $this->db->prepare('CALL sp_create_factura(:id_venta, :fecha_emision, :total);');
        $ok = $stmt->execute([
            ':id_venta' => $entity->getVenta()->getId(),
            ':fecha_emision' => $entity->getFechaEmision(),
            ':total' => $entity->getTotal()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Factura) {
            throw new \InvalidArgumentException('Expected instance of Factura');
        }

        $stmt = $this->db->prepare('CALL sp_update_factura(:id_factura, :id_venta, :fecha_emision, :total);');
        $ok = $stmt->execute([
            ':id_factura' => $entity->getId(),
            ':id_venta' => $entity->getVenta()->getId(),
            ':fecha_emision' => $entity->getFechaEmision(),
            ':total' => $entity->getTotal()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_delete_factura(:id_factura);');
        $ok = $stmt->execute([':id_factura' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_factura_find_by_id(:id_factura);');
        $stmt->execute([':id_factura' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
