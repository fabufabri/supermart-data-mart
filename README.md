# Supermart Data Mart

Proyecto de Business Intelligence basado en el dataset
**Supermart Grocery Sales - Retail Analytics Dataset**.

El proyecto transforma el dataset original en un modelo dimensional
implementado en PostgreSQL mediante Docker, incorporando procesos de
carga, validación, consultas analíticas y vistas SQL para posteriormente
alimentar un dashboard.

---

## 1. Arquitectura

Dataset Kaggle
↓
Limpieza y transformación
↓
PostgreSQL
↓
Modelo dimensional
↓
Vistas SQL
↓
Mockup del dashboard
↓
Aplicación analítica

---

## 2. Tecnologías utilizadas

- PostgreSQL 16
- Docker
- Docker Compose
- SQL
- Git / GitHub
- HTML / CSS para el mockup

---

## 3. Estructura del proyecto

```text
supermart-data-mart/
│
├── data/
│   └── Supermart Grocery Sales - Retail Analytics Dataset.csv
│
├── docs/
│   └── mockup/
│       └── supermart_dashboard_mockup.html
│
├── sql/
│   ├── 01_create_tables.sql
│   ├── 02_load_data.sql
│   ├── 03_validation.sql
│   └── 04_views.sql
│
├── docker-compose.yml
└── README.md
```

---

## 4. Modelo dimensional

El proyecto utiliza un modelo estrella compuesto por una tabla de hechos y cuatro dimensiones.

```text
                    ┌─────────────────┐
                    │   DIM_FECHA     │
                    │─────────────────│
                    │ id_fecha (PK)   │
                    │ fecha           │
                    │ dia             │
                    │ mes             │
                    │ nombre_mes      │
                    │ trimestre       │
                    │ anio            │
                    └────────┬────────┘
                             │
                             │
┌─────────────────┐    ┌─────▼──────────┐    ┌─────────────────┐
│ DIM_PRODUCTO    │    │  FACT_VENTAS   │    │ DIM_UBICACION   │
│─────────────────│    │────────────────│    │─────────────────│
│ id_producto PK  ├───►│ id_venta PK    │◄───┤ id_ubicacion PK │
│ categoria       │    │ order_id       │    │ ciudad          │
│ sub_categoria   │    │ id_fecha FK    │    │ region          │
└─────────────────┘    │ id_producto FK │    │ estado          │
                       │ id_cliente FK  │    └─────────────────┘
                       │ id_ubicacion FK│
                       │ sales          │
                       │ discount       │
                       │ profit         │
                       └───────┬────────┘
                               │
                       ┌───────▼────────┐
                       │ DIM_CLIENTE     │
                       │────────────────│
                       │ id_cliente PK  │
                       │ customer_name  │
                       └────────────────┘
```

### Granularidad

La granularidad de `fact_ventas` corresponde a:

> **Una fila representa una operación de venta registrada en el dataset original, identificada mediante `order_id`.**

---

## 5. Tablas del Data Mart

| Tabla | Registros cargados |
|---|---:|
| dim_fecha | 1.236 |
| dim_producto | 23 |
| dim_ubicacion | 97 |
| dim_cliente | 50 |
| fact_ventas | 9.994 |

---

## 6. Medidas principales

Las principales medidas utilizadas para el análisis son:

- Ventas totales (`sales`)
- Ganancia total (`profit`)
- Descuento (`discount`)
- Cantidad de ventas

Resultados generales obtenidos en el Data Mart:

| Indicador | Resultado |
|---|---:|
| Cantidad de ventas | 9.994 |
| Ventas totales | 14.956.982,00 |
| Ganancia total | 3.747.121,20 |
| Descuento promedio | 0,2268 |

---

## 7. Scripts SQL

### 01_create_tables.sql

Crea las tablas correspondientes al modelo dimensional:

- `dim_fecha`
- `dim_producto`
- `dim_ubicacion`
- `dim_cliente`
- `fact_ventas`

### 02_load_data.sql

Realiza la carga y transformación de los datos del dataset hacia las dimensiones y la tabla de hechos.

### 03_validation.sql

Permite comprobar:

