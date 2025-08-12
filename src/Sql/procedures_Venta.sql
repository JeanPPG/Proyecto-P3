-- =========================================================
-- 1) LISTAR VENTAS (con info básica del cliente)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_venta_list;
DELIMITER //

CREATE PROCEDURE sp_venta_list()
BEGIN
    SELECT
        v.id,
        v.fecha,
        v.idCliente,
        v.total,
        v.estado,
        -- Cliente: nombre mostrado (razón social o nombre completo) + email
        COALESCE(pj.razonSocial, CONCAT(pn.nombres,' ',pn.apellidos))  AS cliente_nombre,
        c.email AS cliente_email
    FROM Venta v
    JOIN Cliente c ON c.id = v.idCliente
    LEFT JOIN PersonaNatural  pn ON pn.id = c.id
    LEFT JOIN PersonaJuridica pj ON pj.id = c.id
    ORDER BY v.fecha DESC, v.id DESC;
END //
//
DELIMITER ;

-- =========================================================
-- 2) BUSCAR VENTA POR ID (cabecera + detalles)
--     Devuelve 2 resultsets: Header y Detalles
-- =========================================================
DROP PROCEDURE IF EXISTS sp_find_venta;
DELIMITER //

CREATE PROCEDURE sp_find_venta(IN p_id INT)
BEGIN
    -- Header
    SELECT
        v.id, v.fecha, v.idCliente, v.total, v.estado,
        COALESCE(pj.razonSocial, CONCAT(pn.nombres,' ',pn.apellidos))  AS cliente_nombre,
        c.email AS cliente_email, c.telefono, c.direccion
    FROM Venta v
    JOIN Cliente c ON c.id = v.idCliente
    LEFT JOIN PersonaNatural  pn ON pn.id = c.id
    LEFT JOIN PersonaJuridica pj ON pj.id = c.id
    WHERE v.id = p_id;

    -- Detalles
    SELECT
        d.idVenta, d.lineNumber, d.idProducto, p.nombre,
        d.cantidad, d.precioUnitario, d.subtotal
    FROM DetalleVenta d
    JOIN Producto p ON p.id = d.idProducto
    WHERE d.idVenta = p_id
    ORDER BY d.lineNumber;
END //
//
DELIMITER ;

-- =========================================================
-- 3) CREAR VENTA (estado inicial BORRADOR, total en 0.00)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_create_venta;
DELIMITER //

CREATE PROCEDURE sp_create_venta(IN p_idCliente INT)
BEGIN
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id = p_idCliente) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente no existe';
    END IF;

    START TRANSACTION;
    INSERT INTO Venta (idCliente, total, estado) VALUES (p_idCliente, 0.00, 'BORRADOR');
    SET v_new_id = LAST_INSERT_ID();
    COMMIT;

    SELECT v_new_id AS venta_id;
END //
//
DELIMITER ;

-- =========================================================
-- 4) AGREGAR DETALLE A VENTA
--    - Solo permite cuando la venta está en BORRADOR
--    - Autonumera lineNumber (MAX+1)
--    - Si p_precioUnitario es NULL, usa Producto.precioUnitario
--    - Recalcula total de la venta
-- =========================================================
DROP PROCEDURE IF EXISTS sp_venta_add_detalle;
DELIMITER //

CREATE PROCEDURE sp_venta_add_detalle(
    IN p_idVenta INT,
    IN p_idProducto INT,
    IN p_cantidad INT,
    IN p_precioUnitario DECIMAL(12,2)  -- puede ser NULL
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

    -- Validaciones básicas
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

    -- Tomar precio del producto si no viene
    IF p_precioUnitario IS NULL THEN
        SELECT precioUnitario INTO v_precio FROM Producto WHERE id = p_idProducto;
    ELSE
        SET v_precio = p_precioUnitario;
    END IF;

    START TRANSACTION;

    -- lineNumber siguiente
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

    -- Devolver el detalle insertado y el header
    SELECT * FROM DetalleVenta WHERE idVenta = p_idVenta AND lineNumber = v_next_line;
    SELECT id, fecha, idCliente, total, estado FROM Venta WHERE id = p_idVenta;
END //
//
DELIMITER ;

-- =========================================================
-- 5) RECALCULAR TOTAL (por si cambiaste detalles)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_venta_recalcular_total;
DELIMITER //

CREATE PROCEDURE sp_venta_recalcular_total(IN p_idVenta INT)
BEGIN
    DECLARE v_estado VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Venta WHERE id = p_idVenta) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venta no existe';
    END IF;

    START TRANSACTION;

    UPDATE Venta v
    LEFT JOIN (
        SELECT idVenta, SUM(subtotal) AS s
        FROM DetalleVenta
        WHERE idVenta = p_idVenta
        GROUP BY idVenta
    ) t ON t.idVenta = v.id
    SET v.total = COALESCE(t.s, 0.00)
    WHERE v.id = p_idVenta;

    COMMIT;

    SELECT id, fecha, idCliente, total, estado FROM Venta WHERE id = p_idVenta;
END //
//
DELIMITER ;

-- =========================================================
-- 6) CAMBIAR CLIENTE/ESTADO (con validaciones)
--    - Solo permite EMITIR si hay detalles (>0) y total > 0
--    - ANULAR: solo cambia estado (no re-stock aquí; opcional implementarlo)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_venta_update_header;
DELIMITER //

CREATE PROCEDURE sp_venta_update_header(
    IN p_idVenta INT,
    IN p_idCliente INT,
    IN p_estado ENUM('BORRADOR','EMITIDA','ANULADA')
)
BEGIN
    DECLARE v_total DECIMAL(12,2);
    DECLARE v_cnt INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Venta WHERE id = p_idVenta) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venta no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE id = p_idCliente) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente no existe';
    END IF;

    -- Reglas de estado
    SELECT COALESCE(SUM(1),0) INTO v_cnt FROM DetalleVenta WHERE idVenta = p_idVenta;
    SELECT total INTO v_total FROM Venta WHERE id = p_idVenta;

    IF p_estado = 'EMITIDA' AND (v_cnt = 0 OR v_total <= 0) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No puedes EMITIR sin detalles o con total <= 0';
    END IF;

    START TRANSACTION;

    UPDATE Venta
       SET idCliente = p_idCliente,
           estado    = p_estado
     WHERE id = p_idVenta;

    COMMIT;

    SELECT id, fecha, idCliente, total, estado FROM Venta WHERE id = p_idVenta;
END //
//
DELIMITER ;

-- =========================================================
-- 7) ELIMINAR VENTA
--     (DetalleVenta se borra por ON DELETE CASCADE; Factura también)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_delete_venta;
DELIMITER //

CREATE PROCEDURE sp_delete_venta(IN p_idVenta INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Venta WHERE id = p_idVenta) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venta no existe';
    END IF;

    START TRANSACTION;
    DELETE FROM Venta WHERE id = p_idVenta;
    COMMIT;

    SELECT 1 AS ok;
END //
//
DELIMITER ;


CALL sp_venta_recalcular_total(1);
