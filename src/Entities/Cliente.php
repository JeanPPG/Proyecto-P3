<?php

declare(strict_types=1);

namespace App\Entities;

Abstract class Cliente {
    private int $id;
    private string $email;
    private string $telefono;
    private string $direccion;

    public function __construct (int $id, string $email, string $telefono, string $direccion) {
        $this->id = $id;
        $this->email = $email;
        $this->telefono = $telefono;
        $this->direccion = $direccion;
    }

    public function getId(): int {
        return $this->id;
    }
    public function getEmail(): string {
        return $this->email;
    }
    public function getTelefono(): string {
        return $this->telefono;
    }
    public function getDireccion(): string {
        return $this->direccion;
    }
    
    public function setId(int $id): void {
        if ($id <= 0) {
            throw new \InvalidArgumentException("El ID debe ser mayor que cero.");
        }
        $this->id = $id;
    }
    public function setEmail(string $email): void {
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            throw new \InvalidArgumentException('Email inválido: ' . $email);
        }
        $this->email = $email;
    }
    public function setTelefono(string $telefono): void {
        $this->telefono = $telefono;
    }
    public function setDireccion(string $direccion): void {
        $this->direccion = $direccion;
    }
    
}

