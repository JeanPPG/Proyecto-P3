<?php
declare(strict_types=1);

namespace App\Entities;

class Venta
{
    private int $id;
    private \DateTime $fecha;
    private int $idCliente;
    private float $total;
    private string $estado; // BORRADOR | EMITIDA | ANULADA

    public function __construct(
        int $id = 0,
        ?\DateTime $fecha = null,
        int $idCliente = 0,
        float $total = 0.0,
        string $estado = 'BORRADOR'
    ) {
        $this->id = $id;
        $this->fecha = $fecha ?? new \DateTime();
        $this->idCliente = $idCliente;
        $this->total = $total;
        $this->estado = $estado;
    }

    // Getters y Setters
    public function getId(): int { return $this->id; }
    public function setId(int $id): void { $this->id = $id; }

    public function getFecha(): \DateTime { return $this->fecha; }
    public function setFecha(\DateTime $fecha): void { $this->fecha = $fecha; }

    public function getIdCliente(): int { return $this->idCliente; }
    public function setIdCliente(int $idCliente): void { $this->idCliente = $idCliente; }

    public function getTotal(): float { return $this->total; }
    public function setTotal(float $total): void { $this->total = $total; }

    public function getEstado(): string { return $this->estado; }
    public function setEstado(string $estado): void { $this->estado = $estado; }
}
