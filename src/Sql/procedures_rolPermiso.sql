/* =========================================================
   ROL-PERMISO – asignación / consulta
   ========================================================= */

-- Lista de permisos por rol
DROP PROCEDURE IF EXISTS sp_rol_permisos;
DELIMITER //

CREATE PROCEDURE sp_rol_permisos(IN p_idRol INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Rol WHERE id = p_idRol) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rol no existe';
    END IF;

    SELECT p.id, p.codigo
    FROM RolPermiso rp
    JOIN Permiso p ON p.id = rp.idPermiso
    WHERE rp.idRol = p_idRol
    ORDER BY p.codigo;
END //
//
DELIMITER ;

------------------------------------------------------------

-- Lista de roles que tienen un permiso
DROP PROCEDURE IF EXISTS sp_permiso_roles;
DELIMITER //

CREATE PROCEDURE sp_permiso_roles(IN p_idPermiso INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Permiso WHERE id = p_idPermiso) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Permiso no existe';
    END IF;

    SELECT r.id, r.nombre
    FROM RolPermiso rp
    JOIN Rol r ON r.id = rp.idRol
    WHERE rp.idPermiso = p_idPermiso
    ORDER BY r.nombre;
END //
//
DELIMITER ;

------------------------------------------------------------

-- Asignar permiso a rol
DROP PROCEDURE IF EXISTS sp_rol_add_permiso;
DELIMITER //

CREATE PROCEDURE sp_rol_add_permiso(
    IN p_idRol INT,
    IN p_idPermiso INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; RESIGNAL; END;

    IF NOT EXISTS (SELECT 1 FROM Rol WHERE id = p_idRol) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rol no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Permiso WHERE id = p_idPermiso) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Permiso no existe';
    END IF;

    IF EXISTS (
        SELECT 1 FROM RolPermiso
        WHERE idRol = p_idRol AND idPermiso = p_idPermiso
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El rol ya tiene ese permiso';
    END IF;

    START TRANSACTION;

    INSERT INTO RolPermiso (idRol, idPermiso)
    VALUES (p_idRol, p_idPermiso);

    COMMIT;
    SELECT 1 AS ok;
END //
//
DELIMITER ;

------------------------------------------------------------

-- Quitar permiso de rol
DROP PROCEDURE IF EXISTS sp_rol_remove_permiso;
DELIMITER //

CREATE PROCEDURE sp_rol_remove_permiso(
    IN p_idRol INT,
    IN p_idPermiso INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; RESIGNAL; END;

    IF NOT EXISTS (SELECT 1 FROM Rol WHERE id = p_idRol) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rol no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Permiso WHERE id = p_idPermiso) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Permiso no existe';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM RolPermiso
        WHERE idRol = p_idRol AND idPermiso = p_idPermiso
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El rol no tiene ese permiso';
    END IF;

    START TRANSACTION;

    DELETE FROM RolPermiso
     WHERE idRol = p_idRol AND idPermiso = p_idPermiso;

    COMMIT;
    SELECT 1 AS ok;
END //
//
DELIMITER ;

------------------------------------------------------------

-- (Opcional) Matriz Rol x Permiso
DROP PROCEDURE IF EXISTS sp_rol_permiso_matrix;
DELIMITER //

CREATE PROCEDURE sp_rol_permiso_matrix()
BEGIN
    SELECT 
        r.id   AS rol_id,
        r.nombre AS rol_nombre,
        p.id   AS permiso_id,
        p.codigo AS permiso_codigo
    FROM Rol r
    LEFT JOIN RolPermiso rp ON rp.idRol = r.id
    LEFT JOIN Permiso p     ON p.id = rp.idPermiso
    ORDER BY r.nombre, p.codigo;
END //
//
DELIMITER ;
