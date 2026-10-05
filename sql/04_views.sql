-- ============================================================
-- 04_views.sql
-- Vistas SQL para alimentar el dashboard
-- ============================================================

-- Resumen general
CREATE OR REPLACE VIEW vw_resumen_ventas AS
SELECT
    COUNT(*) AS total_ventas,
    ROUND(SUM(sales), 2) AS ventas_totales,
    ROUND(SUM(profit), 2) AS ganancia_total,
    ROUND(AVG(discount), 4) AS descuento_promedio
FROM fact_ventas;

-- Ventas por categoría
CREATE OR REPLACE VIEW vw_ventas_categoria AS
SELECT
    p.categoria,
    COUNT(f.order_id) AS cantidad_ventas,
    ROUND(SUM(f.sales), 2) AS ventas_totales,
    ROUND(SUM(f.profit), 2) AS ganancia_total
FROM fact_ventas f
JOIN dim_producto p
    ON f.id_producto = p.id_producto
GROUP BY p.categoria
ORDER BY ventas_totales DESC;

-- Evolución mensual de ventas
CREATE OR REPLACE VIEW vw_ventas_tiempo AS
SELECT
    d.anio,
    d.mes,
    d.nombre_mes,
    COUNT(f.order_id) AS cantidad_ventas,
    ROUND(SUM(f.sales), 2) AS ventas_totales,
    ROUND(SUM(f.profit), 2) AS ganancia_total
FROM fact_ventas f
JOIN dim_fecha d
    ON f.id_fecha = d.id_fecha
GROUP BY
    d.anio,
    d.mes,
    d.nombre_mes
ORDER BY
    d.anio,
    d.mes;

CREATE OR REPLACE VIEW vw_kpi_ventas AS
SELECT
    COUNT(f.order_id) AS cantidad_ventas,
    ROUND(SUM(f.sales), 2) AS ventas_totales,
    ROUND(SUM(f.profit), 2) AS ganancia_total,
    ROUND(AVG(f.discount), 4) AS descuento_promedio
FROM fact_ventas f;

CREATE OR REPLACE VIEW vw_detalle_ventas AS
SELECT
    p.categoria,
    p.sub_categoria,
    COUNT(f.order_id) AS cantidad_ventas,
    ROUND(SUM(f.sales), 2) AS ventas_totales,
    ROUND(SUM(f.profit), 2) AS ganancia_total,
    ROUND(AVG(f.discount), 4) AS descuento_promedio
FROM fact_ventas f
JOIN dim_producto p
    ON f.id_producto = p.id_producto
JOIN dim_fecha d
    ON f.id_fecha = d.id_fecha
JOIN dim_ubicacion u
    ON f.id_ubicacion = u.id_ubicacion
GROUP BY
    p.categoria,
    p.sub_categoria
ORDER BY
    p.categoria,
    p.sub_categoria;