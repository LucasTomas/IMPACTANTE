/* ============================================================================
   TP - BASE DE DATOS | GRUPO: IMPACTANTE
   Esquema: IMPACTANTE
   Motor:   SQL Server (2016 SP1 o superior)

   Contenido (en orden de ejecucion):
     0. Limpieza de objetos previos (permite re-ejecutar en pruebas)
     1. Creacion del esquema
     2. Creacion de tablas, PKs, FKs, UNIQUE y CHECK
     3. Vista auxiliar
     4. Stored Procedures de migracion (uno por entidad + uno orquestador)
     5. Ejecucion de la migracion (dentro de una transaccion)
     6. Triggers (se crean luego de migrar)
     7. Indices

   IMPORTANTE:
     - Ejecutar sobre la base de datos de la catedra (descomentar el USE).
     - La tabla maestra se asume como gd_esquema.Maestra. Si en tu base se
       llama distinto, reemplazar "gd_esquema.Maestra" (Ctrl+H) en todo el script.
   ============================================================================ */

USE [GD2C_2026];
GO

SET NOCOUNT ON;
GO

/* ============================================================================
   0. LIMPIEZA (solo para poder re-ejecutar durante las pruebas)
   ============================================================================ */
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_datos;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_detalle_reparacion;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_reparacion;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_alquiler;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_bicicleta_alquiler;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_detalle_compra;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_compra;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_detalle_venta;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_venta;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_repuesto;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_accesorio;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_bicicleta_venta;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_producto;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_modelo_bicicleta;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_proveedor;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_cliente;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_empleado;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_local;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_catalogos;
DROP PROCEDURE IF EXISTS IMPACTANTE.migrar_ubicaciones;
DROP VIEW IF EXISTS IMPACTANTE.vw_Maestra_Modelo;

DROP TABLE IF EXISTS IMPACTANTE.Detalle_Reparacion;
DROP TABLE IF EXISTS IMPACTANTE.Detalle_Compra;
DROP TABLE IF EXISTS IMPACTANTE.Detalle_Venta;
DROP TABLE IF EXISTS IMPACTANTE.Reparacion;
DROP TABLE IF EXISTS IMPACTANTE.Alquiler;
DROP TABLE IF EXISTS IMPACTANTE.Compra;
DROP TABLE IF EXISTS IMPACTANTE.Venta;
DROP TABLE IF EXISTS IMPACTANTE.Bicicleta_Alquiler;
DROP TABLE IF EXISTS IMPACTANTE.Accesorio;
DROP TABLE IF EXISTS IMPACTANTE.Bicicleta_Venta;
DROP TABLE IF EXISTS IMPACTANTE.Repuesto;
DROP TABLE IF EXISTS IMPACTANTE.Producto;
DROP TABLE IF EXISTS IMPACTANTE.Modelo_Bicicleta;
DROP TABLE IF EXISTS IMPACTANTE.Empleado;
DROP TABLE IF EXISTS IMPACTANTE.Cliente;
DROP TABLE IF EXISTS IMPACTANTE.Proveedor;
DROP TABLE IF EXISTS IMPACTANTE.[Local];
DROP TABLE IF EXISTS IMPACTANTE.Localidad;
DROP TABLE IF EXISTS IMPACTANTE.Provincia;
DROP TABLE IF EXISTS IMPACTANTE.Estado_Bici_Alquiler;
DROP TABLE IF EXISTS IMPACTANTE.Estado_Alquiler;
DROP TABLE IF EXISTS IMPACTANTE.Estado_Reparacion;
DROP TABLE IF EXISTS IMPACTANTE.Forma_Pago;
DROP TABLE IF EXISTS IMPACTANTE.Tipo_Producto;
DROP TABLE IF EXISTS IMPACTANTE.Categoria_Repuesto;
DROP TABLE IF EXISTS IMPACTANTE.Categoria_Accesorio;
DROP TABLE IF EXISTS IMPACTANTE.Categoria_Bicicleta;
DROP TABLE IF EXISTS IMPACTANTE.Marca;
GO

/* ============================================================================
   1. ESQUEMA
   ============================================================================ */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'IMPACTANTE')
    EXEC('CREATE SCHEMA IMPACTANTE');
GO

/* ============================================================================
   2. TABLAS
   ============================================================================ */

/* ---------- Catalogos simples ---------- */
CREATE TABLE IMPACTANTE.Provincia (
    provincia_id INT IDENTITY(1,1) NOT NULL,
    nombre       VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Provincia PRIMARY KEY (provincia_id),
    CONSTRAINT UQ_Provincia_nombre UNIQUE (nombre)
);

CREATE TABLE IMPACTANTE.Marca (
    marca_id INT IDENTITY(1,1) NOT NULL,
    nombre   VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Marca PRIMARY KEY (marca_id),
    CONSTRAINT UQ_Marca_nombre UNIQUE (nombre)
);

CREATE TABLE IMPACTANTE.Categoria_Bicicleta (
    categoria_bicicleta_id INT IDENTITY(1,1) NOT NULL,
    nombre                 VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Categoria_Bicicleta PRIMARY KEY (categoria_bicicleta_id),
    CONSTRAINT UQ_Categoria_Bicicleta_nombre UNIQUE (nombre)
);

CREATE TABLE IMPACTANTE.Categoria_Accesorio (
    categoria_accesorio_id INT IDENTITY(1,1) NOT NULL,
    nombre                 VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Categoria_Accesorio PRIMARY KEY (categoria_accesorio_id),
    CONSTRAINT UQ_Categoria_Accesorio_nombre UNIQUE (nombre)
);

CREATE TABLE IMPACTANTE.Categoria_Repuesto (
    categoria_repuesto_id INT IDENTITY(1,1) NOT NULL,
    nombre                VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Categoria_Repuesto PRIMARY KEY (categoria_repuesto_id),
    CONSTRAINT UQ_Categoria_Repuesto_nombre UNIQUE (nombre)
);

CREATE TABLE IMPACTANTE.Tipo_Producto (
    tipo_producto_id INT IDENTITY(1,1) NOT NULL,
    tipo_producto    VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Tipo_Producto PRIMARY KEY (tipo_producto_id),
    CONSTRAINT UQ_Tipo_Producto UNIQUE (tipo_producto)
);

CREATE TABLE IMPACTANTE.Forma_Pago (
    forma_pago_id INT IDENTITY(1,1) NOT NULL,
    descripcion   VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Forma_Pago PRIMARY KEY (forma_pago_id),
    CONSTRAINT UQ_Forma_Pago_descripcion UNIQUE (descripcion)
);

CREATE TABLE IMPACTANTE.Estado_Reparacion (
    estado_reparacion_id INT IDENTITY(1,1) NOT NULL,
    estado_reparacion    VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Estado_Reparacion PRIMARY KEY (estado_reparacion_id),
    CONSTRAINT UQ_Estado_Reparacion UNIQUE (estado_reparacion),
    CONSTRAINT CK_Estado_Reparacion CHECK (estado_reparacion IN ('Entregada')) 
);

CREATE TABLE IMPACTANTE.Estado_Alquiler (
    estado_alquiler_id INT IDENTITY(1,1) NOT NULL,
    estado_alquiler    VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Estado_Alquiler PRIMARY KEY (estado_alquiler_id),
    CONSTRAINT UQ_Estado_Alquiler UNIQUE (estado_alquiler),
    CONSTRAINT CK_Estado_Alquiler CHECK (estado_alquiler IN ('Devuelto')) 
);

