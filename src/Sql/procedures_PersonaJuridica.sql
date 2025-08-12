-- Active: 1752793151268@@127.0.0.1@3306@p3_db
DELIMITER //

DROP PROCEDURE IF EXISTS sp_persona_juridica_list;
CREATE PROCEDURE sp_persona_juridica_list()
BEGIN
    SELECT
        pj.id,
        pj.razonSocial,
        pj.ruc,
        pj.representanteLegal,
        c.email,
        c.telefono,
        c.direccion,
        c.tipo 
    FROM personajuridica pj
    INNER JOIN cliente c ON pj.id = c.id
    ORDER BY pj.ruc;
END;


DROP PROCEDURE IF EXISTS sp_create_persona_juridica;

CREATE PROCEDURE sp_create_persona_juridica(
    IN pj_email VARCHAR(255),
    IN pj_telefono VARCHAR(20),
    IN pj_direccion VARCHAR(255),
    IN pj_razonSocial VARCHAR(255),
    IN pj_ruc VARCHAR(13),
    IN pj_representanteLegal VARCHAR(255)
)
BEGIN
    DECLARE v_new_cli_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    IF EXISTS (SELECT 1 FROM Cliente WHERE email = pj_email) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email ya registrado';
    END IF;
    IF EXISTS (SELECT 1 FROM PersonaJuridica WHERE ruc = pj_ruc) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RUC ya registrado';
    END IF;

    START TRANSACTION;

    INSERT INTO Cliente (email, telefono, direccion, tipo) 
    VALUES (pj_email, pj_telefono, pj_direccion, 'JURIDICA');

    SET v_new_cli_id = LAST_INSERT_ID();

    INSERT INTO PersonaJuridica (razonSocial, ruc, representanteLegal, id) 
    VALUES (pj_razonSocial, pj_ruc, pj_representanteLegal, v_new_cli_id);    

    COMMIT;

    SELECT v_new_cli_id AS cli_id;
END;

DROP PROCEDURE IF EXISTS sp_update_persona_juridica;
CREATE PROCEDURE sp_update_persona_juridica(
    IN p_id INT,
    IN p_email VARCHAR(255),
    IN p_telefono VARCHAR(20),
    IN p_direccion VARCHAR(255),
    IN p_razonSocial VARCHAR(255),
    IN p_ruc VARCHAR(13),
    IN p_representanteLegal VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;   -- <<-- Propaga el error para que lo veas
    END;

    -- 1) Validar existencia y tipo
    IF NOT EXISTS (
        SELECT 1
        FROM PersonaJuridica pj
        JOIN Cliente c ON pj.id = c.id
        WHERE pj.id = p_id AND c.tipo = 'JURIDICA'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Persona Jurídica no encontrada o tipo inválido';
    END IF;

    -- 2) Unicidad de RUC (permitiendo el propio registro)
    IF EXISTS (
        SELECT 1 FROM PersonaJuridica
        WHERE ruc = p_ruc AND id <> p_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'RUC ya registrado';
    END IF;

    -- 3) Unicidad de email en Cliente (permitiendo el propio registro)
    IF EXISTS (
        SELECT 1 FROM Cliente
        WHERE email = p_email AND id <> p_id
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email ya registrado';
    END IF;

    START TRANSACTION;

    UPDATE Cliente
       SET telefono  = p_telefono,
           direccion = p_direccion,
           email     = p_email
     WHERE id = p_id;

    UPDATE PersonaJuridica
       SET razonSocial         = p_razonSocial,
           ruc                 = p_ruc,
           representanteLegal  = p_representanteLegal
     WHERE id = p_id;

    COMMIT;
END;

DROP PROCEDURE IF EXISTS sp_delete_persona_juridica;

CREATE PROCEDURE sp_delete_persona_juridica(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM PersonaJuridica pj
        JOIN Cliente c ON pj.id = c.id
        WHERE pj.id = p_id AND c.tipo = 'JURIDICA'
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Persona Jurídica no encontrada o tipo inválido';
    END IF;

    START TRANSACTION;

    DELETE FROM PersonaJuridica WHERE id = p_id;
    DELETE FROM Cliente WHERE id = p_id;

    COMMIT;
END;

DROP PROCEDURE IF EXISTS sp_find_persona_juridica;

CREATE PROCEDURE sp_find_persona_juridica(IN p_id INT)
BEGIN
    SELECT
        pj.id,
        pj.razonSocial,
        pj.ruc,
        pj.representanteLegal,
        c.email,
        c.telefono,
        c.direccion
    FROM
        Cliente c
    JOIN
        PersonaJuridica pj ON c.id = pj.id
    WHERE
        pj.id = p_id ;
END;

DELIMITER ;


-- PRUEBAS
CALL sp_persona_juridica_list();

CALL sp_create_persona_juridica('kfc@example.com', '123456743', 'Direccion 123', 'Razon Social', '1234567890222', 'KFC');
CALL sp_update_persona_juridica(
  9,
  'cnt@example.com',
  '123456743',
  'Direccion 123',
  'CNT',
  '1234567890222',
  'CNT'
);

CALL sp_delete_persona_juridica(9);

CALL sp_find_persona_juridica(9);