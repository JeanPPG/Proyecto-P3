<?php
declare(strict_types=1);

namespace App\Repositories;

use App\Interfaces\RepositoryInterface;
use App\Config\Database;
use App\Entities\Usuario;
use PDO;
use PDOException;

class UsuarioRepository implements RepositoryInterface
{
    private PDO $db;

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    private function hydrate(array $row): Usuario
    {
        return new Usuario(
            (int)$row['id'],
            (string)$row['username'],
            (string)($row['passwordHash'] ?? ''), 
            (string)$row['estado']
        );
    }

    public function findAll(): array
    {
        try {
            $stmt = $this->db->query('CALL sp_usuario_list()');
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            $out = [];
            foreach ($rows as $r) {
                $out[] = new Usuario(
                    (int)$r['id'],
                    (string)$r['username'],
                    '',                          
                    (string)$r['estado']
                );
            }
            return $out;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar usuarios: '.$e->getMessage(), 0, $e);
        }
    }

    public function findById(int $id): ?object
    {
        try {
            $stmt = $this->db->prepare('CALL sp_find_usuario(?)');
            $stmt->execute([$id]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            if (!$row) return null;

            $username = (string)$row['username'];
            $estado   = (string)$row['estado'];
            $hash     = isset($row['passwordHash']) ? (string)$row['passwordHash'] : '';

            return new Usuario($id, $username, $hash, $estado);
        } catch (PDOException $e) {
            if (stripos($e->getMessage(), 'sp_find_usuario') !== false) {
                $stmt = $this->db->prepare('CALL sp_usuario_find_by_id(?)');
                $stmt->execute([$id]);
                $row = $stmt->fetch(PDO::FETCH_ASSOC);
                $stmt->closeCursor();
                return $row
                    ? new Usuario(
                        (int)$row['id'],
                        (string)$row['username'],
                        isset($row['passwordHash']) ? (string)$row['passwordHash'] : '',
                        (string)$row['estado']
                      )
                    : null;
            }
            throw new \RuntimeException('Error al buscar usuario: '.$e->getMessage(), 0, $e);
        }
    }

    public function create(object $entity): bool
    {
        if (!$entity instanceof Usuario) {
            throw new \InvalidArgumentException('Expected instance of Usuario');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_create_usuario(?, ?, ?)');
            $ok = $stmt->execute([
                $entity->getUsername(),
                $entity->getPasswordHash(),
                $entity->getEstado()
            ]);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al crear usuario: '.$e->getMessage(), 0, $e);
        }
    }

    public function update(object $entity): bool
    {
        if (!$entity instanceof Usuario) {
            throw new \InvalidArgumentException('Expected instance of Usuario');
        }

        try {
            $stmt = $this->db->prepare('CALL sp_update_usuario(?, ?, ?)');
            $ok = $stmt->execute([
                $entity->getId(),
                $entity->getUsername(),
                $entity->getEstado()
            ]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al actualizar usuario: '.$e->getMessage(), 0, $e);
        }
    }

    public function delete(int $id): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_usuario_set_estado(?, ?)');
            $ok = $stmt->execute([$id, 'INACTIVO']);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al desactivar usuario: '.$e->getMessage(), 0, $e);
        }
    }

    public function setPassword(int $id, string $passwordHash): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_usuario_set_password(?, ?)');
            $ok = $stmt->execute([$id, $passwordHash]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al cambiar contraseña: '.$e->getMessage(), 0, $e);
        }
    }

    public function setEstado(int $id, string $estado): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_usuario_set_estado(?, ?)');
            $ok = $stmt->execute([$id, $estado]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al cambiar estado: '.$e->getMessage(), 0, $e);
        }
    }


    public function assignRole(int $usuarioId, int $rolId): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_usuario_assign_role(?, ?)');
            $ok = $stmt->execute([$usuarioId, $rolId]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al asignar rol: '.$e->getMessage(), 0, $e);
        }
    }

    public function removeRole(int $usuarioId, int $rolId): bool
    {
        try {
            $stmt = $this->db->prepare('CALL sp_usuario_remove_role(?, ?)');
            $ok = $stmt->execute([$usuarioId, $rolId]);
            $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return (bool)$ok;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al quitar rol: '.$e->getMessage(), 0, $e);
        }
    }

    public function rolesOf(int $usuarioId): array
    {
        try {
            $stmt = $this->db->prepare('CALL sp_usuario_roles(?)');
            $stmt->execute([$usuarioId]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();
            return $rows;
        } catch (PDOException $e) {
            throw new \RuntimeException('Error al listar roles del usuario: '.$e->getMessage(), 0, $e);
        }
    }
}
