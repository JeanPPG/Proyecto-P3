-- =========================================================
-- LISTAR ROLES
-- =========================================================
DROP PROCEDURE IF EXISTS sp_rol_list;
DELIMITER //

CREATE PROCEDURE sp_rol_list()
BEGIN
    SELECT id, nombre FROM Rol ORDER BY nombre;
END //
//
DELIMITER ;

-- =========================================================
-- ASIGNAR ROL A USUARIO
-- =========================================================
DROP PROCEDURE IF EXISTS sp_usuario_assign_role;
DELIMITER //

CREATE PROCEDURE sp_usuario_assign_role(
    IN p_usuario_id INT,
    IN p_rol_id     INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id=p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Rol WHERE id=p_rol_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rol no existe';
    END IF;

    IF EXISTS (SELECT 1 FROM UsuarioRol WHERE usuario_id=p_usuario_id AND rol_id=p_rol_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario ya tiene ese rol';
    END IF;

    START TRANSACTION;

    INSERT INTO UsuarioRol (usuario_id, rol_id)
    VALUES (p_usuario_id, p_rol_id);

    COMMIT;
    SELECT 1 AS ok;
END //
//
DELIMITER ;

-- =========================================================
-- QUITAR ROL A USUARIO
-- =========================================================
DROP PROCEDURE IF EXISTS sp_usuario_remove_role;
DELIMITER //

CREATE PROCEDURE sp_usuario_remove_role(
    IN p_usuario_id INT,
    IN p_rol_id     INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id=p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM UsuarioRol WHERE usuario_id=p_usuario_id AND rol_id=p_rol_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El usuario no tiene ese rol';
    END IF;

    START TRANSACTION;

    DELETE FROM UsuarioRol
     WHERE usuario_id=p_usuario_id AND rol_id=p_rol_id;

    COMMIT;
    SELECT 1 AS ok;
END //
//
DELIMITER ;

-- =========================================================
-- LISTAR ROLES DE UN USUARIO
-- =========================================================
DROP PROCEDURE IF EXISTS sp_usuario_roles;
DELIMITER //

CREATE PROCEDURE sp_usuario_roles(IN p_usuario_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id=p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario no existe';
    END IF;

    SELECT r.id, r.nombre
    FROM UsuarioRol ur
    JOIN Rol r ON r.id = ur.rol_id
    WHERE ur.usuario_id = p_usuario_id
    ORDER BY r.nombre;
END //
//
DELIMITER ;
