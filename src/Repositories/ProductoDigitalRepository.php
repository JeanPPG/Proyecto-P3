<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\ProductoDigital;
use PDO;

class ProductoDigitalRepository implements RepositoryInterface
{
    private PDO $db;
    private ProductoRepository $productoRepository;

    public function __construct()
    {
        $this->db = Database::getConnection();
        $this->productoRepository = new ProductoRepository();
    }

    private function hydrate(array $row): ProductoDigital
    {
        $productoBase = $this->productoRepository->findById((int)$row['id_producto']);

        return new ProductoDigital(
            $productoBase->getId(),
            $productoBase->getNombre(),
            $productoBase->getDescripcion(),
            $productoBase->getPrecio(),
            $productoBase->getStock(),
            $productoBase->getCategoria(),
            $row['formato'],
            $row['url_descarga']
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_producto_digital_list();');
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $productos = [];
        foreach ($rows as $r) {
            $productos[] = $this->hydrate($r);
        }
        return $productos;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof ProductoDigital) {
            throw new \InvalidArgumentException('Expected instance of ProductoDigital');
        }

        $stmt = $this->db->prepare('CALL sp_create_producto_digital(:id_producto, :formato, :url_descarga);');
        $ok = $stmt->execute([
            ':id_producto' => $entity->getId(),
            ':formato' => $entity->getFormato(),
            ':url_descarga' => $entity->getUrlDescarga()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof ProductoDigital) {
            throw new \InvalidArgumentException('Expected instance of ProductoDigital');
        }

        $stmt = $this->db->prepare('CALL sp_update_producto_digital(:id_producto, :formato, :url_descarga);');
        $ok = $stmt->execute([
            ':id_producto' => $entity->getId(),
            ':formato' => $entity->getFormato(),
            ':url_descarga' => $entity->getUrlDescarga()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_delete_producto_digital(:id_producto);');
        $ok = $stmt->execute([':id_producto' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_producto_digital_find_by_id(:id_producto);');
        $stmt->execute([':id_producto' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
