<?php

declare(strict_types=1);

namespace App\Entities;

class PersonaJuridica extends Cliente {
    private string $razonSocial;
    private string $ruc;
    private ?string $representanteLegal;

    public function __construct(int $id, string $email, string $telefono, string $direccion, string $tipo, string $razonSocial, string $ruc, ?string $representanteLegal = null) {
        parent::__construct($id, $email, $telefono, $direccion);
        $this->razonSocial = $razonSocial;
        $this->ruc = $ruc;
        $this->representanteLegal = $representanteLegal;
    }

    public function getRazonSocial(): string {
        return $this->razonSocial;
    }

    public function getRuc(): string {
        return $this->ruc;
    }

    public function getRepresentanteLegal(): ?string {
        return $this->representanteLegal;
    }

    public function setRazonSocial(string $razonSocial): void {
        if (trim($razonSocial) === '') {
            throw new \InvalidArgumentException('La razón social no puede estar vacía.');
        }
        $this->razonSocial = $razonSocial;
    }

    public function setRuc(string $ruc): void {
        $ruc = trim($ruc);
        if (strlen($ruc) !== 13 || !ctype_digit($ruc)) {
            throw new \InvalidArgumentException('El RUC debe tener 13 dígitos numéricos.');
        }

        $prov = (int)substr($ruc, 0, 2);
        if ($prov < 1 || $prov > 24) {
            throw new \InvalidArgumentException('Provincia inválida en el RUC.');
        }

        $tercer = (int)$ruc[2];
        // Jurídicas: pública (6) o privada (9)
        if (!in_array($tercer, [6, 9], true)) {
            throw new \InvalidArgumentException('Para persona jurídica, el RUC debe tener tercer dígito 6 (pública) o 9 (privada).');
        }

        // (Opcional) Validar sufijo establecimiento '001'
        if (substr($ruc, 10, 3) !== '001') {
            throw new \InvalidArgumentException('El RUC debe terminar en 001 para el establecimiento principal.');
        }

        $this->ruc = $ruc;
    }


    public function setRepresentanteLegal(?string $representanteLegal): void {
        if ($representanteLegal !== null && trim($representanteLegal) === '') {
            throw new \InvalidArgumentException('El representante legal no puede estar vacío.');
        }
        $this->representanteLegal = $representanteLegal;
    }


}