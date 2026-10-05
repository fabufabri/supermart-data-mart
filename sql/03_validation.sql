-- ============================================================
-- 03_validation.sql
-- Validaciones del Data Mart Supermart
-- ============================================================

-- Cantidad de registros
SELECT 'dim_fecha' AS tabla, COUNT(*) AS registros
FROM dim_fecha
UNION ALL
SELECT 'dim_producto', COUNT(*)
FROM dim_producto
UNION ALL
SELECT 'dim_ubicacion', COUNT(*)
FROM dim_ubicacion
UNION ALL
SELECT 'dim_cliente', COUNT(*)
FROM dim_cliente
UNION ALL
SELECT 'fact_ventas', COUNT(*)
FROM fact_ventas;

-- Validación de valores nulos
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulos,
    COUNT(*) FILTER (WHERE id_fecha IS NULL) AS fecha_nulos,
    COUNT(*) FILTER (WHERE id_producto IS NULL) AS producto_nulos,
    COUNT(*) FILTER (WHERE id_cliente IS NULL) AS cliente_nulos,
    COUNT(*) FILTER (WHERE id_ubicacion IS NULL) AS ubicacion_nulos,
    COUNT(*) FILTER (WHERE sales IS NULL) AS sales_nulos,
    COUNT(*) FILTER (WHERE discount IS NULL) AS discount_nulos,
    COUNT(*) FILTER (WHERE profit IS NULL) AS profit_nulos
FROM fact_ventas;

-- Integridad de fecha
SELECT COUNT(*) AS ventas_sin_fecha
FROM fact_ventas f
LEFT JOIN dim_fecha d
    ON f.id_fecha = d.id_fecha
WHERE d.id_fecha IS NULL;

-- Integridad de producto
SELECT COUNT(*) AS ventas_sin_producto
FROM fact_ventas f
LEFT JOIN dim_producto d
    ON f.id_producto = d.id_producto
WHERE d.id_producto IS NULL;

-- Integridad de cliente
SELECT COUNT(*) AS ventas_sin_cliente
FROM fact_ventas f
LEFT JOIN dim_cliente d
    ON f.id_cliente = d.id_cliente
WHERE d.id_cliente IS NULL;

-- Integridad de ubicación
SELECT COUNT(*) AS ventas_sin_ubicacion
FROM fact_ventas f
LEFT JOIN dim_ubicacion d
    ON f.id_ubicacion = d.id_ubicacion
WHERE d.id_ubicacion IS NULL;

-- KPI principales
SELECT
    COUNT(*) AS total_ventas,
    ROUND(SUM(sales), 2) AS ventas_totales,
    ROUND(SUM(profit), 2) AS ganancia_total,
    ROUND(AVG(discount), 4) AS descuento_promedio
FROM fact_ventas;