-- ============================================================
-- PERÚ COMPRAS - Modelo Dimensional (Star Schema)
-- Análisis de Órdenes de Compra - Catálogos Electrónicos
-- ============================================================

-- Tabla temporal para carga inicial desde CSV
CREATE TABLE TempData (
    FECHA_PROCESO DATETIME,
    RUC_PROVEEDOR VARCHAR(20),
    PROVEEDOR VARCHAR(255),
    RUC_ENTIDAD VARCHAR(20),
    ENTIDAD VARCHAR(255),
    TIPO_PROCEDIMIENTO VARCHAR(50),
    ORDEN_ELECTRÓNICA VARCHAR(50),
    ORDEN_ELECTRÓNICA_GENERADA VARCHAR(255),
    ESTADO_ORDEN_ELECTRÓNICA VARCHAR(50),
    DOCUMENTO_ESTADO_OCAM VARCHAR(200),
    FECHA_FORMALIZACIÓN DATETIME,
    FECHA_ÚLTIMO_ESTADO DATETIME,
    SUB_TOTAL DECIMAL(18, 2),
    IGV DECIMAL(18, 2),
    TOTAL DECIMAL(18, 2),
    ORDEN_DIGITALIZADA VARCHAR(255),
    DESCRIPCIÓN_ESTADO VARCHAR(255),
    DESCRIPCIÓN_CESIÓN_DERECHOS VARCHAR(255),
    ACUERDO_MARCO VARCHAR(255)
);

-- Dimensión: Orden
CREATE TABLE DimOrden (
    OrdenID INT IDENTITY(1,1) PRIMARY KEY,
    OrdenElectronica VARCHAR(50),
    OrdenElectronicaGenerada VARCHAR(255),
    EstadoOrdenElectronica VARCHAR(50),
    DocumentoEstadoOCAM VARCHAR(200),
    OrdenDigitalizada VARCHAR(255),
    DescripcionEstado VARCHAR(255),
    DescripcionCesionDerechos VARCHAR(255),
    AcuerdoMarco VARCHAR(255)
);

-- Dimensión: Proveedor
CREATE TABLE DimProveedor (
    ProveedorID INT IDENTITY(1,1) PRIMARY KEY,
    RUC_Proveedor VARCHAR(40),
    Proveedor VARCHAR(2000)
);

-- Dimensión: Entidad
CREATE TABLE DimEntidad (
    EntidadID INT IDENTITY(1,1) PRIMARY KEY,
    RUC_Entidad VARCHAR(50),
    Entidad VARCHAR(4500)
);

-- Dimensión: Tiempo
CREATE TABLE DimTiempo (
    TiempoID INT IDENTITY(1,1) PRIMARY KEY,
    FechaProceso DATETIME,
    FechaFormalizacion DATETIME,
    FechaUltimoEstado DATETIME
);

-- Tabla de Hechos: FactOrden
CREATE TABLE FactOrden (
    FactOrdenID INT IDENTITY(1,1) PRIMARY KEY,
    ProveedorID INT NOT NULL,
    EntidadID INT NOT NULL,
    TiempoID INT NOT NULL,
    OrdenID INT NOT NULL,
    TipoProcedimiento VARCHAR(50),
    SubTotal DECIMAL(18, 2),
    IGV DECIMAL(18, 2),
    Total DECIMAL(18, 2),
    CONSTRAINT FK_FactOrden_Proveedor FOREIGN KEY (ProveedorID) REFERENCES DimProveedor(ProveedorID),
    CONSTRAINT FK_FactOrden_Entidad FOREIGN KEY (EntidadID) REFERENCES DimEntidad(EntidadID),
    CONSTRAINT FK_FactOrden_Tiempo FOREIGN KEY (TiempoID) REFERENCES DimTiempo(TiempoID),
    CONSTRAINT FK_FactOrden_Orden FOREIGN KEY (OrdenID) REFERENCES DimOrden(OrdenID)
);
