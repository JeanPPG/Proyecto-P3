<?php
declare(strict_types=1);

namespace App\Entities;

class Usuario
{
    private int $id;
    private string $username;
    private string $passwordHash;
    private string $estado; // ACTIVO | INACTIVO | BLOQUEADO

    public function __construct(
        int $id = 0,
        string $username = '',
        string $passwordHash = '',
        string $estado = 'ACTIVO'
    ) {
        $this->id = $id;
        $this->username = $username;
        $this->passwordHash = $passwordHash;
        $this->estado = $estado;
    }

    public function getId(): int { return $this->id; }
    public function setId(int $id): void { $this->id = $id; }

    public function getUsername(): string { return $this->username; }
    public function setUsername(string $username): void { $this->username = $username; }

    public function getPasswordHash(): string { return $this->passwordHash; }
    public function setPasswordHash(string $passwordHash): void { $this->passwordHash = $passwordHash; }

    public function getEstado(): string { return $this->estado; }
    public function setEstado(string $estado): void { $this->estado = $estado; }
}
