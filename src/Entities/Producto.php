<?php declare(strict_types=1);

namespace App\Entities;

abstract class Producto
{
    protected static int $autoIncrementId = 1;

    protected int $id;
    protected string $nombre;
    protected string $descripcion;
    protected float $precioUnitario;
    protected int $stock;
    protected int $idCategoria;

    public function __construct(
        ?int $id,
        string $nombre,
        string $descripcion,
        float $precioUnitario,
        int $stock,
        int $idCategoria
    ) {
        $this->id             = $id ?? self::$autoIncrementId++;
        $this->setNombre($nombre);
        $this->setDescripcion($descripcion);
        $this->setPrecioUnitario($precioUnitario);
        $this->setStock($stock);
        $this->setIdCategoria($idCategoria);
    }

    // Getters
    public function getId(): int                      
    { 
        return $this->id; 
    }
    public function getNombre(): string               
    { 
        return $this->nombre; 
    }
    public function getDescripcion(): string          
    { 
        return $this->descripcion; 
    }
    public function getPrecioUnitario(): float        
    { 
        return $this->precioUnitario; 
    }
    public function getStock(): int                   
    { 
        return $this->stock; 
    }
    public function getIdCategoria(): int             
    { 
        return $this->idCategoria; 
    }

    // Setters con validaciones
    public function setId(int $id): void
    {
        if ($id <= 0) {
            throw new \InvalidArgumentException("El ID debe ser mayor que cero.");
        }
        $this->id = $id;
    }

    public function setNombre(string $nombre): void
    {
        if (trim($nombre) === '') {
            throw new \InvalidArgumentException("El nombre no puede estar vacío.");
        }
        $this->nombre = $nombre;
    }

    public function setDescripcion(string $descripcion): void
    {
        if (trim($descripcion) === '') {
            throw new \InvalidArgumentException("La descripción no puede estar vacía.");
        }
        $this->descripcion = $descripcion;
    }

    public function setPrecioUnitario(float $precio): void
    {
        if ($precio < 0) {
            throw new \InvalidArgumentException("El precio unitario no puede ser negativo.");
        }
        $this->precioUnitario = round($precio, 2);
    }

    public function setStock(int $stock): void
    {
        if ($stock < 0) {
            throw new \InvalidArgumentException("El stock no puede ser negativo.");
        }
        $this->stock = $stock;
    }

    public function setIdCategoria(int $idCategoria): void
    {
        if ($idCategoria <= 0) {
            throw new \InvalidArgumentException("El ID de categoría debe ser mayor que cero.");
        }
        $this->idCategoria = $idCategoria;
    }

    // Método abstracto
    abstract public function getTipo(): string;
}
