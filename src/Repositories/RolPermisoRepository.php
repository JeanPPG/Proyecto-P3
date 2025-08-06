<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\RolPermiso;
use PDO;

class RolPermisoRepository implements RepositoryInterface
{
    private PDO $db;
    private RolRepository $rolRepository;
    private PermisoRepository $permisoRepository;

    public function __construct()
    {
        $this->db = Database::getConnection();
        $this->rolRepository = new RolRepository();
        $this->permisoRepository = new PermisoRepository();
    }

    private function hydrate(array $row): RolPermiso
    {
        $rol = $this->rolRepository->findById((int)$row['id_rol']);
        $permiso = $this->permisoRepository->findById((int)$row['id_permiso']);

        return new RolPermiso(
            (int)$row['id_rol_permiso'],
            $rol,
            $permiso
        );
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_rol_permiso_list();');
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $rolPermisos = [];
        foreach ($rows as $r) {
            $rolPermisos[] = $this->hydrate($r);
        }
        return $rolPermisos;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof RolPermiso) {
            throw new \InvalidArgumentException('Expected instance of RolPermiso');
        }

        $stmt = $this->db->prepare('CALL sp_create_rol_permiso(:id_rol, :id_permiso);');
        $ok = $stmt->execute([
            ':id_rol' => $entity->getRol()->getId(),
            ':id_permiso' => $entity->getPermiso()->getId()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof RolPermiso) {
            throw new \InvalidArgumentException('Expected instance of RolPermiso');
        }

        $stmt = $this->db->prepare('CALL sp_update_rol_permiso(:id_rol_permiso, :id_rol, :id_permiso);');
        $ok = $stmt->execute([
            ':id_rol_permiso' => $entity->getId(),
            ':id_rol' => $entity->getRol()->getId(),
            ':id_permiso' => $entity->getPermiso()->getId()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_delete_rol_permiso(:id_rol_permiso);');
        $ok = $stmt->execute([':id_rol_permiso' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_rol_permiso_find_by_id(:id_rol_permiso);');
        $stmt->execute([':id_rol_permiso' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
