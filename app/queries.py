
from db import read_sql


def get_filter_options():
    years = read_sql("""
        SELECT DISTINCT anio
        FROM dim_fecha
        ORDER BY anio
    """)["anio"].dropna().astype(int).tolist()

    months = read_sql("""
        SELECT DISTINCT mes, nombre_mes
        FROM dim_fecha
        ORDER BY mes
    """)

    categories = read_sql("""
        SELECT DISTINCT categoria
        FROM dim_producto
        ORDER BY categoria
    """)["categoria"].dropna().tolist()

    regions = read_sql("""
        SELECT DISTINCT region
        FROM dim_ubicacion
        ORDER BY region
    """)["region"].dropna().tolist()

    return years, months, categories, regions


def _params(years, months, categories, regions):
    return {
        "todos_anios": not years,
        "anios": years or [0],
        "todos_meses": not months,
        "meses": months or [0],
        "todas_categorias": not categories,
        "categorias": categories or [""],
        "todas_regiones": not regions,
        "regiones": regions or [""],
    }


def _where_filters():
    return """
        (:todos_anios OR d.anio = ANY(CAST(:anios AS integer[])))
        AND (:todos_meses OR d.mes = ANY(CAST(:meses AS integer[])))
        AND (
            :todas_categorias
            OR p.categoria = ANY(CAST(:categorias AS varchar[]))
        )
        AND (
            :todas_regiones
            OR u.region = ANY(CAST(:regiones AS varchar[]))
        )
    """


def get_kpis(years, months, categories, regions):
    query = f"""
        SELECT
            COUNT(DISTINCT f.order_id) AS ordenes,
            COALESCE(SUM(f.sales), 0) AS ventas,
            COALESCE(SUM(f.profit), 0) AS ganancias,
            COALESCE(AVG(f.discount), 0) AS descuento_promedio
        FROM fact_ventas f
        JOIN dim_fecha d ON f.id_fecha = d.id_fecha
        JOIN dim_producto p ON f.id_producto = p.id_producto
        JOIN dim_ubicacion u ON f.id_ubicacion = u.id_ubicacion
        WHERE {_where_filters()}
    """
    return read_sql(
        query, _params(years, months, categories, regions)
    ).iloc[0]


def get_sales_by_category(years, months, categories, regions):
    query = f"""
        SELECT
            p.categoria,
            SUM(f.sales) AS ventas,
            SUM(f.profit) AS ganancias
        FROM fact_ventas f
        JOIN dim_fecha d ON f.id_fecha = d.id_fecha
        JOIN dim_producto p ON f.id_producto = p.id_producto
        JOIN dim_ubicacion u ON f.id_ubicacion = u.id_ubicacion
        WHERE {_where_filters()}
        GROUP BY p.categoria
        ORDER BY ventas DESC
    """
    return read_sql(
        query, _params(years, months, categories, regions)
    )


def get_sales_by_month(years, months, categories, regions):
    query = f"""
        SELECT
            d.anio,
            d.mes,
            d.nombre_mes,
            SUM(f.sales) AS ventas,
            SUM(f.profit) AS ganancias
        FROM fact_ventas f
        JOIN dim_fecha d ON f.id_fecha = d.id_fecha
        JOIN dim_producto p ON f.id_producto = p.id_producto
        JOIN dim_ubicacion u ON f.id_ubicacion = u.id_ubicacion
        WHERE {_where_filters()}
        GROUP BY d.anio, d.mes, d.nombre_mes
        ORDER BY d.anio, d.mes
    """
    return read_sql(
        query, _params(years, months, categories, regions)
    )


def get_detail(years, months, categories, regions):
    query = f"""
        SELECT
            p.categoria,
            p.sub_categoria,
            COUNT(*) AS cantidad_ventas,
            SUM(f.sales) AS ventas_totales,
            SUM(f.profit) AS ganancia_total,
            AVG(f.discount) AS descuento_promedio
        FROM fact_ventas f
        JOIN dim_fecha d ON f.id_fecha = d.id_fecha
        JOIN dim_producto p ON f.id_producto = p.id_producto
        JOIN dim_ubicacion u ON f.id_ubicacion = u.id_ubicacion
        WHERE {_where_filters()}
        GROUP BY p.categoria, p.sub_categoria
        ORDER BY ventas_totales DESC
    """
    return read_sql(
        query, _params(years, months, categories, regions)
    )
