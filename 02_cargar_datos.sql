-- ============================================================
-- Procedimiento almacenado: CargarDatos
-- Carga el CSV → TempData → Dimensiones → FactOrden
-- ============================================================
-- IMPORTANTE: Cambia la ruta del archivo CSV antes de ejecutar.
-- ============================================================

CREATE OR ALTER PROCEDURE CargarDatos
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Cargar datos desde el archivo CSV
        --    Ajusta la ruta según tu entorno
        BULK INSERT TempData
        FROM 'C:\Ruta\A\Tu\Archivo\ReportePCBienes202301.csv'
        WITH (
            FIELDTERMINATOR = ';',
            ROWTERMINATOR = '\n',
            FIRSTROW = 2,
            CODEPAGE = 'ACP'
        );

        -- 2. Insertar en DimProveedor (valores únicos)
        INSERT INTO DimProveedor (RUC_Proveedor, Proveedor)
        SELECT DISTINCT RUC_PROVEEDOR, PROVEEDOR
        FROM TempData
        WHERE RUC_PROVEEDOR IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM DimProveedor dp
              WHERE dp.RUC_Proveedor = TempData.RUC_PROVEEDOR
                AND dp.Proveedor = TempData.PROVEEDOR
          );

        -- 3. Insertar en DimEntidad (valores únicos)
        INSERT INTO DimEntidad (RUC_Entidad, Entidad)
        SELECT DISTINCT RUC_ENTIDAD, ENTIDAD
        FROM TempData
        WHERE RUC_ENTIDAD IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM DimEntidad de
              WHERE de.RUC_Entidad = TempData.RUC_ENTIDAD
                AND de.Entidad = TempData.ENTIDAD
          );

        -- 4. Insertar en DimTiempo (valores únicos)
        INSERT INTO DimTiempo (FechaProceso, FechaFormalizacion, FechaUltimoEstado)
        SELECT DISTINCT FECHA_PROCESO, FECHA_FORMALIZACIÓN, FECHA_ÚLTIMO_ESTADO
        FROM TempData
        WHERE NOT EXISTS (
            SELECT 1 FROM DimTiempo dt
            WHERE dt.FechaProceso = TempData.FECHA_PROCESO
              AND ISNULL(dt.FechaFormalizacion, '1900-01-01') = ISNULL(TempData.FECHA_FORMALIZACIÓN, '1900-01-01')
              AND ISNULL(dt.FechaUltimoEstado, '1900-01-01') = ISNULL(TempData.FECHA_ÚLTIMO_ESTADO, '1900-01-01')
        );

        -- 5. Insertar en DimOrden (valores únicos)
        INSERT INTO DimOrden (
            OrdenElectronica, OrdenElectronicaGenerada, EstadoOrdenElectronica,
            DocumentoEstadoOCAM, OrdenDigitalizada, DescripcionEstado,
            DescripcionCesionDerechos, AcuerdoMarco
        )
        SELECT DISTINCT
            ORDEN_ELECTRÓNICA, ORDEN_ELECTRÓNICA_GENERADA, ESTADO_ORDEN_ELECTRÓNICA,
            DOCUMENTO_ESTADO_OCAM, ORDEN_DIGITALIZADA, DESCRIPCIÓN_ESTADO,
            DESCRIPCIÓN_CESIÓN_DERECHOS, ACUERDO_MARCO
        FROM TempData
        WHERE ORDEN_ELECTRÓNICA IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM DimOrden do
              WHERE do.OrdenElectronica = TempData.ORDEN_ELECTRÓNICA
                AND ISNULL(do.OrdenElectronicaGenerada, '') = ISNULL(TempData.ORDEN_ELECTRÓNICA_GENERADA, '')
          );

        -- 6. Insertar en FactOrden
        INSERT INTO FactOrden (ProveedorID, EntidadID, TiempoID, OrdenID, TipoProcedimiento, SubTotal, IGV, Total)
        SELECT
            dp.ProveedorID,
            de.EntidadID,
            dt.TiempoID,
            do.OrdenID,
            t.TIPO_PROCEDIMIENTO,
            t.SUB_TOTAL,
            t.IGV,
            t.TOTAL
        FROM TempData t
        INNER JOIN DimProveedor dp
            ON dp.RUC_Proveedor = t.RUC_PROVEEDOR
           AND dp.Proveedor = t.PROVEEDOR
        INNER JOIN DimEntidad de
            ON de.RUC_Entidad = t.RUC_ENTIDAD
           AND de.Entidad = t.ENTIDAD
        INNER JOIN DimTiempo dt
            ON dt.FechaProceso = t.FECHA_PROCESO
           AND ISNULL(dt.FechaFormalizacion, '1900-01-01') = ISNULL(t.FECHA_FORMALIZACIÓN, '1900-01-01')
           AND ISNULL(dt.FechaUltimoEstado, '1900-01-01') = ISNULL(t.FECHA_ÚLTIMO_ESTADO, '1900-01-01')
        INNER JOIN DimOrden do
            ON do.OrdenElectronica = t.ORDEN_ELECTRÓNICA
           AND ISNULL(do.OrdenElectronicaGenerada, '') = ISNULL(t.ORDEN_ELECTRÓNICA_GENERADA, '');

        -- 7. Limpiar tabla temporal
        TRUNCATE TABLE TempData;

        COMMIT TRANSACTION;
        PRINT 'Carga de datos completada exitosamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
