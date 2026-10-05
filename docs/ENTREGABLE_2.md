# Entregable 2 · Construcción del Data Mart

## Supermart Data Mart

**Proyecto de Business Intelligence basado en el dataset:**  
**Supermart Grocery Sales - Retail Analytics Dataset**

---

## 1. Objetivo

El objetivo de este entregable es transformar el dataset real seleccionado en el Entregable 1 en una estructura analítica funcional implementada en PostgreSQL.

Para ello se realizó la preparación y carga de los datos, el diseño e implementación de un modelo dimensional tipo estrella, la creación de consultas de validación, vistas SQL y un mockup del dashboard analítico.

La arquitectura implementada corresponde a:

```text
Dataset Kaggle
      ↓
Limpieza y transformación
      ↓
PostgreSQL 16
      ↓
Modelo dimensional
      ↓
Vistas SQL
      ↓
Mockup del dashboard
      ↓
Aplicación analítica
```

---

## 2. Tecnologías utilizadas

- PostgreSQL 16
- Docker
- Docker Compose
- SQL
- Git
- GitHub
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
│   ├── ENTREGABLE_2.md
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
├── README.md
└── .gitignore
```

---

## 4. Arquitectura Docker y PostgreSQL

Para la implementación del Data Mart se utilizó PostgreSQL 16 ejecutándose mediante Docker Compose.

El archivo `docker-compose.yml` define:

```text
Servicio: postgres
Imagen: postgres:16
Contenedor: supermart_postgres
Base de datos: supermart
Usuario: supermart
Puerto: 5432
```

El contenedor fue levantado mediante:

```bash
docker compose up -d
```

La comprobación del estado del servicio se realizó con:

```bash
docker compose ps
```

El contenedor `supermart_postgres` quedó ejecutándose correctamente y exponiendo el puerto 5432.

---

## 5. Modelo dimensional

Se implementó un modelo estrella compuesto por una tabla de hechos y cuatro dimensiones.

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
                       │ DIM_CLIENTE    │
                       │────────────────│
                       │ id_cliente PK  │
                       │ customer_name  │
                       └────────────────┘
```

### 5.1 Tabla de hechos

La tabla principal es:

```text
fact_ventas
```

Contiene las medidas necesarias para el análisis:

- `sales`
- `discount`
- `profit`
- `order_id`

Además contiene las claves foráneas que relacionan cada venta con las dimensiones.

### 5.2 Dimensiones

Se implementaron las siguientes dimensiones:

- `dim_fecha`
- `dim_producto`
- `dim_ubicacion`
- `dim_cliente`

---

## 6. Granularidad

La granularidad definida para `fact_ventas` es:

> **Una fila representa una operación de venta registrada en el dataset original, identificada mediante `order_id`.**

Esta definición permite analizar las ventas desde diferentes perspectivas: tiempo, producto, ubicación y cliente.

La comprobación realizada sobre el dataset mostró:

```text
Total de registros: 9.994
Order ID únicos: 9.994
```

Por lo tanto, cada registro de la tabla de hechos corresponde a una operación de venta del dataset original.

---

## 7. Creación de tablas

La estructura del modelo dimensional se encuentra en:

```text
sql/01_create_tables.sql
```

Este script crea las cinco tablas principales:

```text
dim_fecha
dim_producto
dim_ubicacion
dim_cliente
fact_ventas
```

Las tablas incluyen claves primarias y las relaciones mediante claves foráneas necesarias para conectar la tabla de hechos con sus dimensiones.

---

## 8. Preparación y transformación de datos

Los datos originales fueron cargados inicialmente a una estructura de staging para realizar su tratamiento antes de incorporarlos al modelo dimensional.

Entre las transformaciones realizadas se encuentran:

### 8.1 Tratamiento de fechas

El dataset contenía fechas en dos formatos:

```text
DD-MM-YYYY
M/D/YYYY
```

Se identificaron:

```text
DD-MM-YYYY → 4.042 registros
M/D/YYYY  → 5.952 registros
```

Por esta razón, durante la transformación se realizó la conversión de las fechas a un tipo `DATE` de PostgreSQL.

El rango de fechas obtenido fue:

```text
Fecha mínima: 2015-01-02
Fecha máxima: 2018-12-30
```

La dimensión de fecha quedó conformada por:

```text
id_fecha
fecha
dia
mes
nombre_mes
trimestre
anio
```

### 8.2 Tratamiento de categorías

Se aplicó limpieza mediante `TRIM()` para eliminar espacios innecesarios en:

- Categoría.
- Subcategoría.
- Ciudad.
- Región.
- Estado.
- Nombre del cliente.

