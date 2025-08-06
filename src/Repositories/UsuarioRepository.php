<?php

declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Usuario;
use PDO;

class UsuarioRepository implements RepositoryInterface
{
    private PDO $db;
    private RolRepository $rolRepository;

    public function __construct()
    {
        $this->db = Database::getConnection();
        $this->rolRepository = new RolRepository();
    }

    private function hydrate(array $row): Usuario
    {
        $rol = $this->rolRepository->findById((int)$row['id_rol']);

        $usuario = new Usuario(
            (int)$row['id_usuario'],
            $row['nombre_usuario'],
            $row['email'],
            'temporal', // contraseña temporal para no romper la lógica
            $rol
        );

        // Reemplazar hash sin regenerar
        $ref = new \ReflectionClass($usuario);
        $property = $ref->getProperty('password');
        $property->setAccessible(true);
        $property->setValue($usuario, $row['password']);

        return $usuario;
    }

    public function findAll(): array
    {
        $stmt = $this->db->query('CALL sp_usuario_list();');
        $rows = $stmt->fetchAll();
        $stmt->closeCursor();

        $usuarios = [];
        foreach ($rows as $r) {
            $usuarios[] = $this->hydrate($r);
        }
        return $usuarios;
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Usuario) {
            throw new \InvalidArgumentException('Expected instance of Usuario');
        }

        $stmt = $this->db->prepare('CALL sp_create_usuario(:nombre_usuario, :email, :password, :id_rol);');
        $ok = $stmt->execute([
            ':nombre_usuario' => $entity->getNombreUsuario(),
            ':email' => $entity->getEmail(),
            ':password' => $entity->getPassword(),
            ':id_rol' => $entity->getRol()->getId()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Usuario) {
            throw new \InvalidArgumentException('Expected instance of Usuario');
        }

        $stmt = $this->db->prepare('CALL sp_update_usuario(:id_usuario, :nombre_usuario, :email, :password, :id_rol);');
        $ok = $stmt->execute([
            ':id_usuario' => $entity->getId(),
            ':nombre_usuario' => $entity->getNombreUsuario(),
            ':email' => $entity->getEmail(),
            ':password' => $entity->getPassword(),
            ':id_rol' => $entity->getRol()->getId()
        ]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function delete(int $id): bool
    {
        $stmt = $this->db->prepare('CALL sp_delete_usuario(:id_usuario);');
        $ok = $stmt->execute([':id_usuario' => $id]);

        if (!$ok) {
            $ok->fetchAll();
        }
        $stmt->closeCursor();
        return $ok;
    }

    public function findById(int $id): ?object
    {
        $stmt = $this->db->prepare('CALL sp_usuario_find_by_id(:id_usuario);');
        $stmt->execute([':id_usuario' => $id]);
        $row = $stmt->fetch();
        $stmt->closeCursor();

        return $row ? $this->hydrate($row) : null;
    }
}
