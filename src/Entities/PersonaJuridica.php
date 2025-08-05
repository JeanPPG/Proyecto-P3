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
        // Debe tener 13 dígitos numéricos
        if (strlen($ruc) !== 13 || !ctype_digit($ruc)) {
            throw new \InvalidArgumentException('El RUC debe tener 13 dígitos numéricos.');
        }

        // Provincia: dos primeros dígitos entre 01 y 24
        $prov = (int) substr($ruc, 0, 2);
        if ($prov < 1 || $prov > 24) {
            throw new \InvalidArgumentException('RUC con provincia inválida.');
        }

        // Tercer dígito: 9 = sociedad privada
        $tercer = (int) $ruc[2];
        if ($tercer !== 9) {
            throw new \InvalidArgumentException('RUC de persona jurídica debe tener tercer dígito = 9.');
        }

        // Los tres últimos dígitos (establecimiento) no pueden ser 000
        if (substr($ruc, 10, 3) === '000') {
            throw new \InvalidArgumentException('Los tres últimos dígitos del RUC no pueden ser 000.');
        }

        // Cálculo módulo 11 con coeficientes para personas privadas:
        $coef = [4, 3, 2, 7, 6, 5, 4, 3, 2];
        $suma = 0;
        for ($i = 0; $i < 9; $i++) {
            $suma += (int)$ruc[$i] * $coef[$i];
        }
        $res = $suma % 11;
        $digVer = ($res === 0) ? 0 : (11 - $res);
        if ($digVer === 10) {
            $digVer = 0;
        }

        // Comparamos con el dígito verificador (posición 10, índice 9)
        if ($digVer !== (int)$ruc[9]) {
            throw new \InvalidArgumentException('RUC inválido según algoritmo Módulo 11.');
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