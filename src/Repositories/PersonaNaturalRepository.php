<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\PersonaNatural;
use PDO;
use PDOException;

class PersonaNaturalRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): PersonaNatural
    {
        return new PersonaNatural(
            (int)$row['id'],
            (string)$row['email'],
            (string)$row['telefono'],
            (string)$row['direccion'],
            (string)$row['tipo'],
            (string)$row['nombres'],
            (string)$row['apellidos'],
            (string)$row['cedula']
        );
    }

    public function findAll(): array
    {
        try {
            $stmt = $this->db->query('CALL sp_persona_natural_list()');
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $out = [];
            foreach ($rows as $r) {
                $out[] = $this->hydrate($r);
            }
            return $out;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar personas naturales: '.$e->getMessage(), 0, $e);
        }
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof PersonaNatural) {
            throw new \InvalidArgumentException('Se esperaba PersonaNatural');
        }
        try {
            $stmt = $this->db->prepare('CALL sp_create_persona_natural(?,?,?,?,?,?)');
            $ok = $stmt->execute([
                $entity->getEmail(),
                $entity->getTelefono(),
                $entity->getDireccion(),
                $entity->getNombres(),
                $entity->getApellidos(),
                $entity->getCedula()
            ]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al crear persona natural: '.$e->getMessage(), 0, $e);
        }
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof PersonaNatural) {
            throw new \InvalidArgumentException('Se esperaba PersonaNatural');
        }
        try {

            $stmt = $this->db->prepare('CALL sp_update_persona_natural(?,?,?,?,?,?)');
            $ok = $stmt->execute([
                $entity->getId(),
                $entity->getTelefono(),
                $entity->getDireccion(),
                $entity->getNombres(),
                $entity->getApellidos(),
                $entity->getCedula()
            ]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al actualizar persona natural: '.$e->getMessage(), 0, $e);
        }
    }

    public function delete(int $id): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_delete_persona_natural(?)');
            $ok = $stmt->execute([$id]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al eliminar persona natural: '.$e->getMessage(), 0, $e);
        }
    }

    public function findById(int $id): ?object
    {
        try {
            $stmt = $this->db->prepare('CALL sp_find_persona_natural(?)');
            $stmt->execute([$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return $row ? $this->hydrate($row) : null;
        } catch (PDOException $e) {
            if (stripos($e->getMessage(), 'sp_find_persona_natural') !== false) {
                $stmt = $this->db->prepare('CALL sp_persona_natural_find_by_id(?)');
                $stmt->execute([$id]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
                return $row ? $this->hydrate($row) : null;
            }
            throw new \RuntimeException('Error al buscar persona natural: '.$e->getMessage(), 0, $e);
        }
    }
}
