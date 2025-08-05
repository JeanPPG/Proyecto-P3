<?php
declare(strict_types=1);

namespace App\Entities;

class DetalleVenta
{
    private int $idVenta;
    private int $lineNumber;
    private int $idProducto;
    private int $cantidad;
    private float $precioUnitario;

    public function __construct(
        int $idVenta = 0,
        int $lineNumber = 0,
        int $idProducto = 0,
        int $cantidad = 0,
        float $precioUnitario = 0.0
    ) {
        $this->idVenta = $idVenta;
        $this->lineNumber = $lineNumber;
        $this->idProducto = $idProducto;
        $this->cantidad = $cantidad;
        $this->precioUnitario = $precioUnitario;
    }

    public function getIdVenta(): int { return $this->idVenta; }
    public function setIdVenta(int $idVenta): void { $this->idVenta = $idVenta; }

    public function getLineNumber(): int { return $this->lineNumber; }
    public function setLineNumber(int $lineNumber): void { $this->lineNumber = $lineNumber; }

    public function getIdProducto(): int { return $this->idProducto; }
    public function setIdProducto(int $idProducto): void { $this->idProducto = $idProducto; }

    public function getCantidad(): int { return $this->cantidad; }
    public function setCantidad(int $cantidad): void { $this->cantidad = $cantidad; }

    public function getPrecioUnitario(): float { return $this->precioUnitario; }
    public function setPrecioUnitario(float $precioUnitario): void { $this->precioUnitario = $precioUnitario; }

    public function getSubtotal(): float { return $this->cantidad * $this->precioUnitario; }
}