CREATE TABLE IMPACTANTE.Estado_Bici_Alquiler (
    estado_bici_alquiler_id INT IDENTITY(1,1) NOT NULL,
    estado_bici_alquiler    VARCHAR(255)      NOT NULL,
    CONSTRAINT PK_Estado_Bici_Alquiler PRIMARY KEY (estado_bici_alquiler_id),
    CONSTRAINT UQ_Estado_Bici_Alquiler UNIQUE (estado_bici_alquiler),
    CONSTRAINT CK_Estado_Bici_Alquiler CHECK (estado_bici_alquiler IN ('Disponible')) 
);

/* ---------- Ubicacion ---------- */
CREATE TABLE IMPACTANTE.Localidad (
    localidad_id INT IDENTITY(1,1) NOT NULL,
    nombre       VARCHAR(255)      NOT NULL,
    provincia_id INT               NOT NULL,
    CONSTRAINT PK_Localidad PRIMARY KEY (localidad_id),
    CONSTRAINT FK_Localidad_Provincia FOREIGN KEY (provincia_id)
        REFERENCES IMPACTANTE.Provincia (provincia_id),
    CONSTRAINT UQ_Localidad_nombre_provincia UNIQUE (nombre, provincia_id)
);

/* ---------- Personas y organizaciones ---------- */
CREATE TABLE IMPACTANTE.[Local] (
    local_id     INT IDENTITY(1,1) NOT NULL,
    nombre       VARCHAR(255)      NOT NULL,
    telefono     VARCHAR(255)      NOT NULL,
    email        VARCHAR(255)      NOT NULL,
    direccion    VARCHAR(255)      NOT NULL,
    localidad_id INT               NOT NULL,
    CONSTRAINT PK_Local PRIMARY KEY (local_id),
    CONSTRAINT FK_Local_Localidad FOREIGN KEY (localidad_id)
        REFERENCES IMPACTANTE.Localidad (localidad_id),
    CONSTRAINT UQ_Local_nombre_direccion UNIQUE (nombre, direccion)
);

CREATE TABLE IMPACTANTE.Empleado (
    empleado_id      INT IDENTITY(1,1) NOT NULL,
    local_id         INT               NOT NULL,
    nombre           VARCHAR(255)      NOT NULL,
    apellido         VARCHAR(255)      NOT NULL,
    fecha_nacimiento DATETIME2         NOT NULL,
    dni              VARCHAR(255)      NOT NULL,
    puesto           VARCHAR(255)      NOT NULL,
    fecha_ingreso    DATETIME2         NOT NULL,
    telefono         VARCHAR(255)      NOT NULL,
    email            VARCHAR(255)      NOT NULL,
    domicilio        VARCHAR(255)      NOT NULL,
    localidad_id     INT               NOT NULL,
    CONSTRAINT PK_Empleado PRIMARY KEY (empleado_id),
    CONSTRAINT FK_Empleado_Local FOREIGN KEY (local_id)
        REFERENCES IMPACTANTE.[Local] (local_id),
    CONSTRAINT FK_Empleado_Localidad FOREIGN KEY (localidad_id)
        REFERENCES IMPACTANTE.Localidad (localidad_id),
    CONSTRAINT UQ_Empleado_dni UNIQUE (dni)
);

CREATE TABLE IMPACTANTE.Cliente (
    cliente_id       INT IDENTITY(1,1) NOT NULL,
    nombre           VARCHAR(255)      NOT NULL,
    apellido         VARCHAR(255)      NOT NULL,
    dni              VARCHAR(255)      NOT NULL,
    telefono         VARCHAR(255)      NOT NULL,
    email            VARCHAR(255)      NOT NULL,
    domicilio        VARCHAR(255)      NOT NULL,
    localidad_id     INT               NOT NULL,
    fecha_nacimiento DATETIME2         NOT NULL,
    CONSTRAINT PK_Cliente PRIMARY KEY (cliente_id),
    CONSTRAINT FK_Cliente_Localidad FOREIGN KEY (localidad_id)
        REFERENCES IMPACTANTE.Localidad (localidad_id),
    CONSTRAINT UQ_Cliente_dni UNIQUE (dni)
);

CREATE TABLE IMPACTANTE.Proveedor (
    proveedor_id INT IDENTITY(1,1) NOT NULL,
    razon_social VARCHAR(255)      NOT NULL,
    cuit         VARCHAR(255)      NOT NULL,
    telefono     VARCHAR(255)      NOT NULL,
    email        VARCHAR(255)      NOT NULL,
    direccion    VARCHAR(255)      NOT NULL,
    localidad_id INT               NOT NULL,
    CONSTRAINT PK_Proveedor PRIMARY KEY (proveedor_id),
    CONSTRAINT FK_Proveedor_Localidad FOREIGN KEY (localidad_id)
        REFERENCES IMPACTANTE.Localidad (localidad_id),
    CONSTRAINT UQ_Proveedor_cuit UNIQUE (cuit)
);

/* ---------- Bicicletas y productos ---------- */
CREATE TABLE IMPACTANTE.Modelo_Bicicleta (
    modelo_bicicleta_id    INT IDENTITY(1,1) NOT NULL,
    nombre                 VARCHAR(255)      NOT NULL,
    rodado                 VARCHAR(255)      NOT NULL,
    cuadro                 VARCHAR(255)      NOT NULL,
    color                  VARCHAR(255)      NOT NULL,
    marca_id               INT               NOT NULL,
    categoria_bicicleta_id INT               NOT NULL,
    CONSTRAINT PK_Modelo_Bicicleta PRIMARY KEY (modelo_bicicleta_id),
    CONSTRAINT FK_Modelo_Bicicleta_Marca FOREIGN KEY (marca_id)
        REFERENCES IMPACTANTE.Marca (marca_id),
    CONSTRAINT FK_Modelo_Bicicleta_Categoria FOREIGN KEY (categoria_bicicleta_id)
        REFERENCES IMPACTANTE.Categoria_Bicicleta (categoria_bicicleta_id),
    CONSTRAINT UQ_Modelo_Bicicleta UNIQUE (nombre, rodado, cuadro, color, marca_id, categoria_bicicleta_id)
);

CREATE TABLE IMPACTANTE.Producto (
    cod_producto     VARCHAR(255)  NOT NULL,
    nombre           VARCHAR(255)  NOT NULL,
    descripcion      VARCHAR(255)  NOT NULL,
    precio_venta     NUMERIC(38,2) NOT NULL,
    tipo_producto_id INT           NOT NULL,
    CONSTRAINT PK_Producto PRIMARY KEY (cod_producto),
    CONSTRAINT FK_Producto_Tipo FOREIGN KEY (tipo_producto_id)
        REFERENCES IMPACTANTE.Tipo_Producto (tipo_producto_id),
    CONSTRAINT CK_Producto_precio CHECK (precio_venta >= 0)
);

/* Subtipo de Producto: bicicleta a la venta */
CREATE TABLE IMPACTANTE.Bicicleta_Venta (
    cod_producto        VARCHAR(255) NOT NULL,
    modelo_bicicleta_id INT          NOT NULL,
    meses_garantia      INT          NOT NULL,
    CONSTRAINT PK_Bicicleta_Venta PRIMARY KEY (cod_producto),
    CONSTRAINT FK_Bicicleta_Venta_Producto FOREIGN KEY (cod_producto)
        REFERENCES IMPACTANTE.Producto (cod_producto),
    CONSTRAINT FK_Bicicleta_Venta_Modelo FOREIGN KEY (modelo_bicicleta_id)
        REFERENCES IMPACTANTE.Modelo_Bicicleta (modelo_bicicleta_id),
    CONSTRAINT CK_Bicicleta_Venta_garantia CHECK (meses_garantia >= 0)
);

