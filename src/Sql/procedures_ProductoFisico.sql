
DROP PROCEDURE IF EXISTS sp_producto_fisico_list;
DELIMITER //

CREATE PROCEDURE sp_producto_fisico_list()
BEGIN
    SELECT
        p.id,
        p.nombre,
        p.descripcion,
        p.precioUnitario,
        p.stock,
        p.idCategoria,
        p.tipo,
        pf.peso,
        pf.alto,
        pf.ancho,
        pf.profundidad
    FROM ProductoFisico pf
    JOIN Producto p ON pf.id = p.id
    ORDER BY p.nombre;
END //
//
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_find_producto_fisico;
DELIMITER //

CREATE PROCEDURE sp_find_producto_fisico(IN p_id INT)
BEGIN
    SELECT
        p.id,
        p.nombre,
        p.descripcion,
        p.precioUnitario,
        p.stock,
        p.idCategoria,
        p.tipo,
        pf.peso,
        pf.alto,
        pf.ancho,
        pf.profundidad
    FROM ProductoFisico pf
    JOIN Producto p ON pf.id = p.id
    WHERE p.id = p_id;
END //
//
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_create_producto_fisico;
DELIMITER //

CREATE PROCEDURE sp_create_producto_fisico(
    IN p_nombre         VARCHAR(150),
    IN p_descripcion    TEXT,
    IN p_precioUnitario DECIMAL(12,2),
    IN p_stock          INT,
    IN p_idCategoria    INT,
    IN p_peso           DECIMAL(8,2),
    IN p_alto           DECIMAL(8,2),
    IN p_ancho          DECIMAL(8,2),
    IN p_profundidad    DECIMAL(8,2)
)
BEGIN
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO Producto (nombre, descripcion, precioUnitario, stock, idCategoria, tipo)
    VALUES (p_nombre, p_descripcion, p_precioUnitario, p_stock, p_idCategoria, 'FISICO');

    SET v_new_id = LAST_INSERT_ID();

    INSERT INTO ProductoFisico (id, peso, alto, ancho, profundidad)
    VALUES (v_new_id, p_peso, p_alto, p_ancho, p_profundidad);

    COMMIT;

    SELECT v_new_id AS producto_id;
END //
//
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_update_producto_fisico;
DELIMITER //

CREATE PROCEDURE sp_update_producto_fisico(
    IN p_id            INT,
    IN p_nombre        VARCHAR(150),
    IN p_descripcion   TEXT,
    IN p_precioUnitario DECIMAL(12,2),
    IN p_stock         INT,
    IN p_idCategoria   INT,
    IN p_peso          DECIMAL(8,2),
    IN p_alto          DECIMAL(8,2),
    IN p_ancho         DECIMAL(8,2),
    IN p_profundidad   DECIMAL(8,2)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM Producto p
        JOIN ProductoFisico pf ON pf.id = p.id
        WHERE p.id = p_id AND p.tipo = 'FISICO'
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Producto físico no encontrado (o tipo distinto de FISICO)';
    END IF;

    START TRANSACTION;

    UPDATE Producto
       SET nombre         = p_nombre,
           descripcion    = p_descripcion,
           precioUnitario = p_precioUnitario,
           stock          = p_stock,
           idCategoria    = p_idCategoria
     WHERE id = p_id;

    UPDATE ProductoFisico
       SET peso        = p_peso,
           alto        = p_alto,
           ancho       = p_ancho,
           profundidad = p_profundidad
     WHERE id = p_id;

    COMMIT;
END //
//
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_delete_producto_fisico;
DELIMITER //

CREATE PROCEDURE sp_delete_producto_fisico(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Producto p WHERE p.id = p_id AND p.tipo = 'FISICO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto físico no encontrado';
    END IF;

    START TRANSACTION;
    DELETE FROM Producto WHERE id = p_id;
    COMMIT;
END //
//
DELIMITER ;

CALL sp_producto_fisico_list();
CALL sp_find_producto_fisico(1);
CALL sp_create_producto_fisico('Nuevo Producto Físico', 'Descripción del nuevo producto físico', 29.99, 100, 1, 1.5, 10.0, 5.0, 3.0);
CALL sp_update_producto_fisico(6, 'Producto Físico Actualizado', 'Descripción actualizada', 39.99, 150, 2, 2.0, 12.0, 6.0, 4.0);
CALL sp_delete_producto_fisico(6);