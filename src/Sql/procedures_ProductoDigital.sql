DELIMITER //

DROP PROCEDURE IF EXISTS sp_producto_digital_list;
CREATE PROCEDURE sp_producto_digital_list()
BEGIN
    SELECT
        p.id,
        p.nombre,
        p.descripcion,
        p.precioUnitario,
        p.stock,
        p.idCategoria,
        p.tipo,
        pd.urlDescarga,
        pd.licencia
    FROM ProductoDigital pd
    JOIN Producto p ON pd.id = p.id
    ORDER BY p.nombre;
END ;

DROP PROCEDURE IF EXISTS sp_find_producto_digital;

CREATE PROCEDURE sp_find_producto_digital(IN p_id INT)
BEGIN
    SELECT
        p.id,
        p.nombre,
        p.descripcion,
        p.precioUnitario,
        p.stock,
        p.idCategoria,
        p.tipo,
        pd.urlDescarga,
        pd.licencia
    FROM ProductoDigital pd
    JOIN Producto p ON pd.id = p.id
    WHERE p.id = p_id;
END ;

DROP PROCEDURE IF EXISTS sp_create_producto_digital;

CREATE PROCEDURE sp_create_producto_digital(
    IN p_nombre VARCHAR(150),
    IN p_descripcion TEXT,
    IN p_precioUnitario DECIMAL(12,2),
    IN p_stock INT,
    IN p_idCategoria INT,
    IN p_urlDescarga VARCHAR(255),
    IN p_licencia VARCHAR(100)
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
    VALUES (p_nombre, p_descripcion, p_precioUnitario, p_stock, p_idCategoria, 'DIGITAL');

    SET v_new_id = LAST_INSERT_ID();

    INSERT INTO ProductoDigital (id, urlDescarga, licencia)
    VALUES (v_new_id, p_urlDescarga, p_licencia);

    COMMIT;

    SELECT v_new_id AS producto_id;
END ;
                
DROP PROCEDURE IF EXISTS sp_update_producto_digital;
CREATE PROCEDURE sp_update_producto_digital(
    IN p_id INT,
    IN p_nombre VARCHAR(150),
    IN p_descripcion TEXT,
    IN p_precioUnitario DECIMAL(12,2),
    IN p_stock INT,
    IN p_idCategoria INT,
    IN p_urlDescarga VARCHAR(255),
    IN p_licencia VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM ProductoDigital WHERE id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto Digital no encontrado';
    END IF;

    START TRANSACTION;

    UPDATE Producto
    SET nombre        = p_nombre,
        descripcion   = p_descripcion,
        precioUnitario= p_precioUnitario,
        stock         = p_stock,
        idCategoria   = p_idCategoria
    WHERE id = p_id;

    UPDATE ProductoDigital
    SET urlDescarga = p_urlDescarga,
        licencia    = p_licencia
    WHERE id = p_id;

    COMMIT;
END ;

DROP PROCEDURE IF EXISTS sp_delete_producto_digital;
CREATE PROCEDURE sp_delete_producto_digital(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM ProductoDigital WHERE id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto Digital no encontrado';
    END IF;

    START TRANSACTION;
    -- Si tu FK tiene ON DELETE CASCADE, basta con borrar en Producto
    DELETE FROM Producto WHERE id = p_id;
    COMMIT;
END ;


CALL sp_producto_digital_list();
CALL sp_find_producto_digital(3);
CALL sp_create_producto_digital('Nuevo Producto', 'Descripción del nuevo producto', 19.99, 100, 1, 'http://ejemplo.com/descarga', 'Licencia del producto');
CALL sp_update_producto_digital(5, 'Producto Actualizado', 'Descripción actualizada', 29.99, 150, 2, 'http://ejemplo.com/descarga_actualizada', 'Licencia actualizada');
CALL sp_delete_producto_digital(5);