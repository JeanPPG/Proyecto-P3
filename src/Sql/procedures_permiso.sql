/* =========================================================
   PERMISO – CRUD
   ========================================================= */

DROP PROCEDURE IF EXISTS sp_permiso_list;
DELIMITER //

CREATE PROCEDURE sp_permiso_list()
BEGIN
    SELECT id, codigo
    FROM Permiso
    ORDER BY codigo;
END //
//
DELIMITER ;

------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_find_permiso;
DELIMITER //

CREATE PROCEDURE sp_find_permiso(IN p_id INT)
BEGIN
    SELECT id, codigo
    FROM Permiso
    WHERE id = p_id;
END //
//
DELIMITER ;

------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_create_permiso;
DELIMITER //

CREATE PROCEDURE sp_create_permiso(IN p_codigo VARCHAR(100))
BEGIN
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; RESIGNAL; END;

    IF p_codigo IS NULL OR LENGTH(TRIM(p_codigo)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Código de permiso requerido';
    END IF;

    IF EXISTS (SELECT 1 FROM Permiso WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El código de permiso ya existe';
    END IF;

    START TRANSACTION;

    INSERT INTO Permiso (codigo) VALUES (TRIM(p_codigo));
    SET v_new_id = LAST_INSERT_ID();

    COMMIT;
    SELECT v_new_id AS permiso_id;
END //
//
DELIMITER ;

------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_update_permiso;
DELIMITER //

CREATE PROCEDURE sp_update_permiso(
    IN p_id INT,
    IN p_codigo VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; RESIGNAL; END;

    IF NOT EXISTS (SELECT 1 FROM Permiso WHERE id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Permiso no existe';
    END IF;

    IF p_codigo IS NULL OR LENGTH(TRIM(p_codigo)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Código de permiso requerido';
    END IF;

    IF EXISTS (SELECT 1 FROM Permiso WHERE codigo = p_codigo AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El código de permiso ya existe';
    END IF;

    START TRANSACTION;

    UPDATE Permiso
       SET codigo = TRIM(p_codigo)
     WHERE id = p_id;

    COMMIT;
    SELECT 1 AS ok;
END //
//
DELIMITER ;

------------------------------------------------------------

DROP PROCEDURE IF EXISTS sp_delete_permiso;
DELIMITER //

CREATE PROCEDURE sp_delete_permiso(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; RESIGNAL; END;

    IF NOT EXISTS (SELECT 1 FROM Permiso WHERE id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Permiso no existe';
    END IF;

    -- Si hay FKs con ON DELETE CASCADE en RolPermiso, se eliminarán solos.
    START TRANSACTION;
    DELETE FROM Permiso WHERE id = p_id;
    COMMIT;

    SELECT 1 AS ok;
END //
//
DELIMITER ;
