<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Categoria;
use PDO;

class CategoriaRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): Categoria
    {
        return new Categoria(
            (int)$row['id_categoria'],
            $row['nombre'],
            $row['descripcion']
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_categoria_list();');
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $categorias = [];
        foreach ($rows as $r) {
            $categorias[] = $this->hydrate($r);
        }
        return $categorias;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Categoria) {
            throw new \InvalidArgumentException('Expected instance of Categoria');
        }

        $stmt = $this->db->prepare('CALL sp_create_categoria(:nombre, :descripcion);');
        $ok = $stmt->execute([
            ':nombre' => $entity->getNombre(),
            ':descripcion' => $entity->getDescripcion()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Categoria) {
            throw new \InvalidArgumentException('Expected instance of Categoria');
        }

        $stmt = $this->db->prepare('CALL sp_update_categoria(:id_categoria, :nombre, :descripcion);');
        $ok = $stmt->execute([
            ':id_categoria' => $entity->getId(),
            ':nombre' => $entity->getNombre(),
            ':descripcion' => $entity->getDescripcion()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_delete_categoria(:id_categoria);');
        $ok = $stmt->execute([':id_categoria' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_categoria_find_by_id(:id_categoria);');
        $stmt->execute([':id_categoria' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
