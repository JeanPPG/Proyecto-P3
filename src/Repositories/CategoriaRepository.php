<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Categoria;
use PDO;
use PDOException;

class CategoriaRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }


    private function hydrate(array $row): Categoria
    {
        $cat = new Categoria(
            (int)$row['id'],
            (string)$row['nombre'],
            $row['descripcion'] ?? null
        );

        if (method_exists($cat, 'setEstado') && isset($row['estado'])) {
            $cat->setEstado((string)$row['estado']);
        }
        if (method_exists($cat, 'setIdPadre')) {
            $cat->setIdPadre(isset($row['idPadre']) ? (int)$row['idPadre'] : null);
        }

        return $cat;
    }

    private function getEstadoFromEntity(object $entity): string
    {
        return method_exists($entity, 'getEstado') ? (string)$entity->getEstado() : 'ACTIVO';
    }

    private function getIdPadreFromEntity(object $entity): ?int
    {
        if (method_exists($entity, 'getIdPadre')) {
            $v = $entity->getIdPadre();
            return $v !== null ? (int)$v : null;
        }
        return null;
    }

    public function findAll(): array
    {
        try {
            $stmt = $this->db->query('CALL sp_categoria_list()');
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $items = [];
            foreach ($rows as $r) {
                $items[] = $this->hydrate($r);
            }
            return $items;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar categorías: '.$e->getMessage(), 0, $e);
        }
    }

    public function findById(int $id): ?object
    {
        try {
            $stmt = $this->db->prepare('CALL sp_find_categoria(?)');
            $stmt->execute([$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            return $row ? $this->hydrate($row) : null;
        } catch (PDOException $e) {
            if (stripos($e->getMessage(), 'sp_find_categoria') !== false) {
                $stmt = $this->db->prepare('CALL sp_categoria_find_by_id(?)');
                $stmt->execute([$id]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
                return $row ? $this->hydrate($row) : null;
            }
            throw new \RuntimeException('Error al buscar categoría: '.$e->getMessage(), 0, $e);
        }
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Categoria) {
            throw new \InvalidArgumentException('Expected instance of Categoria');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_create_categoria(?,?,?,?)');
            $ok = $stmt->execute([
                $entity->getNombre(),
                $entity->getDescripcion(),
                $this->getEstadoFromEntity($entity),      
                $this->getIdPadreFromEntity($entity)     
            ]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al crear categoría: '.$e->getMessage(), 0, $e);
        }
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Categoria) {
            throw new \InvalidArgumentException('Expected instance of Categoria');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_update_categoria(?,?,?,?,?)');
            $ok = $stmt->execute([
                $entity->getId(),
                $entity->getNombre(),
                $entity->getDescripcion(),
                $this->getEstadoFromEntity($entity),
                $this->getIdPadreFromEntity($entity)
            ]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al actualizar categoría: '.$e->getMessage(), 0, $e);
        }
    }

    public function delete(int $id): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_delete_categoria(?)');
            $ok = $stmt->execute([$id]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al eliminar categoría: '.$e->getMessage(), 0, $e);
        }
    }


    public function tree(?int $rootId = null): array
    {
        try {
            $stmt = $this->db->prepare('CALL sp_categoria_tree(?)');
            $stmt->bindValue(1, $rootId, $rootId === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
            $stmt->execute();
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return $rows; 
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al obtener árbol de categorías: '.$e->getMessage(), 0, $e);
        }
    }
}
