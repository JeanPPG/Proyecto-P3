<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Producto;
use PDO;

class ProductoRepository implements RepositoryInterface
{
    private PDO $db;
    private CategoriaRepository $categoriaRepository;

    public function __construct()
    {
        $this->db = Database::getConnection();
        $this->categoriaRepository = new CategoriaRepository();
    }

    private function hydrate(array $row): Producto
    {
        
        $categoria = $this->categoriaRepository->findById((int)$row['id_categoria']);

        return new Producto(
            (int)$row['id_producto'],
            $row['nombre'],
            $row['descripcion'],
            (float)$row['precio'],
            (int)$row['stock'],
            $categoria
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_producto_list();');
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
        if (!$entity instanceof Producto) {
            throw new \InvalidArgumentException('Expected instance of Producto');
        }

        $stmt = $this->db->prepare('CALL sp_create_producto(:nombre, :descripcion, :precio, :stock, :id_categoria);');
        $ok = $stmt->execute([
            ':nombre' => $entity->getNombre(),
            ':descripcion' => $entity->getDescripcion(),
            ':precio' => $entity->getPrecio(),
            ':stock' => $entity->getStock(),
            ':id_categoria' => $entity->getCategoria()->getId()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Producto) {
            throw new \InvalidArgumentException('Expected instance of Producto');
        }

        $stmt = $this->db->prepare('CALL sp_update_producto(:id_producto, :nombre, :descripcion, :precio, :stock, :id_categoria);');
        $ok = $stmt->execute([
            ':id_producto' => $entity->getId(),
            ':nombre' => $entity->getNombre(),
            ':descripcion' => $entity->getDescripcion(),
            ':precio' => $entity->getPrecio(),
            ':stock' => $entity->getStock(),
            ':id_categoria' => $entity->getCategoria()->getId()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_delete_producto(:id_producto);');
        $ok = $stmt->execute([':id_producto' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_producto_find_by_id(:id_producto);');
        $stmt->execute([':id_producto' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
