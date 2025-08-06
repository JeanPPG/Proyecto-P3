<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\ProductoFisico;
use PDO;

class ProductoFisicoRepository implements RepositoryInterface
{
    private PDO $db;
    private ProductoRepository $productoRepository;

    public function __construct()
    {
        $this->db = Database::getConnection();
        $this->productoRepository = new ProductoRepository();
    }

    private function hydrate(array $row): ProductoFisico
    {
        $productoBase = $this->productoRepository->findById((int)$row['id_producto']);

        return new ProductoFisico(
            $productoBase->getId(),
            $productoBase->getNombre(),
            $productoBase->getDescripcion(),
            $productoBase->getPrecio(),
            $productoBase->getStock(),
            $productoBase->getCategoria(),
            $row['peso'],
            $row['dimensiones']
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_producto_fisico_list();');
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
        if (!$entity instanceof ProductoFisico) {
            throw new \InvalidArgumentException('Expected instance of ProductoFisico');
        }

        $stmt = $this->db->prepare('CALL sp_create_producto_fisico(:id_producto, :peso, :dimensiones);');
        $ok = $stmt->execute([
            ':id_producto' => $entity->getId(),
            ':peso' => $entity->getPeso(),
            ':dimensiones' => $entity->getDimensiones()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof ProductoFisico) {
            throw new \InvalidArgumentException('Expected instance of ProductoFisico');
        }

        $stmt = $this->db->prepare('CALL sp_update_producto_fisico(:id_producto, :peso, :dimensiones);');
        $ok = $stmt->execute([
            ':id_producto' => $entity->getId(),
            ':peso' => $entity->getPeso(),
            ':dimensiones' => $entity->getDimensiones()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_delete_producto_fisico(:id_producto);');
        $ok = $stmt->execute([':id_producto' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_producto_fisico_find_by_id(:id_producto);');
        $stmt->execute([':id_producto' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
