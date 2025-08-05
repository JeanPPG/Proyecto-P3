<?php
declare(strict_types=1);

namespace App\Entities;

class Factura
{
    private int $id;
    private int $idVenta;
    private string $numero;
    private string $claveAcceso;
    private \DateTime $fechaEmision;
    private string $estado; // PENDIENTE | ENVIADA | ANULADA

    public function __construct(
        int $id = 0,
        int $idVenta = 0,
        string $numero = '',
        string $claveAcceso = '',
        ?\DateTime $fechaEmision = null,
        string $estado = 'PENDIENTE'
    ) {
        $this->id = $id;
        $this->idVenta = $idVenta;
        $this->numero = $numero;
        $this->claveAcceso = $claveAcceso;
        $this->fechaEmision = $fechaEmision ?? new \DateTime();
        $this->estado = $estado;
    }

    public function getId(): int { return $this->id; }
    public function setId(int $id): void { $this->id = $id; }

    public function getIdVenta(): int { return $this->idVenta; }
    public function setIdVenta(int $idVenta): void { $this->idVenta = $idVenta; }

    public function getNumero(): string { return $this->numero; }
    public function setNumero(string $numero): void { $this->numero = $numero; }

    public function getClaveAcceso(): string { return $this->claveAcceso; }
    public function setClaveAcceso(string $claveAcceso): void { $this->claveAcceso = $claveAcceso; }

    public function getFechaEmision(): \DateTime { return $this->fechaEmision; }
    public function setFechaEmision(\DateTime $fechaEmision): void { $this->fechaEmision = $fechaEmision; }

    public function getEstado(): string { return $this->estado; }
    public function setEstado(string $estado): void { $this->estado = $estado; }
}
