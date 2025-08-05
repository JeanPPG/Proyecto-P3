-- 1. CREACIÓN DE LA BASE DE DATOS Y SELECCIÓN
CREATE DATABASE IF NOT EXISTS p3_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE p3_db;

-- 2. TABLA PADRE CLIENTE (abstracta)
CREATE TABLE Cliente (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255)    NOT NULL UNIQUE,
  telefono VARCHAR(20)  NULL,
  direccion VARCHAR(255) NULL,
  tipo ENUM('NATURAL','JURIDICA') NOT NULL
) ENGINE=InnoDB;

-- 2.1 SUBTIPO PersonaNatural
CREATE TABLE PersonaNatural (
  id INT PRIMARY KEY,
  nombres   VARCHAR(100) NOT NULL,
  apellidos VARCHAR(100) NOT NULL,
  cedula    VARCHAR(10)  NOT NULL UNIQUE,
  CONSTRAINT fk_pn_cliente FOREIGN KEY (id)
    REFERENCES Cliente(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 2.2 SUBTIPO PersonaJuridica
CREATE TABLE PersonaJuridica (
  id INT PRIMARY KEY,
  razonSocial       VARCHAR(255) NOT NULL,
  ruc               VARCHAR(13)  NOT NULL UNIQUE,
  representanteLegal VARCHAR(255) NULL,
  CONSTRAINT fk_pj_cliente FOREIGN KEY (id)
    REFERENCES Cliente(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. CATEGORÍAS
CREATE TABLE Categoria (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre    VARCHAR(100) NOT NULL UNIQUE,
  descripcion TEXT,
  estado    ENUM('ACTIVO','INACTIVO') NOT NULL DEFAULT 'ACTIVO',
  idPadre   INT NULL,
  CONSTRAINT fk_cat_padre FOREIGN KEY (idPadre)
    REFERENCES Categoria(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 4. TABLA PADRE PRODUCTO (abstracta)
CREATE TABLE Producto (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  nombre         VARCHAR(150) NOT NULL,
  descripcion    TEXT,
  precioUnitario DECIMAL(12,2) NOT NULL,
  stock          INT            NOT NULL DEFAULT 0,
  idCategoria    INT            NOT NULL,
  tipo           ENUM('FISICO','DIGITAL') NOT NULL,
  CONSTRAINT fk_prod_categoria FOREIGN KEY (idCategoria)
    REFERENCES Categoria(id)
) ENGINE=InnoDB;

-- 4.1 SUBTIPO ProductoFisico
CREATE TABLE ProductoFisico (
  id          INT PRIMARY KEY,
  peso        DECIMAL(8,2) NULL,
  alto        DECIMAL(8,2) NULL,
  ancho       DECIMAL(8,2) NULL,
  profundidad DECIMAL(8,2) NULL,
  CONSTRAINT fk_pf_producto FOREIGN KEY (id)
    REFERENCES Producto(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4.2 SUBTIPO ProductoDigital
CREATE TABLE ProductoDigital (
  id          INT PRIMARY KEY,
  urlDescarga VARCHAR(255) NOT NULL,
  licencia    VARCHAR(100) NULL,
  CONSTRAINT fk_pd_producto FOREIGN KEY (id)
    REFERENCES Producto(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. VENTAS Y DETALLES
CREATE TABLE Venta (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  fecha     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  idCliente INT      NOT NULL,
  total     DECIMAL(12,2) NOT NULL,
  estado    ENUM('BORRADOR','EMITIDA','ANULADA') NOT NULL DEFAULT 'BORRADOR',
  CONSTRAINT fk_venta_cliente FOREIGN KEY (idCliente)
    REFERENCES Cliente(id)
) ENGINE=InnoDB;

CREATE TABLE DetalleVenta (
  idVenta       INT NOT NULL,
  lineNumber    INT NOT NULL,
  idProducto    INT NOT NULL,
  cantidad      INT NOT NULL,
  precioUnitario DECIMAL(12,2) NOT NULL,
  subtotal      DECIMAL(14,2) AS (cantidad * precioUnitario) VIRTUAL,
  PRIMARY KEY (idVenta, lineNumber),
  CONSTRAINT fk_dv_venta FOREIGN KEY (idVenta)
    REFERENCES Venta(id) ON DELETE CASCADE,
  CONSTRAINT fk_dv_producto FOREIGN KEY (idProducto)
    REFERENCES Producto(id)
) ENGINE=InnoDB;

-- 6. FACTURAS
CREATE TABLE Factura (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  idVenta       INT NOT NULL UNIQUE,
  numero        VARCHAR(50)  NOT NULL UNIQUE,
  claveAcceso   VARCHAR(100) NOT NULL UNIQUE,
  fechaEmision  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado        ENUM('PENDIENTE','ENVIADA','ANULADA') NOT NULL DEFAULT 'PENDIENTE',
  CONSTRAINT fk_factura_venta FOREIGN KEY (idVenta)
    REFERENCES Venta(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. USUARIOS, ROLES Y PERMISOS
CREATE TABLE Usuario (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  username     VARCHAR(50) NOT NULL UNIQUE,
  passwordHash CHAR(60)    NOT NULL,
  estado       ENUM('ACTIVO','INACTIVO','BLOQUEADO') NOT NULL DEFAULT 'ACTIVO'
) ENGINE=InnoDB;

CREATE TABLE Rol (
  id     INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE Permiso (
  id     INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(100)    NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 7.1 Tabla puente RolPermiso
CREATE TABLE RolPermiso (
  idRol     INT NOT NULL,
  idPermiso INT NOT NULL,
  PRIMARY KEY (idRol, idPermiso),
  CONSTRAINT fk_rp_rol FOREIGN KEY (idRol)
    REFERENCES Rol(id) ON DELETE CASCADE,
  CONSTRAINT fk_rp_permiso FOREIGN KEY (idPermiso)
    REFERENCES Permiso(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7.2 Tabla puente UsuarioRol
CREATE TABLE UsuarioRol (
  usuario_id INT NOT NULL,
  rol_id     INT NOT NULL,
  PRIMARY KEY (usuario_id, rol_id),
  CONSTRAINT fk_ur_usuario FOREIGN KEY (usuario_id)
    REFERENCES Usuario(id) ON DELETE CASCADE,
  CONSTRAINT fk_ur_rol FOREIGN KEY (rol_id)
    REFERENCES Rol(id) ON DELETE CASCADE
) ENGINE=InnoDB;