### 8.3 Identificación de registros

Se comprobó la existencia de:

```text
Total de registros: 9.994
Order ID únicos: 9.994
```

Por lo tanto, no se detectaron registros duplicados tomando `order_id` como identificador de la venta.

---

## 9. Carga de las dimensiones

Después de la transformación se cargaron los datos en las dimensiones.

Resultados obtenidos:

| Tabla | Registros |
|---|---:|
| `dim_fecha` | 1.236 |
| `dim_producto` | 23 |
| `dim_ubicacion` | 97 |
| `dim_cliente` | 50 |

### Dimensión de producto

La dimensión contiene las combinaciones de:

- Categoría.
- Subcategoría.

Se cargaron:

```text
23 combinaciones de categoría y subcategoría
```

### Dimensión de ubicación

La dimensión contiene:

- Ciudad.
- Región.
- Estado.

Se cargaron:

```text
97 combinaciones de ubicación
```

### Dimensión de cliente

La dimensión contiene el nombre del cliente.

Se cargaron:

```text
50 clientes
```

---

## 10. Carga de la tabla de hechos

La tabla:

```text
fact_ventas
```

recibió:

```text
9.994 registros
```

Las medidas principales almacenadas son:

```text
sales
discount
profit
```

La carga fue realizada mediante el script:

```text
sql/02_load_data.sql
```

---

## 11. Validación de los datos

Las validaciones se encuentran documentadas en:

```text
sql/03_validation.sql
```

### 11.1 Conteo de registros

Los resultados fueron:

| Tabla | Registros |
|---|---:|
| `dim_fecha` | 1.236 |
| `dim_producto` | 23 |
| `dim_ubicacion` | 97 |
| `dim_cliente` | 50 |
| `fact_ventas` | 9.994 |

### 11.2 Valores nulos

Se revisaron los campos relevantes de la tabla de hechos.

Resultado:

| Campo | Nulos |
|---|---:|
| `order_id` | 0 |
| Fecha | 0 |
| Producto | 0 |
| Cliente | 0 |
| Ubicación | 0 |
| `sales` | 0 |
| `discount` | 0 |
| `profit` | 0 |

### 11.3 Integridad de relaciones

Se verificó que no existieran ventas sin correspondencia en las dimensiones.

Resultados:

```text
Ventas sin fecha:       0
Ventas sin producto:    0
Ventas sin cliente:     0
Ventas sin ubicación:   0
```

Esto confirma la integridad referencial básica del Data Mart.

---

## 12. Indicadores principales obtenidos

La consulta general sobre `fact_ventas` produjo:

| Indicador | Resultado |
|---|---:|
| Total de ventas | 9.994 |
| Ventas totales | 14.956.982,00 |
| Ganancia total | 3.747.121,20 |
| Descuento promedio | 0,2268 |

Estos indicadores constituyen la base para el dashboard analítico.

---

## 13. Vistas SQL

Se creó el script:

```text
sql/04_views.sql
```

El cual contiene **cinco vistas SQL** utilizadas como fuentes iniciales para los componentes analíticos del dashboard.

### 13.1 `vw_resumen_ventas`

Permite obtener:

- Cantidad de ventas.
- Ventas totales.
- Ganancia total.
- Descuento promedio.

Esta vista también sirve como consulta de resumen y apoyo para la validación de los indicadores generales.

### 13.2 `vw_ventas_categoria`

Permite analizar las ventas agrupadas por categoría.

Resultado observado:

| Categoría | Cantidad de ventas | Ventas totales | Ganancia total |
|---|---:|---:|---:|
| Eggs, Meat & Fish | 1.490 | 2.267.401,00 | 567.357,22 |
| Snacks | 1.514 | 2.237.546,00 | 568.178,85 |
| Food Grains | 1.398 | 2.115.272,00 | 529.162,64 |
| Bakery | 1.413 | 2.112.281,00 | 528.521,06 |
| Fruits & Veggies | 1.418 | 2.100.727,00 | 530.400,38 |
| Beverages | 1.400 | 2.085.313,00 | 525.605,76 |
| Oil & Masala | 1.361 | 2.038.442,00 | 497.895,29 |

### 13.3 `vw_ventas_tiempo`

Permite analizar la evolución de las ventas y ganancias por año y mes.

Ejemplo de resultados obtenidos para 2015:

| Mes | Cantidad de ventas | Ventas totales | Ganancia total |
|---|---:|---:|---:|
| Enero | 131 | 203.014,00 | 54.689,18 |
| Febrero | 86 | 120.444,00 | 32.737,87 |
| Marzo | 168 | 260.072,00 | 66.217,50 |
| Abril | 121 | 176.187,00 | 46.030,20 |
| Mayo | 148 | 218.740,00 | 50.899,84 |
| Junio | 137 | 209.191,00 | 51.276,99 |

