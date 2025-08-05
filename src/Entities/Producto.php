<?php
namespace App\Entities;

abstract class Producto
{
    protected int $id;
    protected string $nombre;
    protected ?string $descripcion;
    protected float $precioUnitario;
    protected int $stock;
    protected int $idCategoria;

    public function __construct(
        int $id = 0,
        string $nombre = '',
        ?string $descripcion = null,
        float $precioUnitario = 0,
        int $stock = 0,
        int $idCategoria = 0
    ) {
        $this->id = $id;
        $this->nombre = $nombre;
        $this->descripcion = $descripcion;
        $this->precioUnitario = $precioUnitario;
        $this->stock = $stock;
        $this->idCategoria = $idCategoria;
    }

    // Getters y Setters
    public function getId(): int { return $this->id; }
    public function setId(int $id): void { $this->id = $id; }

    public function getNombre(): string { return $this->nombre; }
    public function setNombre(string $nombre): void { $this->nombre = $nombre; }

    public function getDescripcion(): ?string { return $this->descripcion; }
    public function setDescripcion(?string $descripcion): void { $this->descripcion = $descripcion; }

    public function getPrecioUnitario(): float { return $this->precioUnitario; }
    public function setPrecioUnitario(float $precio): void { $this->precioUnitario = $precio; }

    public function getStock(): int { return $this->stock; }
    public function setStock(int $stock): void { $this->stock = $stock; }

    public function getIdCategoria(): int { return $this->idCategoria; }
    public function setIdCategoria(int $idCategoria): void { $this->idCategoria = $idCategoria; }
}
