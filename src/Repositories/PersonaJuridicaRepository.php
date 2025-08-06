<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\PersonaJuridica;
use PDO;

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
            (int)$row['id_persona_juridica'],
            $row['razon_social'],
            $row['ruc'],
            $row['direccion'],
            $row['telefono'],
            $row['email']
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_persona_juridica_list();');
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $listado = [];
        foreach ($rows as $r) {
            $listado[] = $this->hydrate($r);
        }
        return $listado;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof PersonaJuridica) {
            throw new \InvalidArgumentException('Expected instance of PersonaJuridica');
        }

        $stmt = $this->db->prepare('CALL sp_create_persona_juridica(:razon_social, :ruc, :direccion, :telefono, :email);');
        $ok = $stmt->execute([
            ':razon_social' => $entity->getRazonSocial(),
            ':ruc' => $entity->getRuc(),
            ':direccion' => $entity->getDireccion(),
            ':telefono' => $entity->getTelefono(),
            ':email' => $entity->getEmail()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof PersonaJuridica) {
            throw new \InvalidArgumentException('Expected instance of PersonaJuridica');
        }

        $stmt = $this->db->prepare('CALL sp_update_persona_juridica(:id_persona_juridica, :razon_social, :ruc, :direccion, :telefono, :email);');
        $ok = $stmt->execute([
            ':id_persona_juridica' => $entity->getId(),
            ':razon_social' => $entity->getRazonSocial(),
            ':ruc' => $entity->getRuc(),
            ':direccion' => $entity->getDireccion(),
            ':telefono' => $entity->getTelefono(),
            ':email' => $entity->getEmail()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_delete_persona_juridica(:id_persona_juridica);');
        $ok = $stmt->execute([':id_persona_juridica' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_persona_juridica_find_by_id(:id_persona_juridica);');
        $stmt->execute([':id_persona_juridica' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