/* Subtipo de Producto: accesorio */
CREATE TABLE IMPACTANTE.Accesorio (
    cod_producto           VARCHAR(255) NOT NULL,
    marca_id               INT          NOT NULL,
    categoria_accesorio_id INT          NOT NULL,
    talle                  VARCHAR(255) NOT NULL,
    color                  VARCHAR(255) NOT NULL,
    CONSTRAINT PK_Accesorio PRIMARY KEY (cod_producto),
    CONSTRAINT FK_Accesorio_Producto FOREIGN KEY (cod_producto)
        REFERENCES IMPACTANTE.Producto (cod_producto),
    CONSTRAINT FK_Accesorio_Marca FOREIGN KEY (marca_id)
        REFERENCES IMPACTANTE.Marca (marca_id),
    CONSTRAINT FK_Accesorio_Categoria FOREIGN KEY (categoria_accesorio_id)
        REFERENCES IMPACTANTE.Categoria_Accesorio (categoria_accesorio_id)
);

CREATE TABLE IMPACTANTE.Repuesto (
    cod_repuesto          VARCHAR(255)  NOT NULL,
    descripcion           VARCHAR(255)  NOT NULL,
    categoria_repuesto_id INT           NOT NULL,
    compatibilidad        VARCHAR(255)  NOT NULL,
    precio                NUMERIC(38,2) NOT NULL,
    CONSTRAINT PK_Repuesto PRIMARY KEY (cod_repuesto),
    CONSTRAINT FK_Repuesto_Categoria FOREIGN KEY (categoria_repuesto_id)
        REFERENCES IMPACTANTE.Categoria_Repuesto (categoria_repuesto_id),
    CONSTRAINT CK_Repuesto_precio CHECK (precio >= 0)
);

/* ---------- Ventas ---------- */
CREATE TABLE IMPACTANTE.Venta (
    nro_venta     INT           NOT NULL,
    cliente_id    INT           NOT NULL,
    empleado_id   INT           NOT NULL,
    fecha_hora    DATETIME2     NOT NULL,
    forma_pago_id INT           NOT NULL,
    local_id      INT           NOT NULL,
    total         NUMERIC(38,2) NOT NULL,
    CONSTRAINT PK_Venta PRIMARY KEY (nro_venta),
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (cliente_id)
        REFERENCES IMPACTANTE.Cliente (cliente_id),
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (empleado_id)
        REFERENCES IMPACTANTE.Empleado (empleado_id),
    CONSTRAINT FK_Venta_Forma_Pago FOREIGN KEY (forma_pago_id)
        REFERENCES IMPACTANTE.Forma_Pago (forma_pago_id),
    CONSTRAINT FK_Venta_Local FOREIGN KEY (local_id)
        REFERENCES IMPACTANTE.[Local] (local_id),
    CONSTRAINT CK_Venta_total CHECK (total >= 0)
);

CREATE TABLE IMPACTANTE.Detalle_Venta (
    detalle_venta_id          INT IDENTITY(1,1) NOT NULL,
    cod_producto              VARCHAR(255)      NOT NULL,
    nro_venta                 INT               NOT NULL,
    cantidad_productos_venta  INT               NOT NULL,
    precio_unitario_venta     NUMERIC(38,2)     NOT NULL,
    subtotal_productos_venta  NUMERIC(38,2)     NOT NULL,
    CONSTRAINT PK_Detalle_Venta PRIMARY KEY (detalle_venta_id),
    CONSTRAINT FK_Detalle_Venta_Producto FOREIGN KEY (cod_producto)
        REFERENCES IMPACTANTE.Producto (cod_producto),
    CONSTRAINT FK_Detalle_Venta_Venta FOREIGN KEY (nro_venta)
        REFERENCES IMPACTANTE.Venta (nro_venta),
    CONSTRAINT CK_Detalle_Venta_cantidad CHECK (cantidad_productos_venta > 0),
    CONSTRAINT CK_Detalle_Venta_precio CHECK (precio_unitario_venta >= 0),
    CONSTRAINT CK_Detalle_Venta_subtotal CHECK (subtotal_productos_venta >= 0)
);

/* ---------- Compras ---------- */
CREATE TABLE IMPACTANTE.Compra (
    nro_compra   INT           NOT NULL,
    fecha_hora   DATETIME2     NOT NULL,
    total        NUMERIC(38,2) NOT NULL,
    proveedor_id INT           NOT NULL,
    empleado_id  INT           NOT NULL,
    local_id     INT           NOT NULL,
    CONSTRAINT PK_Compra PRIMARY KEY (nro_compra),
    CONSTRAINT FK_Compra_Proveedor FOREIGN KEY (proveedor_id)
        REFERENCES IMPACTANTE.Proveedor (proveedor_id),
    CONSTRAINT FK_Compra_Empleado FOREIGN KEY (empleado_id)
        REFERENCES IMPACTANTE.Empleado (empleado_id),
    CONSTRAINT FK_Compra_Local FOREIGN KEY (local_id)
        REFERENCES IMPACTANTE.[Local] (local_id),
    CONSTRAINT CK_Compra_total CHECK (total >= 0)
);

CREATE TABLE IMPACTANTE.Detalle_Compra (
    detalle_compra_id        INT IDENTITY(1,1) NOT NULL,
    nro_compra               INT               NOT NULL,
    cod_producto             VARCHAR(255)      NOT NULL,
    cantidad_producto        INT               NOT NULL,
    precio_unitario_producto NUMERIC(38,2)     NOT NULL,
    subtotal                 NUMERIC(38,2)     NOT NULL,
    CONSTRAINT PK_Detalle_Compra PRIMARY KEY (detalle_compra_id),
    CONSTRAINT FK_Detalle_Compra_Compra FOREIGN KEY (nro_compra)
        REFERENCES IMPACTANTE.Compra (nro_compra),
    CONSTRAINT FK_Detalle_Compra_Producto FOREIGN KEY (cod_producto)
        REFERENCES IMPACTANTE.Producto (cod_producto),
    CONSTRAINT CK_Detalle_Compra_cantidad CHECK (cantidad_producto > 0),
    CONSTRAINT CK_Detalle_Compra_precio CHECK (precio_unitario_producto >= 0),
    CONSTRAINT CK_Detalle_Compra_subtotal CHECK (subtotal >= 0)
);

/* ---------- Alquileres ---------- */
CREATE TABLE IMPACTANTE.Bicicleta_Alquiler (
    nro_serie               VARCHAR(255)  NOT NULL,
    modelo_bicicleta_id     INT           NOT NULL,
    precio_alquiler_hora    NUMERIC(38,2) NOT NULL,
    precio_alquiler_dia     NUMERIC(38,2) NOT NULL,
    estado_bici_alquiler_id INT           NOT NULL,
    local_id                INT           NOT NULL,
    CONSTRAINT PK_Bicicleta_Alquiler PRIMARY KEY (nro_serie),
    CONSTRAINT FK_Bici_Alquiler_Modelo FOREIGN KEY (modelo_bicicleta_id)
        REFERENCES IMPACTANTE.Modelo_Bicicleta (modelo_bicicleta_id),
    CONSTRAINT FK_Bici_Alquiler_Estado FOREIGN KEY (estado_bici_alquiler_id)
        REFERENCES IMPACTANTE.Estado_Bici_Alquiler (estado_bici_alquiler_id),
    CONSTRAINT FK_Bici_Alquiler_Local FOREIGN KEY (local_id)
        REFERENCES IMPACTANTE.[Local] (local_id),
    CONSTRAINT CK_Bici_Alquiler_precio_hora CHECK (precio_alquiler_hora >= 0),
    CONSTRAINT CK_Bici_Alquiler_precio_dia CHECK (precio_alquiler_dia >= 0)
);

