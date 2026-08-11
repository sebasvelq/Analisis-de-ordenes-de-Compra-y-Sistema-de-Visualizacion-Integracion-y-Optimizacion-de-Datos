# Análisis de Órdenes de Compra – PERÚ COMPRAS

**Integración y Optimización de Datos para la Central de Compras Públicas – PERÚ COMPRAS**

Sistema de análisis y visualización de órdenes de compra provenientes de los **Catálogos Electrónicos** de la Central de Compras Públicas – PERÚ COMPRAS.

🔗 Fuente de datos: [PERÚ COMPRAS – Catálogos Electrónicos](https://www.gob.pe/perucompras) (https://www.datosabiertos.gob.pe/dataset/%C3%B3rdenes-de-compra-realizadas-trav%C3%A9s-de-los-cat%C3%A1logos-electr%C3%B3nicos-central-de-compras)

---

## 📋 Descripción del Proyecto

Este proyecto implementa un flujo completo de **ETL + modelo dimensional + visualización** para analizar las órdenes de compra públicas de Perú:

| Capa | Tecnología | Descripción |
|------|------------|-------------|
| Extracción / Carga | SQL Server + BULK INSERT / SSIS | Carga de reportes CSV de órdenes de compra |
| Transformación | SQL Server (T-SQL) | Limpieza, deduplicación y carga a modelo dimensional |
| Modelo de datos | Star Schema | Dimensiones + Tabla de Hechos |
| Visualización | Dashboard (Power BI / similar) | Panel interactivo de KPIs y análisis |

---

## 🗂️ Estructura del Repositorio

```
Peru-Compras-Ordenes-Analisis/
├── sql/
│   ├── 01_create_tables.sql      # Creación de TempData, Dimensiones y FactOrden
│   └── 02_cargar_datos.sql       # Procedimiento almacenado CargarDatos
├── docs/                         # Documentación adicional / capturas del dashboard
├── README.md
└── .gitignore
```

---

## 🗄️ Modelo de Datos (Star Schema)

### Tablas Dimensionales

| Tabla | Descripción | Clave |
|-------|-------------|-------|
| **DimProveedor** | Proveedores (RUC + Nombre) | `ProveedorID` |
| **DimEntidad** | Entidades públicas compradoras | `EntidadID` |
| **DimTiempo** | Fechas de proceso, formalización y último estado | `TiempoID` |
| **DimOrden** | Datos de la orden electrónica y su estado | `OrdenID` |

### Tabla de Hechos

| Tabla | Métricas | Relaciones |
|-------|----------|------------|
| **FactOrden** | `SubTotal`, `IGV`, `Total`, `TipoProcedimiento` | FK a las 4 dimensiones |

### Tabla Temporal

- **TempData**: Staging para la carga inicial del CSV antes de distribuir a dimensiones y hechos.

---

## ⚙️ Cómo ejecutar el proyecto

### Requisitos

- SQL Server 2016 o superior (o Azure SQL)
- SQL Server Management Studio (SSMS) o Azure Data Studio
- Archivo CSV de órdenes de compra (separador `;`)

### Pasos

1. **Crear las tablas**
   ```sql
   -- Ejecutar en orden:
   sql/01_create_tables.sql
   ```

2. **Crear el procedimiento de carga**
   ```sql
   sql/02_cargar_datos.sql
   ```

3. **Ajustar la ruta del CSV**
   Abre `02_cargar_datos.sql` y modifica la ruta del `BULK INSERT`:
   ```sql
   BULK INSERT TempData
   FROM 'C:\Ruta\A\Tu\Archivo\ReportePCBienes202301.csv'
   ```

4. **Ejecutar la carga**
   ```sql
   EXEC CargarDatos;
   ```

5. **Verificar**
   ```sql
   SELECT COUNT(*) FROM FactOrden;
   SELECT TOP 10 * FROM FactOrden f
   JOIN DimProveedor p ON f.ProveedorID = p.ProveedorID;
   ```

---

## 📊 Panel de Visualización (Resumen)

El dashboard presenta la información de forma clara y accionable:

### KPIs principales
- **Ventas Totales** por mes (Subtotal, IGV, Total) + deltas mensuales
- **Tiempo promedio de formalización** de órdenes (gráfico de barras mensual)
- **Pedidos vencidos** (contador)
- **Distribución por Entidades y Proveedores** (gráficos de anillos)
- **Mapa geográfico** de las ventas

### Sugerencias de mejora del panel
- Alertas automáticas ante desviaciones o cumplimiento de objetivos
- Exportación a PDF
- Filtros avanzados por acuerdo marco, tipo de procedimiento y estado

---

## 🔄 Proceso ETL

```
CSV (ReportePCBienes...)
        │
        ▼
   TempData (Staging)
        │
        ├──► DimProveedor
        ├──► DimEntidad
        ├──► DimTiempo
        ├──► DimOrden
        │
        ▼
    FactOrden (Hechos)
```

Se utilizó **SQL Server Integration Services (SSIS)** para mejorar la limpieza y automatizar la carga hacia las tablas dimensionales.

---

## 🚀 Mejoras Planeadas

- [ ] Optimización adicional del proceso ETL (limpieza y rendimiento)
- [ ] Mejoras en el modelo lógico
- [ ] Alertas y notificaciones automáticas en el dashboard
- [ ] Exportación a PDF
- [ ] Incorporación de más dimensiones (geografía, categoría de bien, etc.)
- [ ] Histórico de estados de las órdenes

---

## 🛠️ Tecnologías utilizadas

- **SQL Server** – Almacenamiento y modelado dimensional
- **T-SQL** – Scripts de creación y procedimiento de carga
- **SSIS** – Orquestación y limpieza del ETL
- **Dashboard** (Power BI u otra herramienta de BI) – Visualización de KPIs

---

## 📌 Notas

- El archivo CSV original usa separador `;` y la primera fila es encabezado (`FIRSTROW = 2`).
- Se recomienda ejecutar el procedimiento dentro de una transacción (ya implementado) para mantener consistencia.
- Ajusta los tamaños de `VARCHAR` según la calidad real de tus datos si es necesario.

---

## 📄 Licencia

MIT License – Puedes usar, modificar y compartir este proyecto libremente.

---

**Objetivo:** Mejorar la toma de decisiones y la eficiencia de los procesos en la Central de Compras Públicas de Perú mediante un flujo de datos confiable y un panel de control claro.
