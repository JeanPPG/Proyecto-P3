<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Factura;
use PDO;
use PDOException;

class FacturaRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): Factura
    {
        $fecha = isset($row['fechaEmision']) && $row['fechaEmision'] !== null
            ? new \DateTime((string)$row['fechaEmision'])
            : new \DateTime();

        return new Factura(
            (int)$row['id'],
            (int)$row['idVenta'],
            (string)($row['numero'] ?? ''),
            (string)($row['claveAcceso'] ?? ''),
            $fecha,
            (string)($row['estado'] ?? 'PENDIENTE')
        );
    }

    public function findAll(): array
    {
        try {
            $stmt = $this->db->query('CALL sp_factura_list()');
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $out = [];
            foreach ($rows as $r) {
                $out[] = $this->hydrate($r);
            }
            return $out;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar facturas: '.$e->getMessage(), 0, $e);
        }
    }

    public function findById(int $id): ?object
    {
        try {
            $stmt = $this->db->prepare('CALL sp_find_factura(?)');
            $stmt->execute([$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            return $row ? $this->hydrate($row) : null;
        } catch (PDOException $e) {
            if (stripos($e->getMessage(), 'sp_find_factura') !== false) {
                $stmt = $this->db->prepare('CALL sp_factura_find_by_id(?)');
                $stmt->execute([$id]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
                return $row ? $this->hydrate($row) : null;
            }
            throw new \RuntimeException('Error al buscar factura: '.$e->getMessage(), 0, $e);
        }
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Factura) {
            throw new \InvalidArgumentException('Expected instance of Factura');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_factura_create(?, ?, ?)');
            $ok = $stmt->execute([
                $entity->getIdVenta(),
                $entity->getNumero(),
                $entity->getClaveAcceso()
            ]);
            // $row = $stmt->fetch(PDO::FETCH_ASSOC); $newId = $row['factura_id'] ?? null;
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al crear factura: '.$e->getMessage(), 0, $e);
        }
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Factura) {
            throw new \InvalidArgumentException('Expected instance of Factura');
        }

        try {
            $estado = strtoupper($entity->getEstado());

            if ($estado === 'ENVIADA') {
                $stmt = $this->db->prepare('CALL sp_factura_mark_enviada(?, ?, ?)');
                $ok = $stmt->execute([
                    $entity->getId(),
                    $entity->getNumero() ?: null,
                    $entity->getClaveAcceso() ?: null
                ]);
                $stmt->fetchAll(PDO::FETCH_ASSOC); 
                $stmt->closeCursor();
                return (bool)$ok;
            }

            if ($estado === 'ANULADA') {
                $stmt = $this->db->prepare('CALL sp_factura_anular(?)');
                $ok = $stmt->execute([$entity->getId()]);
                $stmt->fetchAll(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
                return (bool)$ok;
            }

            return false;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al actualizar factura: '.$e->getMessage(), 0, $e);
        }
    }

    public function delete(int $id): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_factura_anular(?)');
            $ok = $stmt->execute([$id]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al anular factura: '.$e->getMessage(), 0, $e);
        }
    }

 
    public function markEnviada(int $id, ?string $numero = null, ?string $claveAcceso = null): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_factura_mark_enviada(?, ?, ?)');
            $ok = $stmt->execute([$id, $numero, $claveAcceso]);
            $stmt->fetchAll(PDO::FETCH_ASSOC); 
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al marcar enviada: '.$e->getMessage(), 0, $e);
        }
    }

    public function anular(int $id): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_factura_anular(?)');
            $ok = $stmt->execute([$id]);
            $stmt->fetchAll(PDO::FETCH_ASSOC); 
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al anular factura: '.$e->getMessage(), 0, $e);
        }
    }

    public function findByVenta(int $idVenta): ?Factura
    {
        try {
            $stmt = $this->db->prepare('CALL sp_factura_by_venta(?)');
            $stmt->execute([$idVenta]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            return $row ? $this->hydrate($row) : null;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al buscar factura por venta: '.$e->getMessage(), 0, $e);
        }
    }
}
