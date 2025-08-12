-- =========================================================
-- LISTAR USUARIOS
-- =========================================================
DROP PROCEDURE IF EXISTS sp_usuario_list;
DELIMITER //

CREATE PROCEDURE sp_usuario_list()
BEGIN
    SELECT id, username, estado
    FROM Usuario
    ORDER BY username;
END //
//
DELIMITER ;

-- =========================================================
-- BUSCAR POR ID
-- =========================================================
DROP PROCEDURE IF EXISTS sp_find_usuario;
DELIMITER //

CREATE PROCEDURE sp_find_usuario(IN p_id INT)
BEGIN
    SELECT id, username, estado
    FROM Usuario
    WHERE id = p_id;
END //
//
DELIMITER ;

-- =========================================================
-- CREAR USUARIO (passwordHash = Argon2id DESDE APP)
-- estado: 'ACTIVO' | 'INACTIVO' | 'BLOQUEADO'
-- =========================================================
DROP PROCEDURE IF EXISTS sp_create_usuario;
DELIMITER //

CREATE PROCEDURE sp_create_usuario(
    IN p_username     VARCHAR(50),
    IN p_passwordHash VARCHAR(100),
    IN p_estado       ENUM('ACTIVO','INACTIVO','BLOQUEADO')
)
BEGIN
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;

    IF p_estado NOT IN ('ACTIVO','INACTIVO','BLOQUEADO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estado inválido';
    END IF;

    IF EXISTS (SELECT 1 FROM Usuario WHERE username=p_username) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Username ya existe';
    END IF;

    START TRANSACTION;

    INSERT INTO Usuario (username, passwordHash, estado)
    VALUES (p_username, p_passwordHash, p_estado);

    SET v_new_id = LAST_INSERT_ID();

    COMMIT;
    SELECT v_new_id AS usuario_id;
END //
//
DELIMITER ;

-- =========================================================
-- ACTUALIZAR USUARIO (sin cambiar contraseña)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_update_usuario;
DELIMITER //

CREATE PROCEDURE sp_update_usuario(
    IN p_id           INT,
    IN p_username     VARCHAR(50),
    IN p_estado       ENUM('ACTIVO','INACTIVO','BLOQUEADO')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id=p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario no existe';
    END IF;

    IF p_estado NOT IN ('ACTIVO','INACTIVO','BLOQUEADO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estado inválido';
    END IF;

    IF EXISTS (SELECT 1 FROM Usuario WHERE username=p_username AND id<>p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Username ya en uso';
    END IF;

    START TRANSACTION;

    UPDATE Usuario
       SET username = p_username,
           estado   = p_estado
     WHERE id = p_id;

    COMMIT;
    SELECT 1 AS ok;
END //
//
DELIMITER ;

-- =========================================================
-- CAMBIAR CONTRASEÑA (recibe hash Argon2id)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_usuario_set_password;
DELIMITER //

CREATE PROCEDURE sp_usuario_set_password(
    IN p_id           INT,
    IN p_passwordHash VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id=p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario no existe';
    END IF;

    START TRANSACTION;

    UPDATE Usuario
       SET passwordHash = p_passwordHash
     WHERE id = p_id;

    COMMIT;
    SELECT 1 AS ok;
END //
//
DELIMITER ;

-- =========================================================
-- BLOQUEAR / ACTIVAR / INACTIVAR
-- =========================================================
DROP PROCEDURE IF EXISTS sp_usuario_set_estado;
DELIMITER //

CREATE PROCEDURE sp_usuario_set_estado(
    IN p_id     INT,
    IN p_estado ENUM('ACTIVO','INACTIVO','BLOQUEADO')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id=p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario no existe';
    END IF;

    IF p_estado NOT IN ('ACTIVO','INACTIVO','BLOQUEADO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estado inválido';
    END IF;

    START TRANSACTION;

    UPDATE Usuario
       SET estado = p_estado
     WHERE id = p_id;

    COMMIT;
    SELECT 1 AS ok;
END //
//
DELIMITER ;