- Cantidad de registros.
- Valores nulos relevantes.
- Integridad de las relaciones.
- Totales de ventas.
- Ganancia total.
- Descuento promedio.

### 04_views.sql

Crea las vistas utilizadas como base para el análisis:

- `vw_resumen_ventas`
- `vw_ventas_categoria`
- `vw_ventas_tiempo`

---

## 8. Validación del Data Mart

La validación realizada sobre el Data Mart obtuvo:

- 9.994 registros en `fact_ventas`.
- 0 valores nulos relevantes.
- 0 ventas sin fecha.
- 0 ventas sin producto.
- 0 ventas sin cliente.
- 0 ventas sin ubicación.

Esto permite comprobar la integridad básica de los datos cargados y de las relaciones entre la tabla de hechos y sus dimensiones.

---

## 9. Vistas analíticas

### vw_resumen_ventas

Resume los principales indicadores generales:

- Cantidad de ventas.
- Ventas totales.
- Ganancia total.
- Descuento promedio.

### vw_ventas_categoria

Permite analizar las ventas y ganancias agrupadas por categoría de producto.

### vw_ventas_tiempo

Permite analizar la evolución de las ventas y ganancias por año y mes.

---

## 10. Mockup del dashboard

El proyecto incluye un mockup desarrollado en HTML y CSS como diseño previo de la aplicación analítica.

Ubicación:

```text
docs/mockup/supermart_dashboard_mockup.html
```

El mockup contempla:

- 3 KPI.
- Filtros por año, mes, categoría y región.
- Gráfico de ventas por categoría.
- Gráfico de evolución mensual.
- Tabla de detalle de ventas.

El mockup corresponde al diseño previo de la aplicación final y se encuentra relacionado con las vistas y datos almacenados en PostgreSQL.

---

## 11. Matriz de trazabilidad

Los componentes del mockup se relacionan con los objetos SQL del Data Mart de la siguiente manera:

| Componente | KPI / Pregunta | Filtros | Origen | Objeto SQL |
|---|---|---|---|---|
| KPI Ventas totales | ¿Cuál es el valor total de ventas? | Año, mes, categoría, región | fact_ventas + dimensiones | vw_resumen_ventas |
| KPI Ganancia total | ¿Cuál es la ganancia obtenida? | Año, mes, categoría, región | fact_ventas + dimensiones | vw_resumen_ventas |
| KPI Cantidad de ventas | ¿Cuántas ventas se realizaron? | Año, mes, categoría, región | fact_ventas + dimensiones | vw_resumen_ventas |
| Ventas por categoría | ¿Qué categorías generan más ventas? | Año, región | fact_ventas + dim_producto | vw_ventas_categoria |
| Evolución mensual | ¿Cómo evolucionan las ventas? | Año, categoría, región | fact_ventas + dim_fecha | vw_ventas_tiempo |
| Tabla de detalle | ¿Cómo se distribuyen las ventas por categoría y subcategoría? | Año, mes, categoría, región | fact_ventas + dimensiones | Consulta SQL |

---

## 12. Ejecución con Docker

Desde la carpeta raíz del proyecto:

```bash
docker compose up -d
```

Comprobar el estado del contenedor:

```bash
docker compose ps
```

El proyecto utiliza:

```text
PostgreSQL 16
Base de datos: supermart
Usuario: supermart
Puerto: 5432
```

---

## 13. Orden de ejecución de los scripts

Los scripts deben ejecutarse en el siguiente orden:

```text
01_create_tables.sql
        ↓
02_load_data.sql
        ↓
03_validation.sql
        ↓
04_views.sql
```

Este orden permite crear primero la estructura, cargar los datos, validarlos y finalmente crear las vistas analíticas.

---

## 14. Objetivo del Data Mart

El objetivo es disponer de una estructura analítica que permita estudiar el comportamiento de las ventas de Supermart desde diferentes perspectivas, principalmente:

- Tiempo.
- Producto.
- Ubicación.
- Cliente.

La información almacenada permitirá posteriormente desarrollar una aplicación de Business Intelligence para visualizar los principales KPI y facilitar el análisis de las ventas.
