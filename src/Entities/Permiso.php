<?php
declare(strict_types=1);

namespace App\Entities;

class Permiso
{
    private int $id;
    private string $codigo;

    public function __construct(int $id = 0, string $codigo = '')
    {
        $this->id = $id;
        $this->codigo = $codigo;
    }

    public function getId(): int { return $this->id; }
    public function setId(int $id): void { $this->id = $id; }

    public function getCodigo(): string { return $this->codigo; }
    public function setCodigo(string $codigo): void { $this->codigo = $codigo; }
}
