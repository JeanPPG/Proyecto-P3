-- =========================================
-- LISTAR DETALLES DE UNA VENTA
-- =========================================
DROP PROCEDURE IF EXISTS sp_detalle_venta_list;
DELIMITER //

CREATE PROCEDURE sp_detalle_venta_list(IN p_idVenta INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Venta WHERE id = p_idVenta) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venta no existe';
    END IF;

    SELECT
        d.idVenta, d.lineNumber, d.idProducto, p.nombre,
        d.cantidad, d.precioUnitario, d.subtotal
    FROM DetalleVenta d
    JOIN Producto p ON p.id = d.idProducto
    WHERE d.idVenta = p_idVenta
    ORDER BY d.lineNumber;
END //
//
DELIMITER ;

-- =========================================
-- BUSCAR UNA LÍNEA (POR PK COMPUESTA)
-- =========================================
DROP PROCEDURE IF EXISTS sp_find_detalle_venta;
DELIMITER //

CREATE PROCEDURE sp_find_detalle_venta(IN p_idVenta INT, IN p_lineNumber INT)
BEGIN
    SELECT
        d.idVenta, d.lineNumber, d.idProducto, p.nombre,
        d.cantidad, d.precioUnitario, d.subtotal
    FROM DetalleVenta d
    JOIN Producto p ON p.id = d.idProducto
    WHERE d.idVenta = p_idVenta AND d.lineNumber = p_lineNumber;
END //
//
DELIMITER ;

-- =========================================
-- AGREGAR LÍNEA
-- - Solo BORRADOR
-- - Autonumera lineNumber (MAX+1)
-- - Si p_precioUnitario es NULL, usa Producto.precioUnitario
-- - Recalcula total de la venta
-- =========================================
DROP PROCEDURE IF EXISTS sp_detalle_venta_add;
DELIMITER //

CREATE PROCEDURE sp_detalle_venta_add(
    IN p_idVenta INT,
    IN p_idProducto INT,
    IN p_cantidad INT,
    IN p_precioUnitario DECIMAL(12,2) -- puede ser NULL
)
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_precio DECIMAL(12,2);
    DECLARE v_next_line INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad inválida';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Venta WHERE id = p_idVenta) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venta no existe';
    END IF;

    SELECT estado INTO v_estado FROM Venta WHERE id = p_idVenta;
    IF v_estado <> 'BORRADOR' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se puede modificar una venta en BORRADOR';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = p_idProducto) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe';
    END IF;

    IF p_precioUnitario IS NULL THEN
        SELECT precioUnitario INTO v_precio FROM Producto WHERE id = p_idProducto;
    ELSE
        SET v_precio = p_precioUnitario;
    END IF;

    START TRANSACTION;

    SELECT COALESCE(MAX(lineNumber)+1, 1)
      INTO v_next_line
      FROM DetalleVenta
     WHERE idVenta = p_idVenta;

    INSERT INTO DetalleVenta (idVenta, lineNumber, idProducto, cantidad, precioUnitario)
    VALUES (p_idVenta, v_next_line, p_idProducto, p_cantidad, v_precio);

    -- Recalcular total
    UPDATE Venta v
    JOIN (
        SELECT idVenta, SUM(subtotal) AS s
          FROM DetalleVenta
         WHERE idVenta = p_idVenta
         GROUP BY idVenta
    ) t ON t.idVenta = v.id
       SET v.total = t.s
     WHERE v.id = p_idVenta;

    COMMIT;

    SELECT * FROM DetalleVenta WHERE idVenta = p_idVenta AND lineNumber = v_next_line;
END //
//
DELIMITER ;

-- =========================================
-- ACTUALIZAR LÍNEA
-- - Solo BORRADOR
-- - Permite cambiar cantidad, precio y/o producto
-- - Recalcula total
-- =========================================
DROP PROCEDURE IF EXISTS sp_detalle_venta_update;
DELIMITER //

CREATE PROCEDURE sp_detalle_venta_update(
    IN p_idVenta INT,
    IN p_lineNumber INT,
    IN p_idProducto INT,
    IN p_cantidad INT,
    IN p_precioUnitario DECIMAL(12,2) -- puede ser NULL para tomar precio de Producto
)
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_precio DECIMAL(12,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM DetalleVenta WHERE idVenta = p_idVenta AND lineNumber = p_lineNumber) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Detalle no existe';
    END IF;

    SELECT estado INTO v_estado FROM Venta WHERE id = p_idVenta;
    IF v_estado <> 'BORRADOR' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se puede modificar una venta en BORRADOR';
    END IF;

    IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cantidad inválida';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Producto WHERE id = p_idProducto) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto no existe';
    END IF;

    IF p_precioUnitario IS NULL THEN
        SELECT precioUnitario INTO v_precio FROM Producto WHERE id = p_idProducto;
    ELSE
        SET v_precio = p_precioUnitario;
    END IF;

    START TRANSACTION;

    UPDATE DetalleVenta
       SET idProducto    = p_idProducto,
           cantidad      = p_cantidad,
           precioUnitario= v_precio
     WHERE idVenta = p_idVenta AND lineNumber = p_lineNumber;

    UPDATE Venta v
    LEFT JOIN (
        SELECT idVenta, SUM(subtotal) AS s
          FROM DetalleVenta
         WHERE idVenta = p_idVenta
         GROUP BY idVenta
    ) t ON t.idVenta = v.id
       SET v.total = COALESCE(t.s,0.00)
     WHERE v.id = p_idVenta;

    COMMIT;

    SELECT * FROM DetalleVenta WHERE idVenta = p_idVenta AND lineNumber = p_lineNumber;
END //
//
DELIMITER ;

-- =========================================
-- ELIMINAR LÍNEA
-- - Solo BORRADOR
-- - Recalcula total
-- =========================================
DROP PROCEDURE IF EXISTS sp_detalle_venta_delete;
DELIMITER //

CREATE PROCEDURE sp_detalle_venta_delete(
    IN p_idVenta INT,
    IN p_lineNumber INT
)
BEGIN
    DECLARE v_estado VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM DetalleVenta WHERE idVenta = p_idVenta AND lineNumber = p_lineNumber) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Detalle no existe';
    END IF;

    SELECT estado INTO v_estado FROM Venta WHERE id = p_idVenta;
    IF v_estado <> 'BORRADOR' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se puede modificar una venta en BORRADOR';
    END IF;

    START TRANSACTION;

    DELETE FROM DetalleVenta
     WHERE idVenta = p_idVenta AND lineNumber = p_lineNumber;

    UPDATE Venta v
    LEFT JOIN (
        SELECT idVenta, SUM(subtotal) AS s
          FROM DetalleVenta
         WHERE idVenta = p_idVenta
         GROUP BY idVenta
    ) t ON t.idVenta = v.id
       SET v.total = COALESCE(t.s,0.00)
     WHERE v.id = p_idVenta;

    COMMIT;

    SELECT id, fecha, idCliente, total, estado FROM Venta WHERE id = p_idVenta;
END //
//
DELIMITER ;


CALL sp_detalle_venta_list(1);