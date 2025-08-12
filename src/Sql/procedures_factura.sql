-- =========================================================
-- 1) LISTAR FACTURAS (con info del cliente y venta)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_factura_list;
DELIMITER //

CREATE PROCEDURE sp_factura_list()
BEGIN
    SELECT
        f.id,
        f.idVenta,
        f.numero,
        f.claveAcceso,
        f.fechaEmision,
        f.estado,
        v.total,
        COALESCE(pj.razonSocial, CONCAT(pn.nombres,' ',pn.apellidos)) AS cliente_nombre,
        c.email AS cliente_email
    FROM Factura f
    JOIN Venta v   ON v.id = f.idVenta
    JOIN Cliente c ON c.id = v.idCliente
    LEFT JOIN PersonaNatural  pn ON pn.id = c.id
    LEFT JOIN PersonaJuridica pj ON pj.id = c.id
    ORDER BY f.fechaEmision DESC, f.id DESC;
END //
//
DELIMITER ;

-- =========================================================
-- 2) BUSCAR POR ID
-- =========================================================
DROP PROCEDURE IF EXISTS sp_find_factura;
DELIMITER //

CREATE PROCEDURE sp_find_factura(IN p_id INT)
BEGIN
    SELECT
        f.id,
        f.idVenta,
        f.numero,
        f.claveAcceso,
        f.fechaEmision,
        f.estado,
        v.total,
        COALESCE(pj.razonSocial, CONCAT(pn.nombres,' ',pn.apellidos)) AS cliente_nombre,
        c.email AS cliente_email, c.telefono, c.direccion
    FROM Factura f
    JOIN Venta v   ON v.id = f.idVenta
    JOIN Cliente c ON c.id = v.idCliente
    LEFT JOIN PersonaNatural  pn ON pn.id = c.id
    LEFT JOIN PersonaJuridica pj ON pj.id = c.id
    WHERE f.id = p_id;
END //
//
DELIMITER ;

-- (Opcional) Buscar por número
DROP PROCEDURE IF EXISTS sp_find_factura_by_numero;
DELIMITER //

CREATE PROCEDURE sp_find_factura_by_numero(IN p_numero VARCHAR(50))
BEGIN
    SELECT f.* FROM Factura f WHERE f.numero = p_numero;
END //
//
DELIMITER ;

-- =========================================================
-- 3) CREAR FACTURA
--    Requisitos: venta existe, estado = EMITIDA, tiene detalles y total > 0,
--    esa venta NO tiene factura previa, numero y claveAcceso únicos.
--    La integración con SRI la hace tu backend antes o después;
--    aquí asumimos que ya tienes numero/clave (o los pones provisionales).
-- =========================================================
DROP PROCEDURE IF EXISTS sp_factura_create;
DELIMITER //

CREATE PROCEDURE sp_factura_create(
    IN p_idVenta INT,
    IN p_numero VARCHAR(50),
    IN p_claveAcceso VARCHAR(100)
)
BEGIN
    DECLARE v_estado VARCHAR(20);
    DECLARE v_total DECIMAL(12,2);
    DECLARE v_cnt INT;
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Venta válida
    IF NOT EXISTS (SELECT 1 FROM Venta WHERE id = p_idVenta) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venta no existe';
    END IF;

    SELECT estado, total INTO v_estado, v_total FROM Venta WHERE id = p_idVenta;
    IF v_estado <> 'EMITIDA' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se factura una venta EMITIDA';
    END IF;

    SELECT COUNT(*) INTO v_cnt FROM DetalleVenta WHERE idVenta = p_idVenta;
    IF v_cnt = 0 OR v_total <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venta sin detalles o total <= 0';
    END IF;

    -- Única por venta
    IF EXISTS (SELECT 1 FROM Factura WHERE idVenta = p_idVenta) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta ya tiene factura';
    END IF;

    -- Unicidad de número/clave
    IF EXISTS (SELECT 1 FROM Factura WHERE numero = p_numero) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Número de factura ya existe';
    END IF;
    IF EXISTS (SELECT 1 FROM Factura WHERE claveAcceso = p_claveAcceso) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Clave de acceso ya existe';
    END IF;

    START TRANSACTION;

    INSERT INTO Factura (idVenta, numero, claveAcceso, estado)
    VALUES (p_idVenta, p_numero, p_claveAcceso, 'PENDIENTE');

    SET v_new_id = LAST_INSERT_ID();

    COMMIT;

    SELECT v_new_id AS factura_id;
END //
//
DELIMITER ;

-- =========================================================
-- 4) MARCAR ENVIADA (post SRI)
--    Tu backend llama al SRI, obtiene autorización y luego
--    actualiza estado a ENVIADA. (Opcional: refrescar clave/numero)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_factura_mark_enviada;
DELIMITER //

CREATE PROCEDURE sp_factura_mark_enviada(
    IN p_id INT,
    IN p_numero VARCHAR(50),         -- permite actualizar si cambió
    IN p_claveAcceso VARCHAR(100)    -- idem
)
BEGIN
    DECLARE v_idVenta INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Factura WHERE id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Factura no existe';
    END IF;

    -- Validar unicidad si se actualiza número/clave
    IF p_numero IS NOT NULL AND EXISTS (SELECT 1 FROM Factura WHERE numero = p_numero AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Número de factura ya existe';
    END IF;
    IF p_claveAcceso IS NOT NULL AND EXISTS (SELECT 1 FROM Factura WHERE claveAcceso = p_claveAcceso AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Clave de acceso ya existe';
    END IF;

    START TRANSACTION;

    UPDATE Factura
       SET estado = 'ENVIADA',
           numero = COALESCE(p_numero, numero),
           claveAcceso = COALESCE(p_claveAcceso, claveAcceso),
           fechaEmision = CURRENT_TIMESTAMP
     WHERE id = p_id;

    COMMIT;

    SELECT * FROM Factura WHERE id = p_id;
END //
//
DELIMITER ;

-- =========================================================
-- 5) ANULAR FACTURA
--    Marca factura como ANULADA y, opcionalmente, la venta como ANULADA.
--    (Si manejas stock/inventario, haz la lógica en servicio o trigger)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_factura_anular;
DELIMITER //

CREATE PROCEDURE sp_factura_anular(IN p_id INT)
BEGIN
    DECLARE v_idVenta INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Factura WHERE id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Factura no existe';
    END IF;

    START TRANSACTION;

    SELECT idVenta INTO v_idVenta FROM Factura WHERE id = p_id;

    UPDATE Factura
       SET estado = 'ANULADA'
     WHERE id = p_id;

    -- Opcional: sincronizar estado de la venta
    UPDATE Venta
       SET estado = 'ANULADA'
     WHERE id = v_idVenta;

    COMMIT;

    SELECT * FROM Factura WHERE id = p_id;
END //
//
DELIMITER ;

-- =========================================================
-- 6) FACTURA POR VENTA (útil para validar o consultar rápido)
-- =========================================================
DROP PROCEDURE IF EXISTS sp_factura_by_venta;
DELIMITER //

CREATE PROCEDURE sp_factura_by_venta(IN p_idVenta INT)
BEGIN
    SELECT * FROM Factura WHERE idVenta = p_idVenta;
END //
//
DELIMITER ;