CREATE TABLE IMPACTANTE.Alquiler (
    nro_alquiler                  INT           NOT NULL,
    cliente_id                    INT           NOT NULL,
    empleado_id                   INT           NOT NULL,
    nro_serie                     VARCHAR(255)  NOT NULL,
    fecha_hora_inicio             DATETIME2     NOT NULL,
    fecha_hora_esperada_devolucion DATETIME2    NOT NULL,
    fecha_hora_real_devolucion    DATETIME2     NULL,
    estado_alquiler_id            INT           NOT NULL,
    local_id                      INT           NOT NULL,
    forma_pago_id                 INT           NOT NULL,
    importe_total                 NUMERIC(38,2) NOT NULL,
    CONSTRAINT PK_Alquiler PRIMARY KEY (nro_alquiler),
    CONSTRAINT FK_Alquiler_Cliente FOREIGN KEY (cliente_id)
        REFERENCES IMPACTANTE.Cliente (cliente_id),
    CONSTRAINT FK_Alquiler_Empleado FOREIGN KEY (empleado_id)
        REFERENCES IMPACTANTE.Empleado (empleado_id),
    CONSTRAINT FK_Alquiler_Bicicleta FOREIGN KEY (nro_serie)
        REFERENCES IMPACTANTE.Bicicleta_Alquiler (nro_serie),
    CONSTRAINT FK_Alquiler_Estado FOREIGN KEY (estado_alquiler_id)
        REFERENCES IMPACTANTE.Estado_Alquiler (estado_alquiler_id),
    CONSTRAINT FK_Alquiler_Local FOREIGN KEY (local_id)
        REFERENCES IMPACTANTE.[Local] (local_id),
    CONSTRAINT FK_Alquiler_Forma_Pago FOREIGN KEY (forma_pago_id)
        REFERENCES IMPACTANTE.Forma_Pago (forma_pago_id),
    CONSTRAINT CK_Alquiler_fechas CHECK (
        fecha_hora_esperada_devolucion >= fecha_hora_inicio
        AND (fecha_hora_real_devolucion IS NULL OR fecha_hora_real_devolucion >= fecha_hora_inicio)
    ),
    CONSTRAINT CK_Alquiler_importe CHECK (importe_total >= 0)
);

/* ---------- Reparaciones ---------- */
CREATE TABLE IMPACTANTE.Reparacion (
    nro_reparacion              INT           NOT NULL,
    cliente_id                  INT           NOT NULL,
    empleado_id                 INT           NOT NULL,
    modelo_bicicleta_id         INT           NOT NULL,
    nro_serie_bicicleta         VARCHAR(255)  NOT NULL,
    fecha_hora_ingreso          DATETIME2     NOT NULL,
    fecha_hora_estimada_entrega DATETIME2     NOT NULL,
    fecha_hora_real_entrega     DATETIME2     NULL,
    diagnostico                 VARCHAR(255)  NOT NULL,
    estado_reparacion_id        INT           NOT NULL,
    precio_mano_obra            NUMERIC(38,2) NOT NULL,
    precio_repuestos            NUMERIC(38,2) NOT NULL,
    local_id                    INT           NOT NULL,
    precio_total                NUMERIC(38,2) NOT NULL,
    CONSTRAINT PK_Reparacion PRIMARY KEY (nro_reparacion),
    CONSTRAINT FK_Reparacion_Cliente FOREIGN KEY (cliente_id)
        REFERENCES IMPACTANTE.Cliente (cliente_id),
    CONSTRAINT FK_Reparacion_Empleado FOREIGN KEY (empleado_id)
        REFERENCES IMPACTANTE.Empleado (empleado_id),
    CONSTRAINT FK_Reparacion_Modelo FOREIGN KEY (modelo_bicicleta_id)
        REFERENCES IMPACTANTE.Modelo_Bicicleta (modelo_bicicleta_id),
    CONSTRAINT FK_Reparacion_Estado FOREIGN KEY (estado_reparacion_id)
        REFERENCES IMPACTANTE.Estado_Reparacion (estado_reparacion_id),
    CONSTRAINT FK_Reparacion_Local FOREIGN KEY (local_id)
        REFERENCES IMPACTANTE.[Local] (local_id),
    CONSTRAINT CK_Reparacion_fechas CHECK (
        fecha_hora_estimada_entrega >= fecha_hora_ingreso
        AND (fecha_hora_real_entrega IS NULL OR fecha_hora_real_entrega >= fecha_hora_ingreso)
    ),
    CONSTRAINT CK_Reparacion_precios CHECK (
        precio_mano_obra >= 0 AND precio_repuestos >= 0 AND precio_total >= 0
    )
);

CREATE TABLE IMPACTANTE.Detalle_Reparacion (
    detalle_reparacion_id INT IDENTITY(1,1) NOT NULL,
    nro_reparacion        INT               NOT NULL,
    cod_repuesto          VARCHAR(255)      NOT NULL,
    cantidad              INT               NOT NULL,
    subtotal              NUMERIC(38,2)     NOT NULL,
    precio_unitario       NUMERIC(38,2)     NOT NULL,
    CONSTRAINT PK_Detalle_Reparacion PRIMARY KEY (detalle_reparacion_id),
    CONSTRAINT FK_Detalle_Reparacion_Reparacion FOREIGN KEY (nro_reparacion)
        REFERENCES IMPACTANTE.Reparacion (nro_reparacion),
    CONSTRAINT FK_Detalle_Reparacion_Repuesto FOREIGN KEY (cod_repuesto)
        REFERENCES IMPACTANTE.Repuesto (cod_repuesto),
    CONSTRAINT CK_Detalle_Reparacion_cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_Detalle_Reparacion_precio CHECK (precio_unitario >= 0),
    CONSTRAINT CK_Detalle_Reparacion_subtotal CHECK (subtotal >= 0)
);
GO

/* ============================================================================
   4. STORED PROCEDURES DE MIGRACION
   ============================================================================ */

