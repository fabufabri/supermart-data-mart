-- ============================================================
-- 02_load_data.sql
-- Carga y transformación de datos del Data Mart Supermart
-- ============================================================

-- Tabla temporal para recibir el CSV original
CREATE TEMP TABLE staging_ventas (
    order_id VARCHAR(50),
    customer_name VARCHAR(150),
    category VARCHAR(100),
    sub_category VARCHAR(100),
    city VARCHAR(100),
    order_date VARCHAR(50),
    region VARCHAR(100),
    sales NUMERIC(12,2),
    discount NUMERIC(8,4),
    profit NUMERIC(12,2),
    state VARCHAR(100)
);

-- Carga del archivo CSV dentro del contenedor PostgreSQL
\copy staging_ventas
FROM '/tmp/supermart.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ',',
    QUOTE '"'
);

-- Carga de la dimensión de fecha.
-- El dataset contiene dos formatos:
-- DD-MM-YYYY y M/D/YYYY.

INSERT INTO dim_fecha (
    fecha,
    dia,
    mes,
    nombre_mes,
    trimestre,
    anio
)
SELECT DISTINCT
    fecha,
    EXTRACT(DAY FROM fecha)::INTEGER,
    EXTRACT(MONTH FROM fecha)::INTEGER,
    TO_CHAR(fecha, 'TMMonth'),
    EXTRACT(QUARTER FROM fecha)::INTEGER,
    EXTRACT(YEAR FROM fecha)::INTEGER
FROM (
    SELECT
        CASE
            WHEN order_date ~ '^\d{1,2}-\d{1,2}-\d{4}$'
                THEN TO_DATE(order_date, 'DD-MM-YYYY')
            WHEN order_date ~ '^\d{1,2}/\d{1,2}/\d{4}$'
                THEN TO_DATE(order_date, 'MM/DD/YYYY')
        END AS fecha
    FROM staging_ventas
) fechas
WHERE fecha IS NOT NULL;

-- Carga de productos
INSERT INTO dim_producto (
    categoria,
    sub_categoria
)
SELECT DISTINCT
    TRIM(category),
    TRIM(sub_category)
FROM staging_ventas
WHERE TRIM(category) <> ''
  AND TRIM(sub_category) <> '';

-- Carga de ubicaciones
INSERT INTO dim_ubicacion (
    ciudad,
    region,
    estado
)
SELECT DISTINCT
    TRIM(city),
    TRIM(region),
    TRIM(state)
FROM staging_ventas
WHERE TRIM(city) <> ''
  AND TRIM(region) <> ''
  AND TRIM(state) <> '';

-- Carga de clientes
INSERT INTO dim_cliente (
    customer_name
)
SELECT DISTINCT
    TRIM(customer_name)
FROM staging_ventas
WHERE TRIM(customer_name) <> '';

-- Carga de la tabla de hechos
INSERT INTO fact_ventas (
    order_id,
    id_fecha,
    id_producto,
    id_cliente,
    id_ubicacion,
    sales,
    discount,
    profit
)
SELECT
    s.order_id,
    f.id_fecha,
    p.id_producto,
    c.id_cliente,
    u.id_ubicacion,
    s.sales,
    s.discount,
    s.profit
FROM staging_ventas s

JOIN dim_fecha f
    ON f.fecha =
        CASE
            WHEN s.order_date ~ '^\d{1,2}-\d{1,2}-\d{4}$'
                THEN TO_DATE(s.order_date, 'DD-MM-YYYY')
            WHEN s.order_date ~ '^\d{1,2}/\d{1,2}/\d{4}$'
                THEN TO_DATE(s.order_date, 'MM/DD/YYYY')
        END

JOIN dim_producto p
    ON p.categoria = TRIM(s.category)
   AND p.sub_categoria = TRIM(s.sub_category)

JOIN dim_cliente c
    ON c.customer_name = TRIM(s.customer_name)

JOIN dim_ubicacion u
    ON u.ciudad = TRIM(s.city)
   AND u.region = TRIM(s.region)
   AND u.estado = TRIM(s.state);