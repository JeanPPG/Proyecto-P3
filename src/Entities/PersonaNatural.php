<?php

declare(strict_types=1);

namespace App\Entities;



class PersonaNatural extends Cliente {
    private string $nombres;
    private string $apellidos;
    private string $cedula;


    public function __construct(int $id, string $email, string $telefono, string $direccion, string $tipo, string $nombres, string $apellidos, string $cedula) {
        parent::__construct($id, $email, $telefono, $direccion);
        $this->nombres = $nombres;
        $this->apellidos = $apellidos;
        $this->cedula = $cedula;
    }

    public function getNombres(): string {
        return $this->nombres;
    }
    public function getApellidos(): string {
        return $this->apellidos;
    }
    public function getCedula(): string {
        return $this->cedula;
    }

    public function setNombres(string $nombres): void {
        if (trim($nombres) === '') {
            throw new \InvalidArgumentException('Los nombres no pueden estar vacíos.');
        }
        $this->nombres = $nombres;
    }
    public function setApellidos(string $apellidos): void {
        if (trim($apellidos) === '') {
            throw new \InvalidArgumentException('Los apellidos no pueden estar vacíos.');
        }
        $this->apellidos = $apellidos;
    }
    public function setCedula(string $cedula): void {
        // Debe tener exactamente 10 dígitos numéricos
        if (strlen($cedula) !== 10 || !ctype_digit($cedula)) {
            throw new \InvalidArgumentException('La cédula debe tener 10 dígitos numéricos.');
        }

        // Región: dos primeros dígitos entre 01 y 24
        $region = (int) substr($cedula, 0, 2);
        if ($region < 1 || $region > 24) {
            throw new \InvalidArgumentException('Cédula con región inválida.');
        }

        $digits = str_split($cedula);
        $ultimo = (int) $digits[9];

        // Suma de los dígitos en posiciones pares (1,3,5,7 en índice 1,3,5,7)
        $pares = (int)$digits[1] + (int)$digits[3] + (int)$digits[5] + (int)$digits[7];

        // Suma de los dígitos en posiciones impares (0,2,4,6,8) aplicando *2 y -9 si >9
        $imparesSum = 0;
        for ($i = 0; $i <= 8; $i += 2) {
            $val = (int)$digits[$i] * 2;
            if ($val > 9) {
                $val -= 9;
            }
            $imparesSum += $val;
        }

        $sumaTotal = $pares + $imparesSum;

        // Obtenemos la decena inmediata superior
        $decena = (int) (ceil($sumaTotal / 10) * 10);

        // Dígito validador
        $validador = $decena - $sumaTotal;
        if ($validador === 10) {
            $validador = 0;
        }

        if ($validador !== $ultimo) {
            throw new \InvalidArgumentException('Cédula inválida según algoritmo de validación.');
        }

        $this->cedula = $cedula;
    }
}