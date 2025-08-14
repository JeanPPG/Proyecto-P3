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

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): Factura
    {

        $id          = (int)($row['id'] ?? $row['idFactura'] ?? $row['id_factura'] ?? 0);
        $idVenta     = (int)($row['idVenta'] ?? $row['id_venta'] ?? 0);
        $numero      = (string)($row['numero'] ?? '');
        $claveAcceso = (string)($row['claveAcceso'] ?? $row['clave_acceso'] ?? '');
        $fechaRaw    = (string)($row['fechaEmision'] ?? $row['fecha_emision'] ?? 'now');
        $estado      = (string)($row['estado'] ?? 'PENDIENTE');

        return new Factura(
            $id,
            $idVenta,
            $numero,
            $claveAcceso,
            new \DateTime($fechaRaw),
            $estado
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_factura_list()');
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
        while ($stmt->nextRowset()) { }
        $stmt->closeCursor();

        return array_map(fn($r) => $this->hydrate($r), $rows);
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_find_factura(:p_id)');
        $stmt->execute([':p_id' => $id]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
        while ($stmt->nextRowset()) {  }
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }

    public function createWithVenta(int $idVenta, string $numero, string $claveAcceso): int|bool
    {
        $stmt = $this->db->prepare('CALL sp_factura_create(:p_idVenta, :p_numero, :p_claveAcceso)');
        $ok = $stmt->execute([
            ':p_idVenta'     => $idVenta,
            ':p_numero'      => $numero,
            ':p_claveAcceso' => $claveAcceso,
        ]);

        $row = $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
        while ($stmt->nextRowset()) {  }
        $stmt->closeCursor();

        if (!$ok) return false;
        if ($row && isset($row['factura_id'])) {
            return (int)$row['factura_id'];
        }
        return true;
    }


    public function markEnviada(int $id, ?string $numero = null, ?string $claveAcceso = null): bool
    {
        $stmt = $this->db->prepare('CALL sp_factura_mark_enviada(:p_id, :p_numero, :p_claveAcceso)');
        $ok = $stmt->execute([
            ':p_id'          => $id,
            ':p_numero'      => $numero,
            ':p_claveAcceso' => $claveAcceso,
        ]);
        while ($stmt->fetch(PDO::FETCH_ASSOC)) {  }
        while ($stmt->nextRowset()) {  }
        $stmt->closeCursor();

        return (bool)$ok;
    }

    public function anular(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_factura_anular(:p_id)');
        $ok = $stmt->execute(params: [':p_id' => $id]);
        while ($stmt->fetch(PDO::FETCH_ASSOC)) {  }
        while ($stmt->nextRowset()) {  }
        $stmt->closeCursor();

        return (bool)$ok;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Factura) {
            throw new \InvalidArgumentException('Expected instance of Factura');
        }
        $res = $this->createWithVenta($entity->getIdVenta(), $entity->getNumero(), $entity->getClaveAcceso());
        return $res === true || (is_int($res) && $res > 0);
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Factura) {
            throw new \InvalidArgumentException('Expected instance of Factura');
        }

        return true;
    }

    public function delete(int $id): bool
    {
        return false;
    }
}
