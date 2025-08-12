-- Active: 1752793151268@@127.0.0.1@3306@p3_db
-- 0) Índices (opcional pero recomendado)
CREATE INDEX idx_categoria_padre   ON Categoria(idPadre);
CREATE INDEX idx_producto_cat      ON Producto(idCategoria);
CREATE INDEX idx_venta_cliente     ON Venta(idCliente);
CREATE INDEX idx_detalle_prod      ON DetalleVenta(idProducto);

-- 1) Categorías (árbol)
INSERT INTO Categoria (nombre, descripcion, estado, idPadre) VALUES
  ('Tecnología', 'Todo de tecnología', 'ACTIVO', NULL),           -- id=1
  ('Software',   'Licencias y apps',   'ACTIVO', 1),               -- id=2
  ('Hardware',   'Equipos y partes',   'ACTIVO', 1),               -- id=3
  ('Servicios',  'Servicios varios',   'ACTIVO', NULL),            -- id=4
  ('Educación Digital','Cursos online','ACTIVO', 4);               -- id=5

-- 2) Productos (padre)
INSERT INTO Producto (nombre, descripcion, precioUnitario, stock, idCategoria, tipo) VALUES
  ('Mouse óptico',           'Mouse USB de 1200 DPI',             12.50, 100, 3, 'FISICO'),   -- id=1
  ('Teclado mecánico',       'Teclado switch azul',               45.00,  50, 3, 'FISICO'),   -- id=2
  ('Antivirus Pro (1 año)',  'Licencia anual para 1 equipo',      25.00,1000, 2, 'DIGITAL'),  -- id=3
  ('Curso JavaScript Online','Acceso 6 meses con certificados',   60.00, 999, 5, 'DIGITAL');  -- id=4

-- 2.1) Subtipo físico
INSERT INTO ProductoFisico (id, peso, alto, ancho, profundidad) VALUES
  (1, 0.10, 4.00, 6.00, 10.00),
  (2, 0.80, 4.50, 44.00, 14.00);

-- 2.2) Subtipo digital
INSERT INTO ProductoDigital (id, urlDescarga, licencia) VALUES
  (3, 'https://descargas.ejemplo.com/antivirus-pro', 'EULA-AVP-STD'),
  (4, 'https://plataforma.ejemplo.com/cursos/js',     'CURSO-JS-ONLINE');

-- 3) Clientes (padre)
INSERT INTO Cliente (email, telefono, direccion, tipo) VALUES
  ('juan.perez@example.com',  '0991234567', 'Av. Siempre Viva 123', 'NATURAL'),   -- id=1
  ('ventas@acme.com',         '022345678',  'Calle Industria 456',  'JURIDICA'),  -- id=2
  ('maria.lopez@example.com', '0987654321', 'Pasaje Los Almendros', 'NATURAL'),   -- id=3
  ('contacto@techcorp.com',   '023334455',  'Parque Empresarial',   'JURIDICA');  -- id=4

-- 3.1) Persona Natural
INSERT INTO PersonaNatural (id, nombres, apellidos, cedula) VALUES
  (1, 'Juan',  'Pérez Gómez', '1102456789'),
  (3, 'María', 'López Ruiz',  '0912345678');

-- 3.2) Persona Jurídica
INSERT INTO PersonaJuridica (id, razonSocial, ruc, representanteLegal) VALUES
  (2, 'ACME S.A.',     '1790012345001', 'Carlos Andrade'),
  (4, 'TechCorp Cía.', '1790098765001', 'Ana Morales');

-- 4) Ventas
-- Venta 1: Juan compra 2 mouse y 1 antivirus (total 50.00)
INSERT INTO Venta (idCliente, total, estado) VALUES
  (1, 50.00, 'EMITIDA');  -- id=1

-- Venta 2: María compra 1 curso JS (total 60.00)
INSERT INTO Venta (idCliente, total, estado) VALUES
  (3, 60.00, 'BORRADOR'); -- id=2

-- 5) Detalles de venta
-- Venta 1 (id=1)
INSERT INTO DetalleVenta (idVenta, lineNumber, idProducto, cantidad, precioUnitario) VALUES
  (1, 1, 1, 2, 12.50),   -- 2 x Mouse  = 25.00
  (1, 2, 3, 1, 25.00);   -- 1 x AV Pro = 25.00  → subtotal total = 50.00

-- Venta 2 (id=2)
INSERT INTO DetalleVenta (idVenta, lineNumber, idProducto, cantidad, precioUnitario) VALUES
  (2, 1, 4, 1, 60.00);   -- 1 x Curso = 60.00

-- 6) Facturas (única por venta)
INSERT INTO Factura (idVenta, numero, claveAcceso, estado) VALUES
  (1, '001-001-000000001', '111122223333444455556666777788889999000001', 'ENVIADA');

-- 7) Seguridad: Usuarios, Roles, Permisos
INSERT INTO Usuario (username, passwordHash, estado) VALUES
  ('admin',    '$2y$10$abcdefghijklmnopqrstuv1234567890abcdefghijklmnopqrstu', 'ACTIVO'),
  ('vendedor', '$2y$10$mnopqrstu1234567890abcdefghijklmnopqrstuvabcdefghijkl', 'ACTIVO');

INSERT INTO Rol (nombre) VALUES
  ('ADMIN'),
  ('VENTAS');

INSERT INTO Permiso (codigo) VALUES
  ('VENTAS_CREAR'),
  ('VENTAS_VER'),
  ('FACTURAS_EMITIR'),
  ('PRODUCTOS_GESTION'),
  ('USUARIOS_GESTION');

-- RolPermiso: ADMIN con todos; VENTAS con crear/ver y emitir facturas
INSERT INTO RolPermiso (idRol, idPermiso)
SELECT r.id, p.id FROM Rol r CROSS JOIN Permiso p WHERE r.nombre='ADMIN';

INSERT INTO RolPermiso (idRol, idPermiso)
SELECT r.id, p.id FROM Rol r
JOIN Permiso p ON p.codigo IN ('VENTAS_CREAR','VENTAS_VER','FACTURAS_EMITIR')
WHERE r.nombre='VENTAS';

-- UsuarioRol
INSERT INTO UsuarioRol (usuario_id, rol_id)
SELECT u.id, r.id FROM Usuario u JOIN Rol r ON r.nombre='ADMIN'  WHERE u.username='admin';
INSERT INTO UsuarioRol (usuario_id, rol_id)
SELECT u.id, r.id FROM Usuario u JOIN Rol r ON r.nombre='VENTAS' WHERE u.username='vendedor';
