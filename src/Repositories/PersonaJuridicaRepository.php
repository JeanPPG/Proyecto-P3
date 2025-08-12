<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\PersonaJuridica;
use PDO;
use PDOException;

class PersonaJuridicaRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): PersonaJuridica
    {
        return new PersonaJuridica(
            (int)$row['id'],
            (string)$row['email'],
            (string)$row['telefono'],
            (string)$row['direccion'],
            (string)$row['tipo'],
            (string)$row['razonSocial'],
            (string)$row['ruc'],
            isset($row['representanteLegal']) ? (string)$row['representanteLegal'] : null
        );
    }

    public function findAll(): array
    {
        try {
            $stmt = $this->db->query('CALL sp_persona_juridica_list()');
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $out = [];
            foreach ($rows as $r) {
                $out[] = $this->hydrate($r);
            }
            return $out;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar personas jurídicas: '.$e->getMessage(), 0, $e);
        }
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof PersonaJuridica) {
            throw new \InvalidArgumentException('Se esperaba PersonaJuridica');
        }
        try {
            $stmt = $this->db->prepare('CALL sp_create_persona_juridica(?,?,?,?,?,?)');
            $ok = $stmt->execute([
                $entity->getEmail(),
                $entity->getTelefono(),
                $entity->getDireccion(),
                $entity->getRazonSocial(),
                $entity->getRuc(),
                $entity->getRepresentanteLegal()
            ]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al crear persona jurídica: '.$e->getMessage(), 0, $e);
        }
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof PersonaJuridica) {
            throw new \InvalidArgumentException('Se esperaba PersonaJuridica');
        }
        try {
            $stmt = $this->db->prepare('CALL sp_update_persona_juridica(?,?,?,?,?,?,?)');
            $ok = $stmt->execute([
                $entity->getId(),
                $entity->getEmail(),
                $entity->getTelefono(),
                $entity->getDireccion(),
                $entity->getRazonSocial(),
                $entity->getRuc(),
                $entity->getRepresentanteLegal()
            ]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al actualizar persona jurídica: '.$e->getMessage(), 0, $e);
        }
    }

    public function delete(int $id): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_delete_persona_juridica(?)');
            $ok = $stmt->execute([$id]);
            $stmt->closeCursor();
            return $ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al eliminar persona jurídica: '.$e->getMessage(), 0, $e);
        }
    }

    public function findById(int $id): ?object
    {
        try {
            $stmt = $this->db->prepare('CALL sp_find_persona_juridica(?)');
            $stmt->execute([$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return $row ? $this->hydrate($row) : null;
        } catch (PDOException $e) {
            if (stripos($e->getMessage(), 'sp_find_persona_juridica') !== false) {
                $stmt = $this->db->prepare('CALL sp_persona_juridica_find_by_id(?)');
                $stmt->execute([$id]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
                return $row ? $this->hydrate($row) : null;
            }
            throw new \RuntimeException('Error al buscar persona jurídica: '.$e->getMessage(), 0, $e);
        }
    }
}
