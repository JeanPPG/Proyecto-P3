-- Active: 1752793151268@@127.0.0.1@3306@p3_db
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_persona_natural_list$$

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


DROP PROCEDURE IF EXISTS sp_create_persona_natural$$

CREATE PROCEDURE sp_create_persona_natural(
    IN c_email VARCHAR(100),
    IN c_telefono VARCHAR(10),
    IN c_direccion VARCHAR(255),
    IN c_nombres VARCHAR(100),
    IN c_apellidos VARCHAR(100),
    IN c_cedula VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO cliente (
        email,
        telefono,
        direccion,
        tipo
    ) VALUES (
        c_email,
        c_telefono,
        c_direccion,
        'NATURAL'
    );

    SET @new_cli_id = LAST_INSERT_ID();

    INSERT INTO personanatural (
        cliente_id,
        nombres,
        apellidos,
        cedula
    ) VALUES (
        @new_cli_id,
        c_nombres,
        c_apellidos,
        c_cedula
    );
    COMMIT;

    SELECT @new_cli_id AS cli_id;
END;



DELIMITER ;


CALL sp_persona_natural_list();

CALL sp_create_persona_natural(
    'test@example.com',
    '1234567890',
    '123 Main St',
    'John',
    'Doe',
    'V-12345678'
);