### 13.4 `vw_kpi_ventas`

Esta vista concentra los principales indicadores que serán utilizados por las tarjetas KPI del dashboard:

- Cantidad de ventas.
- Ventas totales.
- Ganancia total.
- Descuento promedio.

Resultado validado:

| Indicador | Resultado |
|---|---:|
| Cantidad de ventas | 9.994 |
| Ventas totales | 14.956.982,00 |
| Ganancia total | 3.747.121,20 |
| Descuento promedio | 0,2268 |

### 13.5 `vw_detalle_ventas`

Esta vista permite obtener el detalle analítico agrupado por categoría y subcategoría.

Incluye:

- Categoría.
- Subcategoría.
- Cantidad de ventas.
- Ventas totales.
- Ganancia total.
- Descuento promedio.

Resultado validado con la consulta:

```text
SELECT * FROM vw_detalle_ventas LIMIT 20;
```

La vista devuelve registros correspondientes a las diferentes combinaciones de categoría y subcategoría existentes en `dim_producto`.

Las cinco vistas fueron verificadas en PostgreSQL mediante:

```text
\dv
```

Resultado:

```text
vw_detalle_ventas
vw_kpi_ventas
vw_resumen_ventas
vw_ventas_categoria
vw_ventas_tiempo
```

---

## 14. Mockup del dashboard

Antes de desarrollar la aplicación final se creó un mockup en HTML y CSS.

Ubicación:

```text
docs/mockup/supermart_dashboard_mockup.html
```

El mockup contempla los elementos mínimos solicitados:

- 3 KPI.
- Filtros.
- 2 gráficos.
- Tabla o componente de detalle.
- Organización general de las vistas.

### Componentes representados

**Filtros:**

- Año.
- Mes.
- Categoría.
- Región.

**KPI:**

- Ventas totales.
- Ganancia total.
- Cantidad de ventas.

**Gráficos:**

- Ventas por categoría.
- Evolución mensual de ventas.

**Detalle:**

- Categoría.
- Subcategoría.
- Ventas.
- Ganancia.
- Descuento promedio.
- Cantidad de ventas.

El mockup es una representación visual previa a la implementación de la aplicación analítica. Los valores y componentes mostrados sirven como referencia del diseño y de la estructura esperada; la versión funcional deberá consultar directamente PostgreSQL.

---

## 15. Matriz de trazabilidad

| Componente | Pregunta / KPI | Filtros | Origen de datos | Objeto SQL |
|---|---|---|---|---|
| KPI: Ventas totales | ¿Cuál es el valor total de las ventas? | Año, mes, categoría, región | `fact_ventas` + dimensiones | `vw_kpi_ventas` |
| KPI: Ganancia total | ¿Cuál es la ganancia total obtenida? | Año, mes, categoría, región | `fact_ventas` + dimensiones | `vw_kpi_ventas` |
| KPI: Cantidad de ventas | ¿Cuántas operaciones de venta se realizaron? | Año, mes, categoría, región | `fact_ventas` + dimensiones | `vw_kpi_ventas` |
| Gráfico: Ventas por categoría | ¿Qué categorías generan mayor volumen de ventas? | Año, región | `fact_ventas` + `dim_producto` | `vw_ventas_categoria` |
| Gráfico: Evolución mensual de ventas | ¿Cómo evolucionan las ventas y ganancias a través del tiempo? | Año, categoría, región | `fact_ventas` + `dim_fecha` | `vw_ventas_tiempo` |
| Tabla de detalle | ¿Cómo se distribuyen las ventas y ganancias por categoría y subcategoría? | Año, mes, categoría, región | `fact_ventas` + `dim_producto` + `dim_fecha` + `dim_ubicacion` | `vw_detalle_ventas` |

### 15.1 Relación entre filtros y dimensiones

Los filtros definidos en el mockup corresponden a atributos almacenados en las dimensiones del modelo dimensional:

- **Año:** `dim_fecha.anio`
- **Mes:** `dim_fecha.mes`
- **Categoría:** `dim_producto.categoria`
- **Región:** `dim_ubicacion.region`

En esta etapa, los filtros se encuentran definidos en el mockup como parte de la propuesta de interacción del dashboard. La aplicación analítica de la siguiente fase deberá utilizar estos atributos de las dimensiones para filtrar los datos consultados desde PostgreSQL.

### 15.2 Correspondencia con las vistas SQL