/* ---------- 4.1 Provincias y Localidades ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_ubicaciones
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Provincia (nombre)
    SELECT t.provincia
    FROM (
        SELECT Cliente_Provincia   AS provincia FROM gd_esquema.Maestra
        UNION
        SELECT Empleado_Provincia               FROM gd_esquema.Maestra
        UNION
        SELECT Local_Provincia                  FROM gd_esquema.Maestra
        UNION
        SELECT Proveedor_Provincia              FROM gd_esquema.Maestra
    ) t
    WHERE t.provincia IS NOT NULL;

    INSERT INTO IMPACTANTE.Localidad (nombre, provincia_id)
    SELECT t.localidad, p.provincia_id
    FROM (
        SELECT Cliente_Localidad   AS localidad, Cliente_Provincia   AS provincia FROM gd_esquema.Maestra
        UNION
        SELECT Empleado_Localidad,               Empleado_Provincia               FROM gd_esquema.Maestra
        UNION
        SELECT Local_Localidad,                  Local_Provincia                  FROM gd_esquema.Maestra
        UNION
        SELECT Proveedor_Localidad,              Proveedor_Provincia              FROM gd_esquema.Maestra
    ) t
    JOIN IMPACTANTE.Provincia p ON p.nombre = t.provincia
    WHERE t.localidad IS NOT NULL;
END;
GO

/* ---------- 4.2 Catalogos (marcas, categorias, tipos, estados, formas de pago) ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_catalogos
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Marca (nombre)
    SELECT DISTINCT Marca_Marca
    FROM gd_esquema.Maestra
    WHERE Marca_Marca IS NOT NULL;

    INSERT INTO IMPACTANTE.Categoria_Bicicleta (nombre)
    SELECT DISTINCT Categoria_Bicicleta_Categoria_Bicicleta
    FROM gd_esquema.Maestra
    WHERE Categoria_Bicicleta_Categoria_Bicicleta IS NOT NULL;

    INSERT INTO IMPACTANTE.Categoria_Accesorio (nombre)
    SELECT DISTINCT Categoria_Accesorios_Categoria_Accesorio
    FROM gd_esquema.Maestra
    WHERE Categoria_Accesorios_Categoria_Accesorio IS NOT NULL;

    INSERT INTO IMPACTANTE.Categoria_Repuesto (nombre)
    SELECT DISTINCT Categoria_Repuestos_Categoria_Respuesto
    FROM gd_esquema.Maestra
    WHERE Categoria_Repuestos_Categoria_Respuesto IS NOT NULL;

    INSERT INTO IMPACTANTE.Tipo_Producto (tipo_producto)
    SELECT DISTINCT Tipo_Producto_Tipo_Producto
    FROM gd_esquema.Maestra
    WHERE Tipo_Producto_Tipo_Producto IS NOT NULL;

    INSERT INTO IMPACTANTE.Forma_Pago (descripcion)
    SELECT DISTINCT Forma_Pago_Forma_Pago
    FROM gd_esquema.Maestra
    WHERE Forma_Pago_Forma_Pago IS NOT NULL;

    INSERT INTO IMPACTANTE.Estado_Reparacion (estado_reparacion)
    SELECT DISTINCT Estado_Reparacion_Estado_Reparacion
    FROM gd_esquema.Maestra
    WHERE Estado_Reparacion_Estado_Reparacion IS NOT NULL;

    INSERT INTO IMPACTANTE.Estado_Alquiler (estado_alquiler)
    SELECT DISTINCT Estado_Alquiler_Estado_Alquiler
    FROM gd_esquema.Maestra
    WHERE Estado_Alquiler_Estado_Alquiler IS NOT NULL;

    INSERT INTO IMPACTANTE.Estado_Bici_Alquiler (estado_bici_alquiler)
    SELECT DISTINCT Estado_Bici_Alquiler_Estado_Bici_Alquiler
    FROM gd_esquema.Maestra
    WHERE Estado_Bici_Alquiler_Estado_Bici_Alquiler IS NOT NULL;
END;
GO

/* ---------- 4.3 Local ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_local
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.[Local] (nombre, telefono, email, direccion, localidad_id)
    SELECT x.nombre, x.telefono, x.email, x.direccion, x.localidad_id
    FROM (
        SELECT  m.Local_Nombre_Local     AS nombre,
                m.Local_Telefono_Local   AS telefono,
                m.Local_Email_Local      AS email,
                m.Local_Direccion_Local  AS direccion,
                l.localidad_id,
                ROW_NUMBER() OVER (PARTITION BY m.Local_Nombre_Local, m.Local_Direccion_Local
                                   ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.Provincia p  ON p.nombre = m.Local_Provincia
        JOIN IMPACTANTE.Localidad l  ON l.nombre = m.Local_Localidad AND l.provincia_id = p.provincia_id
        WHERE m.Local_Nombre_Local IS NOT NULL
          AND m.Local_Direccion_Local IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.4 Empleado ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_empleado
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Empleado
        (local_id, nombre, apellido, fecha_nacimiento, dni, puesto, fecha_ingreso,
         telefono, email, domicilio, localidad_id)
    SELECT x.local_id, x.nombre, x.apellido, x.fecha_nacimiento, x.dni, x.puesto, x.fecha_ingreso,
           x.telefono, x.email, x.domicilio, x.localidad_id
    FROM (
        SELECT  lo.local_id,
                m.Empleado_Nombre_Empleado      AS nombre,
                m.Empleado_Apellido_Empleado    AS apellido,
                m.Empleado_Fecha_Nac_Empleado   AS fecha_nacimiento,
                m.Empleado_Dni_Empleado         AS dni,
                m.Empleado_Puesto_Empleado      AS puesto,
                m.Empleado_Fecha_Ingreso_Empleado AS fecha_ingreso,
                m.Empleado_Telefono_Empleado    AS telefono,
                m.Empleado_Email_Empleado       AS email,
                m.Empleado_Domicilio_Empleado   AS domicilio,
                le.localidad_id,
                ROW_NUMBER() OVER (PARTITION BY m.Empleado_Dni_Empleado ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.[Local] lo
              ON lo.nombre = m.Local_Nombre_Local AND lo.direccion = m.Local_Direccion_Local
        JOIN IMPACTANTE.Provincia pe ON pe.nombre = m.Empleado_Provincia
        JOIN IMPACTANTE.Localidad le ON le.nombre = m.Empleado_Localidad AND le.provincia_id = pe.provincia_id
        WHERE m.Empleado_Dni_Empleado IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.5 Cliente ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_cliente
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Cliente
        (nombre, apellido, dni, telefono, email, domicilio, localidad_id, fecha_nacimiento)
    SELECT x.nombre, x.apellido, x.dni, x.telefono, x.email, x.domicilio, x.localidad_id, x.fecha_nacimiento
    FROM (
        SELECT  m.Cliente_Nombre_Cliente      AS nombre,
                m.Cliente_Apellido_Cliente    AS apellido,
                m.Cliente_Dni_Cliente         AS dni,
                m.Cliente_Telefono_Cliente    AS telefono,
                m.Cliente_Email_Cliente       AS email,
                m.Cliente_Direccion_Cliente   AS domicilio,
                l.localidad_id,
                m.Cliente_Fecha_Nacimiento_Cliente AS fecha_nacimiento,
                ROW_NUMBER() OVER (PARTITION BY m.Cliente_Dni_Cliente ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.Provincia p ON p.nombre = m.Cliente_Provincia
        JOIN IMPACTANTE.Localidad l ON l.nombre = m.Cliente_Localidad AND l.provincia_id = p.provincia_id
        WHERE m.Cliente_Dni_Cliente IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.6 Proveedor ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_proveedor
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Proveedor
        (razon_social, cuit, telefono, email, direccion, localidad_id)
    SELECT x.razon_social, x.cuit, x.telefono, x.email, x.direccion, x.localidad_id
    FROM (
        SELECT  m.Proveedor_Razon_Social_Proveedor AS razon_social,
                m.Proveedor_Cuit_Proveedor         AS cuit,
                m.Proveedor_Telefono_Proveedor     AS telefono,
                m.Proveedor_Email_Proveedor        AS email,
                m.Proveedor_Direccion_Proveedor    AS direccion,
                l.localidad_id,
                ROW_NUMBER() OVER (PARTITION BY m.Proveedor_Cuit_Proveedor ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.Provincia p ON p.nombre = m.Proveedor_Provincia
        JOIN IMPACTANTE.Localidad l ON l.nombre = m.Proveedor_Localidad AND l.provincia_id = p.provincia_id
        WHERE m.Proveedor_Cuit_Proveedor IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.7 Modelo_Bicicleta ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_modelo_bicicleta
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Modelo_Bicicleta
        (nombre, rodado, cuadro, color, marca_id, categoria_bicicleta_id)
    SELECT DISTINCT
            m.Modelo_Bicicleta_Modelo_Bicicleta,
            m.Modelo_Bicicleta_Rodado_Modelo_Bicicleta,
            m.Modelo_Bicicleta_Cuadro_Modelo_Bicicleta,
            m.Modelo_Bicicleta_Color_Modelo_Bicicleta,
            mk.marca_id,
            cb.categoria_bicicleta_id
    FROM gd_esquema.Maestra m
    JOIN IMPACTANTE.Marca mk ON mk.nombre = m.Marca_Marca
    JOIN IMPACTANTE.Categoria_Bicicleta cb ON cb.nombre = m.Categoria_Bicicleta_Categoria_Bicicleta
    WHERE m.Modelo_Bicicleta_Modelo_Bicicleta IS NOT NULL;
END;
GO

/* ---------- 4.8 Producto ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_producto
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Producto (cod_producto, nombre, descripcion, precio_venta, tipo_producto_id)
    SELECT x.cod_producto, x.nombre, x.descripcion, x.precio_venta, x.tipo_producto_id
    FROM (
        SELECT  m.Producto_Cod_Producto          AS cod_producto,
                m.Producto_Nombre_Producto       AS nombre,
                m.Producto_Descripcion_Producto  AS descripcion,
                m.Producto_Precio_Venta_Producto AS precio_venta,
                tp.tipo_producto_id,
                ROW_NUMBER() OVER (PARTITION BY m.Producto_Cod_Producto ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.Tipo_Producto tp ON tp.tipo_producto = m.Tipo_Producto_Tipo_Producto
        WHERE m.Producto_Cod_Producto IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.9 Bicicleta_Venta (subtipo de Producto) ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_bicicleta_venta
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Bicicleta_Venta (cod_producto, modelo_bicicleta_id, meses_garantia)
    SELECT x.cod_producto, x.modelo_bicicleta_id, x.meses_garantia
    FROM (
        SELECT  m.Producto_Cod_Producto AS cod_producto,
                vm.modelo_bicicleta_id,
                m.Bicicleta_Venta_Meses_Garantia_Bici_Venta AS meses_garantia,
                ROW_NUMBER() OVER (PARTITION BY m.Producto_Cod_Producto ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.vw_Maestra_Modelo vm ON vm.Id = m.Id
        WHERE m.Producto_Cod_Producto IS NOT NULL
          AND m.Bicicleta_Venta_Meses_Garantia_Bici_Venta IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.10 Accesorio (subtipo de Producto) ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_accesorio
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Accesorio (cod_producto, marca_id, categoria_accesorio_id, talle, color)
    SELECT x.cod_producto, x.marca_id, x.categoria_accesorio_id, x.talle, x.color
    FROM (
        SELECT  m.Producto_Cod_Producto AS cod_producto,
                mk.marca_id,
                ca.categoria_accesorio_id,
                m.Accesorio_Talle_Accesorio AS talle,
                m.Accesorio_Color_Accesorio AS color,
                ROW_NUMBER() OVER (PARTITION BY m.Producto_Cod_Producto ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.Marca mk ON mk.nombre = m.Marca_Marca
        JOIN IMPACTANTE.Categoria_Accesorio ca ON ca.nombre = m.Categoria_Accesorios_Categoria_Accesorio
        WHERE m.Producto_Cod_Producto IS NOT NULL
          AND m.Categoria_Accesorios_Categoria_Accesorio IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.11 Repuesto ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_repuesto
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Repuesto (cod_repuesto, descripcion, categoria_repuesto_id, compatibilidad, precio)
    SELECT x.cod_repuesto, x.descripcion, x.categoria_repuesto_id, x.compatibilidad, x.precio
    FROM (
        SELECT  m.Repuesto_Cod_Repuesto           AS cod_repuesto,
                m.Repuesto_Desc_Repuesto          AS descripcion,
                cr.categoria_repuesto_id,
                m.Repuesto_Compatibilidad_Repuesto AS compatibilidad,
                m.Repuesto_Precio_Repuesto        AS precio,
                ROW_NUMBER() OVER (PARTITION BY m.Repuesto_Cod_Repuesto ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.Categoria_Repuesto cr ON cr.nombre = m.Categoria_Repuestos_Categoria_Respuesto
        WHERE m.Repuesto_Cod_Repuesto IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.12 Venta ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_venta
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Venta (nro_venta, cliente_id, empleado_id, fecha_hora, forma_pago_id, local_id, total)
    SELECT x.nro_venta, x.cliente_id, x.empleado_id, x.fecha_hora, x.forma_pago_id, x.local_id, x.total
    FROM (
        SELECT  m.Venta_Nro_Venta       AS nro_venta,
                c.cliente_id,
                e.empleado_id,
                m.Venta_Fecha_Hora_Venta AS fecha_hora,
                fp.forma_pago_id,
                lo.local_id,
                m.Venta_Total_Venta     AS total,
                ROW_NUMBER() OVER (PARTITION BY m.Venta_Nro_Venta ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.Cliente c    ON c.dni = m.Cliente_Dni_Cliente
        JOIN IMPACTANTE.Empleado e   ON e.dni = m.Empleado_Dni_Empleado
        JOIN IMPACTANTE.Forma_Pago fp ON fp.descripcion = m.Forma_Pago_Forma_Pago
        JOIN IMPACTANTE.[Local] lo
              ON lo.nombre = m.Local_Nombre_Local AND lo.direccion = m.Local_Direccion_Local
        WHERE m.Venta_Nro_Venta IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.13 Detalle_Venta ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_detalle_venta
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Detalle_Venta
        (cod_producto, nro_venta, cantidad_productos_venta, precio_unitario_venta, subtotal_productos_venta)
    SELECT  m.Producto_Cod_Producto,
            m.Venta_Nro_Venta,
            m.Detalle_Venta_Cantidad_Prod_Venta,
            m.Detalle_Venta_Precio_Unitario_Prod_Venta,
            m.Detalle_Venta_Subtotal_Prod_Venta
    FROM gd_esquema.Maestra m
    WHERE m.Venta_Nro_Venta IS NOT NULL
      AND m.Producto_Cod_Producto IS NOT NULL
      AND m.Detalle_Venta_Cantidad_Prod_Venta IS NOT NULL
    ORDER BY m.Id;
END;
GO

/* ---------- 4.14 Compra ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_compra
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Compra (nro_compra, fecha_hora, total, proveedor_id, empleado_id, local_id)
    SELECT x.nro_compra, x.fecha_hora, x.total, x.proveedor_id, x.empleado_id, x.local_id
    FROM (
        SELECT  m.Compra_Nro_Compra   AS nro_compra,
                m.Compra_Fecha_Compra AS fecha_hora,
                m.Compra_Total_Compra AS total,
                pr.proveedor_id,
                e.empleado_id,
                lo.local_id,
                ROW_NUMBER() OVER (PARTITION BY m.Compra_Nro_Compra ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.Proveedor pr ON pr.cuit = m.Proveedor_Cuit_Proveedor
        JOIN IMPACTANTE.Empleado e   ON e.dni = m.Empleado_Dni_Empleado
        JOIN IMPACTANTE.[Local] lo
              ON lo.nombre = m.Local_Nombre_Local AND lo.direccion = m.Local_Direccion_Local
        WHERE m.Compra_Nro_Compra IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.15 Detalle_Compra ---------- */
