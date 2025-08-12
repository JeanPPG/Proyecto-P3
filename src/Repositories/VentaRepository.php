<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Venta;
use PDO;

class VentaRepository implements RepositoryInterface
{
    private PDO $db;
    private PersonaNaturalRepository $personaNaturalRepository;
    private PersonaJuridicaRepository $personaJuridicaRepository;

    public function __construct()
    {
        $this->db = Database::getConnection();
        $this->personaNaturalRepository = new PersonaNaturalRepository();
        $this->personaJuridicaRepository = new PersonaJuridicaRepository();
    }

    private function hydrate(array $row): Venta
    {
        // Determinar tipo de cliente
        $cliente = null;
        if (!empty($row['id_persona_natural'])) {
            $cliente = $this->personaNaturalRepository->findById((int)$row['id_persona_natural']);
        } elseif (!empty($row['id_persona_juridica'])) {
            $cliente = $this->personaJuridicaRepository->findById((int)$row['id_persona_juridica']);
        }

        return new Venta(
            (int)$row['id_venta'],
            $cliente,
            $row['fecha_venta'],
            (float)$row['total']
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_venta_list();');
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $ventas = [];
        foreach ($rows as $r) {
            $ventas[] = $this->hydrate($r);
        }
        return $ventas;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Venta) {
            throw new \InvalidArgumentException('Expected instance of Venta');
        }

        $stmt = $this->db->prepare('CALL sp_create_venta(:id_cliente, :fecha_venta, :total);');
        $ok = $stmt->execute([
            ':id_cliente' => $entity->getCliente()->getId(),
            ':fecha_venta' => $entity->getFechaVenta(),
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
        if (!$entity instanceof Venta) {
            throw new \InvalidArgumentException('Expected instance of Venta');
        }

        $stmt = $this->db->prepare('CALL sp_update_venta(:id_venta, :id_cliente, :fecha_venta, :total);');
        $ok = $stmt->execute([
            ':id_venta' => $entity->getId(),
            ':id_cliente' => $entity->getCliente()->getId(),
            ':fecha_venta' => $entity->getFechaVenta(),
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
        $stmt = $this->db->prepare('CALL sp_delete_venta(:id_venta);');
        $ok = $stmt->execute([':id_venta' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_venta_find_by_id(:id_venta);');
        $stmt->execute([':id_venta' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