Las vistas SQL fueron diseñadas como fuentes iniciales para los componentes analíticos del mockup:

- `vw_kpi_ventas`: KPI principales.
- `vw_ventas_categoria`: gráfico de ventas por categoría.
- `vw_ventas_tiempo`: evolución temporal.
- `vw_detalle_ventas`: tabla de detalle.
- `vw_resumen_ventas`: resumen general y validación de indicadores.

---

## 16. Correspondencia con las actividades obligatorias

| Requisito del Entregable 2 | Evidencia |
|---|---|
| Preparar y limpiar datos | `02_load_data.sql` y sección 8 |
| Instalar/configurar PostgreSQL | Docker Compose + PostgreSQL 16 |
| Diseñar modelo dimensional | Modelo estrella y `01_create_tables.sql` |
| Definir granularidad | Sección 6 |
| 1 tabla de hechos | `fact_ventas` |
| Mínimo 3 dimensiones | 4 dimensiones implementadas |
| Claves primarias | Definidas en las tablas |
| Claves foráneas | Definidas en `fact_ventas` |
| Medidas para KPI | `sales`, `profit`, `discount`, cantidad de ventas |
| Dimensión de tiempo | `dim_fecha` |
| Carga de datos reales | 9.994 registros en `fact_ventas` |
| Validación de registros | `03_validation.sql` |
| Validación de integridad | `03_validation.sql` |
| Vistas/funciones SQL | 5 vistas SQL en `04_views.sql` |
| Mockup | `docs/mockup/supermart_dashboard_mockup.html` |
| 3 KPI | Mockup y matriz de trazabilidad |
| Filtros | Mockup y matriz de trazabilidad |
| 2 gráficos | Mockup y matriz de trazabilidad |
| Tabla de detalle | Mockup y `vw_detalle_ventas` |
| Matriz de trazabilidad | Sección 15 |
| Respaldo del proyecto | Repositorio Git/GitHub |

---

## 17. Reproducibilidad

Para levantar PostgreSQL:

```bash
docker compose up -d
```

Para comprobar el contenedor:

```bash
docker compose ps
```

Para crear las tablas:

```bash
docker exec -i supermart_postgres psql -U supermart -d supermart < sql/01_create_tables.sql
```

Para cargar los datos:

```bash
docker exec -i supermart_postgres psql -U supermart -d supermart < sql/02_load_data.sql
```

Para ejecutar las validaciones:

```bash
docker exec -i supermart_postgres psql -U supermart -d supermart < sql/03_validation.sql
```

Para crear las vistas:

```bash
docker exec -i supermart_postgres psql -U supermart -d supermart < sql/04_views.sql
```

Los scripts se encuentran en el repositorio del proyecto y permiten reproducir la estructura y las consultas principales del Data Mart.

---

## 18. Control de versiones

El proyecto fue inicializado como repositorio Git y respaldado en GitHub.

Repositorio:

```text
https://github.com/fabufabri/supermart-data-mart
```

### Commits principales

```text
573ae61 - Construccion inicial del Supermart Data Mart
981a65e - Documentacion del Entregable 2
```

La rama principal utilizada es:

```text
main
```

El repositorio contiene:

- Dataset.
- Docker Compose.
- Scripts SQL.
- Mockup.
- README.
- Documentación del Entregable 2.

---

## 19. Conclusión

El Entregable 2 permitió transformar el dataset real de Supermart en un Data Mart funcional utilizando PostgreSQL y Docker.

Se implementó un modelo estrella con una tabla de hechos y cuatro dimensiones, se cargaron 9.994 registros de ventas y se realizaron validaciones de calidad e integridad.

Además, se construyeron cinco vistas SQL para el análisis por resumen, indicadores, categoría, tiempo y detalle, y se elaboró un mockup del dashboard que relaciona los KPI y componentes visuales con los datos almacenados.

De esta manera, el proyecto cuenta con una base preparada para la siguiente etapa: desarrollar la aplicación analítica que consumirá la información del Data Mart y aplicará los filtros definidos sobre las dimensiones correspondientes.

La pregunta planteada para esta fase queda respondida de la siguiente manera:

> **¿Cómo voy a almacenar, consultar y presentar la información?**

**Almacenar:** mediante un modelo dimensional tipo estrella en PostgreSQL, compuesto por `fact_ventas` y cuatro dimensiones.

**Consultar:** mediante SQL, consultas de validación y cinco vistas analíticas.

**Presentar:** mediante el mockup del dashboard, que define los KPI, filtros, gráficos y tabla de detalle que serán implementados en la siguiente etapa.
