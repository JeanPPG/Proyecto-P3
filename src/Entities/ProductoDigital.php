<?php

declare(strict_types=1);

namespace App\Entities;

class ProductoDigital extends Producto
{
    private string $urlDescarga;
    private ?string $licencia;

    public function __construct(
        int $id = 0,
        string $nombre = '',
        ?string $descripcion = null,
        float $precioUnitario = 0,
        int $stock = 0,
        int $idCategoria = 0,
        string $urlDescarga = '',
        ?string $licencia = null
    ) {
        parent::__construct($id, $nombre, $descripcion, $precioUnitario, $stock, $idCategoria);
        $this->urlDescarga = $urlDescarga;
        $this->licencia = $licencia;
    }

    public function getUrlDescarga(): string { return $this->urlDescarga; }
    public function setUrlDescarga(string $urlDescarga): void { $this->urlDescarga = $urlDescarga; }

    public function getLicencia(): ?string { return $this->licencia; }
    public function setLicencia(?string $licencia): void { $this->licencia = $licencia; }
}
