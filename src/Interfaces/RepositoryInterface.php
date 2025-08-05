<?php
declare(strict_types=1);

namespace App\Interfaces;

interface RepositoryInterface
{
    /**
     * Inserta un nuevo registro en la base de datos.
     * 
     * @param object $entity Instancia de la entidad a persistir
     * @return int ID generado (si aplica) o 0 si falla
     */
    public function create(object $entity): int;

    /**
     * Obtiene un registro por su ID.
     * 
     * @param int $id Identificador primario
     * @return object|null Retorna la entidad o null si no existe
     */
    public function findById(int $id): ?object;

    /**
     * Obtiene todos los registros de la tabla.
     * 
     * @return array<object> Lista de entidades
     */
    public function findAll(): array;

    /**
     * Actualiza un registro existente.
     * 
     * @param object $entity Instancia con los datos modificados
     * @return bool True si la operación fue exitosa
     */
    public function update(object $entity): bool;

    /**
     * Elimina un registro por su ID.
     * 
     * @param int $id Identificador primario
     * @return bool True si la operación fue exitosa
     */
    public function delete(int $id): bool;
}
