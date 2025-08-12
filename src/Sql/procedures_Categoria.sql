DROP PROCEDURE IF EXISTS sp_categoria_list;
DELIMITER //

CREATE PROCEDURE sp_categoria_list()
BEGIN
    SELECT c.id, c.nombre, c.descripcion, c.estado, c.idPadre
    FROM Categoria c
    ORDER BY c.nombre;
END //
//
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_find_categoria;
DELIMITER //

CREATE PROCEDURE sp_find_categoria(IN p_id INT)
BEGIN
    SELECT c.id, c.nombre, c.descripcion, c.estado, c.idPadre
    FROM Categoria c
    WHERE c.id = p_id;
END //
//
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_create_categoria;
DELIMITER //

CREATE PROCEDURE sp_create_categoria(
    IN p_nombre      VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_estado      ENUM('ACTIVO','INACTIVO'),
    IN p_idPadre     INT
)
BEGIN
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_estado NOT IN ('ACTIVO','INACTIVO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado inválido';
    END IF;

    IF EXISTS (SELECT 1 FROM Categoria WHERE nombre = p_nombre) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre de categoría ya existe';
    END IF;

    IF p_idPadre IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Categoria WHERE id = p_idPadre) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'idPadre no existe';
    END IF;

    START TRANSACTION;

    INSERT INTO Categoria (nombre, descripcion, estado, idPadre)
    VALUES (p_nombre, p_descripcion, p_estado, p_idPadre);

    SET v_new_id = LAST_INSERT_ID();

    COMMIT;

    SELECT v_new_id AS categoria_id;
END //
//
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_update_categoria;
DELIMITER //

CREATE PROCEDURE sp_update_categoria(
    IN p_id          INT,
    IN p_nombre      VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_estado      ENUM('ACTIVO','INACTIVO'),
    IN p_idPadre     INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Categoria WHERE id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Categoría no encontrada';
    END IF;

    IF p_estado NOT IN ('ACTIVO','INACTIVO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado inválido';
    END IF;

    IF EXISTS (SELECT 1 FROM Categoria WHERE nombre = p_nombre AND id <> p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nombre de categoría ya existe';
    END IF;

    IF p_idPadre = p_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'idPadre no puede ser el mismo id';
    END IF;

    IF p_idPadre IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Categoria WHERE id = p_idPadre) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'idPadre no existe';
    END IF;


    START TRANSACTION;

    UPDATE Categoria
       SET nombre      = p_nombre,
           descripcion = p_descripcion,
           estado      = p_estado,
           idPadre     = p_idPadre
     WHERE id = p_id;

    COMMIT;

    SELECT 1 AS ok;
END //
//
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_delete_categoria;
DELIMITER //

CREATE PROCEDURE sp_delete_categoria(IN p_id INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Categoria WHERE id = p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Categoría no encontrada';
    END IF;

    START TRANSACTION;
    DELETE FROM Categoria WHERE id = p_id;
    COMMIT;

    SELECT 1 AS ok;
END //
//
DELIMITER ;


DROP PROCEDURE IF EXISTS sp_categoria_tree;
DELIMITER //

CREATE PROCEDURE sp_categoria_tree(IN p_root_id INT)
BEGIN
    WITH RECURSIVE cte AS (
        -- Raíz o nodo inicial
        SELECT 
            c.id, c.nombre, c.descripcion, c.estado, c.idPadre,
            0 AS depth,
            CAST(LPAD(c.id, 6, '0') AS CHAR(200)) AS path
        FROM Categoria c
        WHERE (p_root_id IS NULL AND c.idPadre IS NULL)
           OR (p_root_id IS NOT NULL AND c.id = p_root_id)

        UNION ALL

        -- Hijos
        SELECT
            ch.id, ch.nombre, ch.descripcion, ch.estado, ch.idPadre,
            cte.depth + 1 AS depth,
            CONCAT(cte.path, '>', LPAD(ch.id, 6, '0')) AS path
        FROM Categoria ch
        JOIN cte ON ch.idPadre = cte.id
    )
    SELECT id, nombre, descripcion, estado, idPadre, depth, path
    FROM cte
    ORDER BY path;
END //
//
DELIMITER ;


CALL sp_categoria_tree(NULL);
CALL sp_find_categoria(1);