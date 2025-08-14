-- MySQL dump 10.13  Distrib 8.0.33, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: p3_db
-- ------------------------------------------------------
-- Server version	8.2.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `estado` enum('ACTIVO','INACTIVO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVO',
  `idPadre` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`),
  KEY `idx_categoria_padre` (`idPadre`),
  CONSTRAINT `fk_cat_padre` FOREIGN KEY (`idPadre`) REFERENCES `categoria` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
INSERT INTO `categoria` VALUES (1,'Tecnología','Todo de tecnología','ACTIVO',NULL),(2,'Software','Licencias y apps','ACTIVO',1),(3,'Hardware','Equipos y partes','ACTIVO',1),(4,'Servicios','Servicios varios','ACTIVO',NULL),(5,'Educación Digital','Cursos online','ACTIVO',4);
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `direccion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo` enum('NATURAL','JURIDICA') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES (1,'juan.perez@example.com','0991234567','Av. Siempre Viva 123','NATURAL'),(2,'ventas@acme.com','022345678','Calle Industria 456','JURIDICA'),(3,'maria.lopez@example.com','0987654321','Pasaje Los Almendros','NATURAL'),(4,'contacto@techcorp.com','023334455','Parque Empresarial','JURIDICA'),(5,'kfc@example.com','123456743','Direccion 123','JURIDICA'),(6,'nuevo.usuario@example.com','0991112233','Av. Central 999','NATURAL'),(7,'asd@example.com','22222222','asdaaa','JURIDICA');
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;

--
-- Table structure for table `detalleventa`
--

DROP TABLE IF EXISTS `detalleventa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalleventa` (
  `idVenta` int NOT NULL,
  `lineNumber` int NOT NULL,
  `idProducto` int NOT NULL,
  `cantidad` int NOT NULL,
  `precioUnitario` decimal(12,2) NOT NULL,
  `subtotal` decimal(14,2) GENERATED ALWAYS AS ((`cantidad` * `precioUnitario`)) VIRTUAL,
  PRIMARY KEY (`idVenta`,`lineNumber`),
  KEY `idx_detalle_prod` (`idProducto`),
  CONSTRAINT `fk_dv_producto` FOREIGN KEY (`idProducto`) REFERENCES `producto` (`id`),
  CONSTRAINT `fk_dv_venta` FOREIGN KEY (`idVenta`) REFERENCES `venta` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalleventa`
--

/*!40000 ALTER TABLE `detalleventa` DISABLE KEYS */;
INSERT INTO `detalleventa` (`idVenta`, `lineNumber`, `idProducto`, `cantidad`, `precioUnitario`) VALUES (1,1,1,2,12.50),(1,2,3,1,25.00),(2,1,4,1,60.00);
/*!40000 ALTER TABLE `detalleventa` ENABLE KEYS */;

--
-- Table structure for table `factura`
--

DROP TABLE IF EXISTS `factura`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `factura` (
  `id` int NOT NULL AUTO_INCREMENT,
  `idVenta` int NOT NULL,
  `numero` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `claveAcceso` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fechaEmision` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` enum('PENDIENTE','ENVIADA','ANULADA') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idVenta` (`idVenta`),
  UNIQUE KEY `numero` (`numero`),
  UNIQUE KEY `claveAcceso` (`claveAcceso`),
  CONSTRAINT `fk_factura_venta` FOREIGN KEY (`idVenta`) REFERENCES `venta` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `factura`
--

/*!40000 ALTER TABLE `factura` DISABLE KEYS */;
INSERT INTO `factura` VALUES (1,1,'001-001-000000001','111122223333444455556666777788889999000001','2025-08-13 22:18:11','ENVIADA');
/*!40000 ALTER TABLE `factura` ENABLE KEYS */;

--
-- Table structure for table `permiso`
--

DROP TABLE IF EXISTS `permiso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permiso` (
  `id` int NOT NULL AUTO_INCREMENT,
  `codigo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo` (`codigo`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permiso`
--

/*!40000 ALTER TABLE `permiso` DISABLE KEYS */;
INSERT INTO `permiso` VALUES (3,'FACTURAS_EMITIR'),(4,'PRODUCTOS_GESTION'),(5,'USUARIOS_GESTION'),(1,'VENTAS_CREA'),(2,'VENTAS_VER');
/*!40000 ALTER TABLE `permiso` ENABLE KEYS */;

--
-- Table structure for table `personajuridica`
--

DROP TABLE IF EXISTS `personajuridica`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personajuridica` (
  `id` int NOT NULL,
  `razonSocial` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ruc` varchar(13) COLLATE utf8mb4_unicode_ci NOT NULL,
  `representanteLegal` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ruc` (`ruc`),
  CONSTRAINT `fk_pj_cliente` FOREIGN KEY (`id`) REFERENCES `cliente` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personajuridica`
--

/*!40000 ALTER TABLE `personajuridica` DISABLE KEYS */;
INSERT INTO `personajuridica` VALUES (2,'ACME S.A.','1790012345001','Carlos Andrade'),(4,'TechCorp Cía.','1790098765001','Ana Morales'),(5,'Razon Social','1234567890222','KFC'),(7,'asd','1790097765001','asd');
/*!40000 ALTER TABLE `personajuridica` ENABLE KEYS */;

--
-- Table structure for table `personanatural`
--

DROP TABLE IF EXISTS `personanatural`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personanatural` (
  `id` int NOT NULL,
  `nombres` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellidos` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cedula` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cedula` (`cedula`),
  CONSTRAINT `fk_pn_cliente` FOREIGN KEY (`id`) REFERENCES `cliente` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personanatural`
--

/*!40000 ALTER TABLE `personanatural` DISABLE KEYS */;
INSERT INTO `personanatural` VALUES (1,'Juan Pe','Pérez Gómez','1725778672'),(3,'María','López Ruiz','1751992817'),(6,'Luis','Ramírez Torres','0702207366');
/*!40000 ALTER TABLE `personanatural` ENABLE KEYS */;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  `precioUnitario` decimal(12,2) NOT NULL,
  `stock` int NOT NULL DEFAULT '0',
  `idCategoria` int NOT NULL,
  `tipo` enum('FISICO','DIGITAL') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_producto_cat` (`idCategoria`),
  CONSTRAINT `fk_prod_categoria` FOREIGN KEY (`idCategoria`) REFERENCES `categoria` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto`
--

/*!40000 ALTER TABLE `producto` DISABLE KEYS */;
INSERT INTO `producto` VALUES (1,'Mouse óptico','Mouse USB de 1200 DPI',12.50,101,3,'FISICO'),(2,'Teclado mecánico','Teclado switch azul',45.00,50,3,'FISICO'),(3,'Antivirus Pro (1 año)','Licencia anual para 1 equipo',25.00,1001,2,'DIGITAL'),(4,'Curso JavaScript Online','Acceso 6 meses con certificados',60.00,999,5,'DIGITAL'),(5,'Nuevo Producto Físico','Descripción del nuevo producto físico',29.99,100,1,'FISICO');
/*!40000 ALTER TABLE `producto` ENABLE KEYS */;

--
-- Table structure for table `productodigital`
--

DROP TABLE IF EXISTS `productodigital`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productodigital` (
  `id` int NOT NULL,
  `urlDescarga` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `licencia` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_pd_producto` FOREIGN KEY (`id`) REFERENCES `producto` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productodigital`
--

/*!40000 ALTER TABLE `productodigital` DISABLE KEYS */;
INSERT INTO `productodigital` VALUES (3,'https://descargas.ejemplo.com/antivirus-pro','EULA-AVP-STD'),(4,'https://plataforma.ejemplo.com/cursos/js','CURSO-JS-ONLINE');
/*!40000 ALTER TABLE `productodigital` ENABLE KEYS */;

--
-- Table structure for table `productofisico`
--

DROP TABLE IF EXISTS `productofisico`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productofisico` (
  `id` int NOT NULL,
  `peso` decimal(8,2) DEFAULT NULL,
  `alto` decimal(8,2) DEFAULT NULL,
  `ancho` decimal(8,2) DEFAULT NULL,
  `profundidad` decimal(8,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_pf_producto` FOREIGN KEY (`id`) REFERENCES `producto` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productofisico`
--

/*!40000 ALTER TABLE `productofisico` DISABLE KEYS */;
INSERT INTO `productofisico` VALUES (1,0.10,4.00,6.00,10.00),(2,0.80,4.50,44.00,14.00),(5,1.50,10.00,5.00,3.00);
/*!40000 ALTER TABLE `productofisico` ENABLE KEYS */;

--
-- Table structure for table `rol`
--

DROP TABLE IF EXISTS `rol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rol` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol`
--

/*!40000 ALTER TABLE `rol` DISABLE KEYS */;
INSERT INTO `rol` VALUES (1,'ADMIN'),(2,'VENTAS');
/*!40000 ALTER TABLE `rol` ENABLE KEYS */;

--
-- Table structure for table `rolpermiso`
--

DROP TABLE IF EXISTS `rolpermiso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rolpermiso` (
  `idRol` int NOT NULL,
  `idPermiso` int NOT NULL,
  PRIMARY KEY (`idRol`,`idPermiso`),
  KEY `fk_rp_permiso` (`idPermiso`),
  CONSTRAINT `fk_rp_permiso` FOREIGN KEY (`idPermiso`) REFERENCES `permiso` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rp_rol` FOREIGN KEY (`idRol`) REFERENCES `rol` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rolpermiso`
--

/*!40000 ALTER TABLE `rolpermiso` DISABLE KEYS */;
INSERT INTO `rolpermiso` VALUES (1,1),(2,1),(1,2),(2,2),(1,3),(2,3),(1,4),(1,5);
/*!40000 ALTER TABLE `rolpermiso` ENABLE KEYS */;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `passwordHash` char(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado` enum('ACTIVO','INACTIVO','BLOQUEADO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVO',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (1,'admin','$2y$10$abcdefghijklmnopqrstuv1234567890abcdefghijklmnopqrstu','ACTIVO'),(2,'vendedorA','$2y$10$mnopqrstu1234567890abcdefghijklmnopqrstuvabcdefghijkl','ACTIVO');
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;

--
-- Table structure for table `usuariorol`
--

DROP TABLE IF EXISTS `usuariorol`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuariorol` (
  `usuario_id` int NOT NULL,
  `rol_id` int NOT NULL,
  PRIMARY KEY (`usuario_id`,`rol_id`),
  KEY `fk_ur_rol` (`rol_id`),
  CONSTRAINT `fk_ur_rol` FOREIGN KEY (`rol_id`) REFERENCES `rol` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ur_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuariorol`
--

/*!40000 ALTER TABLE `usuariorol` DISABLE KEYS */;
INSERT INTO `usuariorol` VALUES (1,1),(2,2);
/*!40000 ALTER TABLE `usuariorol` ENABLE KEYS */;

--
-- Table structure for table `venta`
--

DROP TABLE IF EXISTS `venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venta` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `idCliente` int NOT NULL,
  `total` decimal(12,2) NOT NULL,
  `estado` enum('BORRADOR','EMITIDA','ANULADA') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'BORRADOR',
  PRIMARY KEY (`id`),
  KEY `idx_venta_cliente` (`idCliente`),
  CONSTRAINT `fk_venta_cliente` FOREIGN KEY (`idCliente`) REFERENCES `cliente` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta`
--

/*!40000 ALTER TABLE `venta` DISABLE KEYS */;
INSERT INTO `venta` VALUES (1,'2025-08-13 22:18:03',1,50.00,'EMITIDA'),(2,'2025-08-13 22:18:04',3,60.00,'BORRADOR');
/*!40000 ALTER TABLE `venta` ENABLE KEYS */;

--
-- Dumping routines for database 'p3_db'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_categoria_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_categoria_list`()
BEGIN
    SELECT c.id, c.nombre, c.descripcion, c.estado, c.idPadre
    FROM Categoria c
    ORDER BY c.nombre;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_categoria_tree` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_categoria_tree`(IN p_root_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_categoria` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_categoria`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_permiso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_permiso`(IN p_codigo VARCHAR(100))
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_persona_juridica` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_persona_juridica`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_persona_natural` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_persona_natural`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_producto_digital` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_producto_digital`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_producto_fisico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_producto_fisico`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_usuario`(
    IN p_username     VARCHAR(50),
    IN p_passwordHash VARCHAR(100),
    IN p_estado       ENUM('ACTIVO','INACTIVO','BLOQUEADO')
)
BEGIN
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;

    IF p_estado NOT IN ('ACTIVO','INACTIVO','BLOQUEADO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estado inválido';
    END IF;

    IF EXISTS (SELECT 1 FROM Usuario WHERE username=p_username) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Username ya existe';
    END IF;

    START TRANSACTION;

    INSERT INTO Usuario (username, passwordHash, estado)
    VALUES (p_username, p_passwordHash, p_estado);

    SET v_new_id = LAST_INSERT_ID();

    COMMIT;
    SELECT v_new_id AS usuario_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_create_venta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_venta`(IN p_idCliente INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_categoria` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_categoria`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_permiso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_permiso`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_persona_juridica` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_persona_juridica`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_persona_natural` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_persona_natural`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_producto_digital` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_producto_digital`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_producto_fisico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_producto_fisico`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_delete_venta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_venta`(IN p_idVenta INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_detalle_venta_add` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_detalle_venta_add`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_detalle_venta_delete` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_detalle_venta_delete`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_detalle_venta_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_detalle_venta_list`(IN p_idVenta INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_detalle_venta_list_all` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_detalle_venta_list_all`()
BEGIN
    SELECT
        idVenta,
        lineNumber,
        idProducto,
        cantidad,
        precioUnitario
    FROM DetalleVenta
    ORDER BY idVenta, lineNumber;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_detalle_venta_update` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_detalle_venta_update`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_factura_anular` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_factura_anular`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_factura_by_venta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_factura_by_venta`(IN p_idVenta INT)
BEGIN
    SELECT * FROM Factura WHERE idVenta = p_idVenta;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_factura_create` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_factura_create`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_factura_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_factura_list`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_factura_mark_enviada` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_factura_mark_enviada`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_find_categoria` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_categoria`(IN p_id INT)
BEGIN
    SELECT c.id, c.nombre, c.descripcion, c.estado, c.idPadre
    FROM Categoria c
    WHERE c.id = p_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_find_detalle_venta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_detalle_venta`(IN p_idVenta INT, IN p_lineNumber INT)
BEGIN
    SELECT
        d.idVenta, d.lineNumber, d.idProducto, p.nombre,
        d.cantidad, d.precioUnitario, d.subtotal
    FROM DetalleVenta d
    JOIN Producto p ON p.id = d.idProducto
    WHERE d.idVenta = p_idVenta AND d.lineNumber = p_lineNumber;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_find_factura` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_factura`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_find_factura_by_numero` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_factura_by_numero`(IN p_numero VARCHAR(50))
BEGIN
    SELECT f.* FROM Factura f WHERE f.numero = p_numero;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_find_permiso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_permiso`(IN p_id INT)
BEGIN
    SELECT id, codigo
    FROM Permiso
    WHERE id = p_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_find_persona_juridica` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_persona_juridica`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_find_persona_natural` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_persona_natural`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_find_producto_digital` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_producto_digital`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_find_producto_fisico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_producto_fisico`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_find_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_usuario`(IN p_id INT)
BEGIN
    SELECT id, username, estado
    FROM Usuario
    WHERE id = p_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_find_venta` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_find_venta`(IN p_id INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_permiso_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_permiso_list`()
BEGIN
    SELECT id, codigo
    FROM Permiso
    ORDER BY codigo;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_permiso_roles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_permiso_roles`(IN p_idPermiso INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Permiso WHERE id = p_idPermiso) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Permiso no existe';
    END IF;

    SELECT r.id, r.nombre
    FROM RolPermiso rp
    JOIN Rol r ON r.id = rp.idRol
    WHERE rp.idPermiso = p_idPermiso
    ORDER BY r.nombre;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_persona_juridica_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_persona_juridica_list`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_persona_natural_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_persona_natural_list`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_producto_digital_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_producto_digital_list`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_producto_fisico_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_producto_fisico_list`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rol_add_permiso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rol_add_permiso`(
    IN p_idRol INT,
    IN p_idPermiso INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; RESIGNAL; END;

    IF NOT EXISTS (SELECT 1 FROM Rol WHERE id = p_idRol) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rol no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Permiso WHERE id = p_idPermiso) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Permiso no existe';
    END IF;

    IF EXISTS (
        SELECT 1 FROM RolPermiso
        WHERE idRol = p_idRol AND idPermiso = p_idPermiso
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El rol ya tiene ese permiso';
    END IF;

    START TRANSACTION;

    INSERT INTO RolPermiso (idRol, idPermiso)
    VALUES (p_idRol, p_idPermiso);

    COMMIT;
    SELECT 1 AS ok;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rol_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rol_list`()
BEGIN
    SELECT id, nombre FROM Rol ORDER BY nombre;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rol_permisos` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rol_permisos`(IN p_idRol INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Rol WHERE id = p_idRol) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rol no existe';
    END IF;

    SELECT p.id, p.codigo
    FROM RolPermiso rp
    JOIN Permiso p ON p.id = rp.idPermiso
    WHERE rp.idRol = p_idRol
    ORDER BY p.codigo;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rol_permiso_matrix` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rol_permiso_matrix`()
BEGIN
    SELECT 
        r.id   AS rol_id,
        r.nombre AS rol_nombre,
        p.id   AS permiso_id,
        p.codigo AS permiso_codigo
    FROM Rol r
    LEFT JOIN RolPermiso rp ON rp.idRol = r.id
    LEFT JOIN Permiso p     ON p.id = rp.idPermiso
    ORDER BY r.nombre, p.codigo;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_rol_remove_permiso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rol_remove_permiso`(
    IN p_idRol INT,
    IN p_idPermiso INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN ROLLBACK; RESIGNAL; END;

    IF NOT EXISTS (SELECT 1 FROM Rol WHERE id = p_idRol) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rol no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Permiso WHERE id = p_idPermiso) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Permiso no existe';
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM RolPermiso
        WHERE idRol = p_idRol AND idPermiso = p_idPermiso
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El rol no tiene ese permiso';
    END IF;

    START TRANSACTION;

    DELETE FROM RolPermiso
     WHERE idRol = p_idRol AND idPermiso = p_idPermiso;

    COMMIT;
    SELECT 1 AS ok;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_categoria` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_categoria`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_permiso` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_permiso`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_persona_juridica` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_persona_juridica`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_persona_natural` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_persona_natural`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_producto_digital` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_producto_digital`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_producto_fisico` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_producto_fisico`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_update_usuario` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_usuario`(
    IN p_id           INT,
    IN p_username     VARCHAR(50),
    IN p_estado       ENUM('ACTIVO','INACTIVO','BLOQUEADO')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id=p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario no existe';
    END IF;

    IF p_estado NOT IN ('ACTIVO','INACTIVO','BLOQUEADO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estado inválido';
    END IF;

    IF EXISTS (SELECT 1 FROM Usuario WHERE username=p_username AND id<>p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Username ya en uso';
    END IF;

    START TRANSACTION;

    UPDATE Usuario
       SET username = p_username,
           estado   = p_estado
     WHERE id = p_id;

    COMMIT;
    SELECT 1 AS ok;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_usuario_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_list`()
BEGIN
    SELECT id, username, estado
    FROM Usuario
    ORDER BY username;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_usuario_remove_role` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_remove_role`(
    IN p_usuario_id INT,
    IN p_rol_id     INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id=p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario no existe';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM UsuarioRol WHERE usuario_id=p_usuario_id AND rol_id=p_rol_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='El usuario no tiene ese rol';
    END IF;

    START TRANSACTION;

    DELETE FROM UsuarioRol
     WHERE usuario_id=p_usuario_id AND rol_id=p_rol_id;

    COMMIT;
    SELECT 1 AS ok;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_usuario_roles` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_roles`(IN p_usuario_id INT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id=p_usuario_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario no existe';
    END IF;

    SELECT r.id, r.nombre
    FROM UsuarioRol ur
    JOIN Rol r ON r.id = ur.rol_id
    WHERE ur.usuario_id = p_usuario_id
    ORDER BY r.nombre;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_usuario_set_estado` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_set_estado`(
    IN p_id     INT,
    IN p_estado ENUM('ACTIVO','INACTIVO','BLOQUEADO')
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id=p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario no existe';
    END IF;

    IF p_estado NOT IN ('ACTIVO','INACTIVO','BLOQUEADO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Estado inválido';
    END IF;

    START TRANSACTION;

    UPDATE Usuario
       SET estado = p_estado
     WHERE id = p_id;

    COMMIT;
    SELECT 1 AS ok;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_usuario_set_password` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_usuario_set_password`(
    IN p_id           INT,
    IN p_passwordHash VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;

    IF NOT EXISTS (SELECT 1 FROM Usuario WHERE id=p_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Usuario no existe';
    END IF;

    START TRANSACTION;

    UPDATE Usuario
       SET passwordHash = p_passwordHash
     WHERE id = p_id;

    COMMIT;
    SELECT 1 AS ok;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_venta_add_detalle` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_venta_add_detalle`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_venta_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_venta_list`()
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_venta_recalcular_total` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_venta_recalcular_total`(IN p_idVenta INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_venta_update_header` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_venta_update_header`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-08-14 13:35:40
