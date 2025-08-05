<?php

declare(strict_types=1);

namespace App\Entities;


class ProductoFisico extends Producto
{
    private ?float $peso;
    private ?float $alto;
    private ?float $ancho;
    private ?float $profundidad;

    public function __construct(
        int $id = 0,
        string $nombre = '',
        ?string $descripcion = null,
        float $precioUnitario = 0,
        int $stock = 0,
        int $idCategoria = 0,
        ?float $peso = null,
        ?float $alto = null,
        ?float $ancho = null,
        ?float $profundidad = null
    ) {
        parent::__construct($id, $nombre, $descripcion, $precioUnitario, $stock, $idCategoria);
        $this->peso = $peso;
        $this->alto = $alto;
        $this->ancho = $ancho;
        $this->profundidad = $profundidad;
    }

    // Getters y Setters
    public function getPeso(): ?float { return $this->peso; }
    public function setPeso(?float $peso): void { $this->peso = $peso; }

    public function getAlto(): ?float { return $this->alto; }
    public function setAlto(?float $alto): void { $this->alto = $alto; }

    public function getAncho(): ?float { return $this->ancho; }
    public function setAncho(?float $ancho): void { $this->ancho = $ancho; }

    public function getProfundidad(): ?float { return $this->profundidad; }
    public function setProfundidad(?float $profundidad): void { $this->profundidad = $profundidad; }
}