/* La maestra no trae subtotal de compra: se calcula como cantidad * precio unitario */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_detalle_compra
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Detalle_Compra
        (nro_compra, cod_producto, cantidad_producto, precio_unitario_producto, subtotal)
    SELECT  m.Compra_Nro_Compra,
            m.Producto_Cod_Producto,
            m.Detalle_Compra_Cantidad_Prod_Compra,
            m.Detalle_Compra_Precio_Unitario_Prod_Compra,
            m.Detalle_Compra_Cantidad_Prod_Compra * m.Detalle_Compra_Precio_Unitario_Prod_Compra
    FROM gd_esquema.Maestra m
    WHERE m.Compra_Nro_Compra IS NOT NULL
      AND m.Producto_Cod_Producto IS NOT NULL
      AND m.Detalle_Compra_Cantidad_Prod_Compra IS NOT NULL
    ORDER BY m.Id;
END;
GO

/* ---------- 4.16 Bicicleta_Alquiler ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_bicicleta_alquiler
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Bicicleta_Alquiler
        (nro_serie, modelo_bicicleta_id, precio_alquiler_hora, precio_alquiler_dia,
         estado_bici_alquiler_id, local_id)
    SELECT x.nro_serie, x.modelo_bicicleta_id, x.precio_hora, x.precio_dia,
           x.estado_bici_alquiler_id, x.local_id
    FROM (
        SELECT  m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler    AS nro_serie,
                vm.modelo_bicicleta_id,
                m.Bicicleta_Alquiler_Precio_Bici_Alquiler_Hora  AS precio_hora,
                m.Bicicleta_Alquiler_Precio_Bici_Alquiler_Dia   AS precio_dia,
                eb.estado_bici_alquiler_id,
                lo.local_id,
                ROW_NUMBER() OVER (PARTITION BY m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler
                                   ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.vw_Maestra_Modelo vm ON vm.Id = m.Id
        JOIN IMPACTANTE.Estado_Bici_Alquiler eb
              ON eb.estado_bici_alquiler = m.Estado_Bici_Alquiler_Estado_Bici_Alquiler
        JOIN IMPACTANTE.[Local] lo
              ON lo.nombre = m.Local_Nombre_Local AND lo.direccion = m.Local_Direccion_Local
        WHERE m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.17 Alquiler ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_alquiler
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Alquiler
        (nro_alquiler, cliente_id, empleado_id, nro_serie, fecha_hora_inicio,
         fecha_hora_esperada_devolucion, fecha_hora_real_devolucion, estado_alquiler_id,
         local_id, forma_pago_id, importe_total)
    SELECT x.nro_alquiler, x.cliente_id, x.empleado_id, x.nro_serie, x.fecha_inicio,
           x.fecha_esperada, x.fecha_real, x.estado_alquiler_id,
           x.local_id, x.forma_pago_id, x.importe_total
    FROM (
        SELECT  m.Alquiler_Nro_Alquiler                  AS nro_alquiler,
                c.cliente_id,
                e.empleado_id,
                m.Bicicleta_Alquiler_Nro_Serie_Bici_Alquiler AS nro_serie,
                m.Alquiler_Fecha_Inicio_Alquiler         AS fecha_inicio,
                m.Alquiler_Fecha_Fin_Pactada_Alquiler    AS fecha_esperada,
                m.Alquiler_Fecha_Devolucion_Real_Alquiler AS fecha_real,
                ea.estado_alquiler_id,
                lo.local_id,
                fp.forma_pago_id,
                m.Alquiler_Importe_Total_Alquiler        AS importe_total,
                ROW_NUMBER() OVER (PARTITION BY m.Alquiler_Nro_Alquiler ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.Cliente c     ON c.dni = m.Cliente_Dni_Cliente
        JOIN IMPACTANTE.Empleado e    ON e.dni = m.Empleado_Dni_Empleado
        JOIN IMPACTANTE.Estado_Alquiler ea ON ea.estado_alquiler = m.Estado_Alquiler_Estado_Alquiler
        JOIN IMPACTANTE.Forma_Pago fp ON fp.descripcion = m.Forma_Pago_Forma_Pago
        JOIN IMPACTANTE.[Local] lo
              ON lo.nombre = m.Local_Nombre_Local AND lo.direccion = m.Local_Direccion_Local
        WHERE m.Alquiler_Nro_Alquiler IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.18 Reparacion ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_reparacion
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Reparacion
        (nro_reparacion, cliente_id, empleado_id, modelo_bicicleta_id, nro_serie_bicicleta,
         fecha_hora_ingreso, fecha_hora_estimada_entrega, fecha_hora_real_entrega,
         diagnostico, estado_reparacion_id, precio_mano_obra, precio_repuestos,
         local_id, precio_total)
    SELECT x.nro_reparacion, x.cliente_id, x.empleado_id, x.modelo_bicicleta_id, x.nro_serie,
           x.fecha_ingreso, x.fecha_estimada, x.fecha_real,
           x.diagnostico, x.estado_reparacion_id, x.precio_mano_obra, x.precio_repuestos,
           x.local_id, x.precio_total
    FROM (
        SELECT  m.Reparacion_Nro_Reparacion              AS nro_reparacion,
                c.cliente_id,
                e.empleado_id,
                vm.modelo_bicicleta_id,
                m.Reparacion_Numero_Serie_Bici_Reparacion AS nro_serie,
                m.Reparacion_Fecha_Ingreso_Reparacion    AS fecha_ingreso,
                m.Reparacion_Fecha_Entrega_Estimada_Reparacion AS fecha_estimada,
                m.Reparacion_Fecha_Entrega_Real_Reparacion     AS fecha_real,
                m.Reparacion_Diagnostico_Reparacion      AS diagnostico,
                er.estado_reparacion_id,
                m.Reparacion_Precio_Mano_Obra_Reparacion AS precio_mano_obra,
                m.Reparacion_Precio_Repuestos_Reparacion AS precio_repuestos,
                lo.local_id,
                m.Reparacion_Precio_Total_Reparacion     AS precio_total,
                ROW_NUMBER() OVER (PARTITION BY m.Reparacion_Nro_Reparacion ORDER BY m.Id) AS rn
        FROM gd_esquema.Maestra m
        JOIN IMPACTANTE.Cliente c     ON c.dni = m.Cliente_Dni_Cliente
        JOIN IMPACTANTE.Empleado e    ON e.dni = m.Empleado_Dni_Empleado
        JOIN IMPACTANTE.vw_Maestra_Modelo vm ON vm.Id = m.Id
        JOIN IMPACTANTE.Estado_Reparacion er
              ON er.estado_reparacion = m.Estado_Reparacion_Estado_Reparacion
        JOIN IMPACTANTE.[Local] lo
              ON lo.nombre = m.Local_Nombre_Local AND lo.direccion = m.Local_Direccion_Local
        WHERE m.Reparacion_Nro_Reparacion IS NOT NULL
    ) x
    WHERE x.rn = 1;
END;
GO

/* ---------- 4.19 Detalle_Reparacion ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_detalle_reparacion
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO IMPACTANTE.Detalle_Reparacion
        (nro_reparacion, cod_repuesto, cantidad, subtotal, precio_unitario)
    SELECT  m.Reparacion_Nro_Reparacion,
            m.Repuesto_Cod_Repuesto,
            m.Detalle_Reparacion_Cantidad_Repuesto,
            m.Detalle_Reparacion_Subtotal_Repuesto,
            m.Detalle_Reparacion_Precio_Unitario_Repuesto
    FROM gd_esquema.Maestra m
    WHERE m.Reparacion_Nro_Reparacion IS NOT NULL
      AND m.Repuesto_Cod_Repuesto IS NOT NULL
      AND m.Detalle_Reparacion_Cantidad_Repuesto IS NOT NULL
    ORDER BY m.Id;
END;
GO

/* ---------- 4.20 Orquestador: ejecuta todo en el orden correcto ---------- */
CREATE OR ALTER PROCEDURE IMPACTANTE.migrar_datos
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC IMPACTANTE.migrar_ubicaciones;
        EXEC IMPACTANTE.migrar_catalogos;
        EXEC IMPACTANTE.migrar_local;
        EXEC IMPACTANTE.migrar_empleado;
        EXEC IMPACTANTE.migrar_cliente;
        EXEC IMPACTANTE.migrar_proveedor;
        EXEC IMPACTANTE.migrar_modelo_bicicleta;
        EXEC IMPACTANTE.migrar_producto;
        EXEC IMPACTANTE.migrar_bicicleta_venta;
        EXEC IMPACTANTE.migrar_accesorio;
        EXEC IMPACTANTE.migrar_repuesto;
        EXEC IMPACTANTE.migrar_venta;
        EXEC IMPACTANTE.migrar_detalle_venta;
        EXEC IMPACTANTE.migrar_compra;
        EXEC IMPACTANTE.migrar_detalle_compra;
        EXEC IMPACTANTE.migrar_bicicleta_alquiler;
        EXEC IMPACTANTE.migrar_alquiler;
        EXEC IMPACTANTE.migrar_reparacion;
        EXEC IMPACTANTE.migrar_detalle_reparacion;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

