-- Active: 1752793151268@@127.0.0.1@3306@p3_db
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_persona_natural_list;

CREATE PROCEDURE sp_persona_natural_list()
BEGIN
    SELECT 
        pn.id,
        pn.nombres,
        pn.apellidos,
        pn.cedula,
        c.email,
        c.telefono,
        c.direccion,
        c.tipo
    FROM PersonaNatural pn
    INNER JOIN Cliente c ON pn.id = c.id
    ORDER BY pn.apellidos, pn.nombres;
END;


DROP PROCEDURE IF EXISTS sp_create_persona_natural;

CREATE PROCEDURE sp_create_persona_natural(
    IN p_email      VARCHAR(255),
    IN p_telefono   VARCHAR(20),
    IN p_direccion  VARCHAR(255),
    IN p_nombres    VARCHAR(100),
    IN p_apellidos  VARCHAR(100),
    IN p_cedula     VARCHAR(10)
)
BEGIN
    DECLARE v_new_cli_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF EXISTS (SELECT 1 FROM Cliente WHERE email = p_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email ya registrado';
    END IF;

    IF EXISTS (SELECT 1 FROM PersonaNatural WHERE cedula = p_cedula) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cédula ya registrada';
    END IF;

    START TRANSACTION;

    INSERT INTO Cliente (email, telefono, direccion, tipo)
    VALUES (p_email, p_telefono, p_direccion, 'NATURAL');

    SET v_new_cli_id = LAST_INSERT_ID();

    INSERT INTO PersonaNatural (id, nombres, apellidos, cedula)
    VALUES (v_new_cli_id, p_nombres, p_apellidos, p_cedula);

    COMMIT;

    SELECT v_new_cli_id AS cli_id;
END;

DROP PROCEDURE IF EXISTS sp_update_persona_natural;
CREATE PROCEDURE sp_update_persona_natural(
    IN p_id         INT,
    IN p_telefono   VARCHAR(20),
    IN p_direccion  VARCHAR(255),
    IN p_nombres    VARCHAR(100),
    IN p_apellidos  VARCHAR(100),
    IN p_cedula     VARCHAR(10)
)
BEGIN
    DECLARE v_rows_cli INT DEFAULT 0;
    DECLARE v_rows_pn  INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- 1) Validar existencia y tipo NATURAL, y que la cédula no esté en otro
    IF NOT EXISTS (
        SELECT 1
        FROM PersonaNatural pn
        JOIN Cliente c ON c.id = pn.id
        WHERE pn.id = p_id AND c.tipo = 'NATURAL'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe PersonaNatural con ese id (o el cliente no es NATURAL)';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM PersonaNatural
        WHERE cedula = p_cedula AND id <> p_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cédula ya registrada en otra persona';
    END IF;

    START TRANSACTION;

    -- 2) Update Cliente (afectará 0 filas si los valores son iguales)
    UPDATE Cliente
       SET telefono  = p_telefono,
           direccion = p_direccion
     WHERE id = p_id;
    SET v_rows_cli = ROW_COUNT();

    -- 3) Update PersonaNatural
    UPDATE PersonaNatural
       SET nombres   = p_nombres,
           apellidos = p_apellidos,
           cedula    = p_cedula
     WHERE id = p_id;
    SET v_rows_pn = ROW_COUNT();

    COMMIT;

    -- 4) Devolver diagnóstico y el registro final
    SELECT 
        v_rows_cli  AS rows_cliente,
        v_rows_pn   AS rows_persona_natural;

    SELECT 
        pn.id, pn.nombres, pn.apellidos, pn.cedula,
        c.email, c.telefono, c.direccion, c.tipo
    FROM PersonaNatural pn
    JOIN Cliente c ON c.id = pn.id
    WHERE pn.id = p_id;
END;

DROP PROCEDURE IF EXISTS sp_delete_persona_natural;

CREATE PROCEDURE sp_delete_persona_natural(IN p_id INT)
BEGIN
    DECLARE v_rows_cli INT DEFAULT 0;
    DECLARE v_rows_pn  INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM PersonaNatural pn
        JOIN Cliente c ON c.id = pn.id
        WHERE pn.id = p_id AND c.tipo = 'NATURAL'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe PersonaNatural con ese id (o el cliente no es NATURAL)';
    END IF;

    START TRANSACTION;

    DELETE FROM PersonaNatural WHERE id = p_id;
    SET v_rows_pn = ROW_COUNT();

    DELETE FROM Cliente WHERE id = p_id;
    SET v_rows_cli = ROW_COUNT();

    COMMIT;

    SELECT 
        v_rows_cli  AS rows_cliente,
        v_rows_pn   AS rows_persona_natural;
END;

DROP PROCEDURE IF EXISTS sp_find_persona_natural;
CREATE PROCEDURE sp_find_persona_natural(IN p_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PersonaNatural WHERE id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PersonaNatural no encontrada';
    END IF;

    SELECT 
        pn.id, pn.nombres, pn.apellidos, pn.cedula,
        c.email, c.telefono, c.direccion, c.tipo
    FROM PersonaNatural pn
    JOIN Cliente c ON c.id = pn.id
    WHERE pn.id = p_id;
END;

DELIMITER ;


CALL sp_persona_natural_list();

CALL sp_create_persona_natural(
  'nuevo.usuario@example.com',
  '0991112233',
  'Av. Central 999',
  'Luis',
  'Ramírez Torres',
  '1109988776'
);


CALL sp_update_persona_natural(
  7,                -- p_id (debe existir en PersonaNatural)
  '0995556677',     -- telefono
  'Calle 10 y Av. 5',
  'Carlos',
  'Paez Flores',
  '1109988776'      -- cédula (no debe estar en otra persona)
);

CALL sp_delete_persona_natural(7);

CALL sp_find_persona_natural(1);