/* ============================================================================
   5. EJECUCION DE LA MIGRACION
   ============================================================================ */
EXEC IMPACTANTE.migrar_datos;
GO

/* ============================================================================
   6. TRIGGERS
   (se crean despues de migrar para no interferir con la carga inicial)
   ============================================================================ */

/* Un producto no puede ser a la vez bicicleta y accesorio (subtipos excluyentes) */
CREATE OR ALTER TRIGGER IMPACTANTE.trg_Bicicleta_Venta_Exclusivo
ON IMPACTANTE.Bicicleta_Venta
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1
               FROM inserted i
               JOIN IMPACTANTE.Accesorio a ON a.cod_producto = i.cod_producto)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, 'El producto ya esta registrado como Accesorio; no puede ser tambien Bicicleta_Venta.', 1;
    END;
END;
GO

CREATE OR ALTER TRIGGER IMPACTANTE.trg_Accesorio_Exclusivo
ON IMPACTANTE.Accesorio
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1
               FROM inserted i
               JOIN IMPACTANTE.Bicicleta_Venta b ON b.cod_producto = i.cod_producto)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50002, 'El producto ya esta registrado como Bicicleta_Venta; no puede ser tambien Accesorio.', 1;
    END;
END;
GO

/* ============================================================================
   7. INDICES (acceso eficiente por claves foraneas y campos de busqueda)
   ============================================================================ */

-- Ubicacion
CREATE NONCLUSTERED INDEX IX_Localidad_provincia      ON IMPACTANTE.Localidad (provincia_id);
CREATE NONCLUSTERED INDEX IX_Local_localidad          ON IMPACTANTE.[Local] (localidad_id);
CREATE NONCLUSTERED INDEX IX_Empleado_local           ON IMPACTANTE.Empleado (local_id);
CREATE NONCLUSTERED INDEX IX_Empleado_localidad       ON IMPACTANTE.Empleado (localidad_id);
CREATE NONCLUSTERED INDEX IX_Cliente_localidad        ON IMPACTANTE.Cliente (localidad_id);
CREATE NONCLUSTERED INDEX IX_Proveedor_localidad      ON IMPACTANTE.Proveedor (localidad_id);

-- Productos
CREATE NONCLUSTERED INDEX IX_Producto_tipo            ON IMPACTANTE.Producto (tipo_producto_id);
CREATE NONCLUSTERED INDEX IX_Modelo_marca             ON IMPACTANTE.Modelo_Bicicleta (marca_id);
CREATE NONCLUSTERED INDEX IX_Modelo_categoria         ON IMPACTANTE.Modelo_Bicicleta (categoria_bicicleta_id);
CREATE NONCLUSTERED INDEX IX_Bici_Venta_modelo        ON IMPACTANTE.Bicicleta_Venta (modelo_bicicleta_id);
CREATE NONCLUSTERED INDEX IX_Accesorio_marca          ON IMPACTANTE.Accesorio (marca_id);
CREATE NONCLUSTERED INDEX IX_Accesorio_categoria      ON IMPACTANTE.Accesorio (categoria_accesorio_id);
CREATE NONCLUSTERED INDEX IX_Repuesto_categoria       ON IMPACTANTE.Repuesto (categoria_repuesto_id);

-- Ventas
CREATE NONCLUSTERED INDEX IX_Venta_cliente            ON IMPACTANTE.Venta (cliente_id);
CREATE NONCLUSTERED INDEX IX_Venta_empleado           ON IMPACTANTE.Venta (empleado_id);
CREATE NONCLUSTERED INDEX IX_Venta_local_fecha        ON IMPACTANTE.Venta (local_id, fecha_hora);
CREATE NONCLUSTERED INDEX IX_Venta_forma_pago         ON IMPACTANTE.Venta (forma_pago_id);
CREATE NONCLUSTERED INDEX IX_Detalle_Venta_venta      ON IMPACTANTE.Detalle_Venta (nro_venta) INCLUDE (cod_producto, cantidad_productos_venta, subtotal_productos_venta);
CREATE NONCLUSTERED INDEX IX_Detalle_Venta_producto   ON IMPACTANTE.Detalle_Venta (cod_producto);

-- Compras
CREATE NONCLUSTERED INDEX IX_Compra_proveedor         ON IMPACTANTE.Compra (proveedor_id);
CREATE NONCLUSTERED INDEX IX_Compra_empleado          ON IMPACTANTE.Compra (empleado_id);
CREATE NONCLUSTERED INDEX IX_Compra_local_fecha       ON IMPACTANTE.Compra (local_id, fecha_hora);
CREATE NONCLUSTERED INDEX IX_Detalle_Compra_compra    ON IMPACTANTE.Detalle_Compra (nro_compra) INCLUDE (cod_producto, cantidad_producto, subtotal);
CREATE NONCLUSTERED INDEX IX_Detalle_Compra_producto  ON IMPACTANTE.Detalle_Compra (cod_producto);

-- Alquileres
CREATE NONCLUSTERED INDEX IX_Bici_Alquiler_modelo     ON IMPACTANTE.Bicicleta_Alquiler (modelo_bicicleta_id);
CREATE NONCLUSTERED INDEX IX_Bici_Alquiler_estado     ON IMPACTANTE.Bicicleta_Alquiler (estado_bici_alquiler_id);
CREATE NONCLUSTERED INDEX IX_Bici_Alquiler_local      ON IMPACTANTE.Bicicleta_Alquiler (local_id);
CREATE NONCLUSTERED INDEX IX_Alquiler_cliente         ON IMPACTANTE.Alquiler (cliente_id);
CREATE NONCLUSTERED INDEX IX_Alquiler_empleado        ON IMPACTANTE.Alquiler (empleado_id);
CREATE NONCLUSTERED INDEX IX_Alquiler_bicicleta       ON IMPACTANTE.Alquiler (nro_serie, fecha_hora_inicio);
CREATE NONCLUSTERED INDEX IX_Alquiler_estado          ON IMPACTANTE.Alquiler (estado_alquiler_id);
CREATE NONCLUSTERED INDEX IX_Alquiler_local           ON IMPACTANTE.Alquiler (local_id);
CREATE NONCLUSTERED INDEX IX_Alquiler_forma_pago      ON IMPACTANTE.Alquiler (forma_pago_id);

-- Reparaciones
CREATE NONCLUSTERED INDEX IX_Reparacion_cliente       ON IMPACTANTE.Reparacion (cliente_id);
CREATE NONCLUSTERED INDEX IX_Reparacion_empleado      ON IMPACTANTE.Reparacion (empleado_id);
CREATE NONCLUSTERED INDEX IX_Reparacion_modelo        ON IMPACTANTE.Reparacion (modelo_bicicleta_id);
CREATE NONCLUSTERED INDEX IX_Reparacion_estado        ON IMPACTANTE.Reparacion (estado_reparacion_id);
CREATE NONCLUSTERED INDEX IX_Reparacion_local_fecha   ON IMPACTANTE.Reparacion (local_id, fecha_hora_ingreso);
CREATE NONCLUSTERED INDEX IX_Detalle_Reparacion_rep   ON IMPACTANTE.Detalle_Reparacion (nro_reparacion) INCLUDE (cod_repuesto, cantidad, subtotal);
CREATE NONCLUSTERED INDEX IX_Detalle_Reparacion_resp  ON IMPACTANTE.Detalle_Reparacion (cod_repuesto);
GO

PRINT 'Script IMPACTANTE ejecutado correctamente.';
GO
