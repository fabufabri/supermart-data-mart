
import streamlit as st

from queries import (
    get_filter_options,
    get_kpis,
    get_sales_by_category,
    get_sales_by_month,
    get_detail,
)


# =========================================================
# CONFIGURACIÓN
# =========================================================

st.set_page_config(
    page_title="Supermart BI",
    page_icon="📊",
    layout="wide",
)

st.title("📊 Supermart BI")
st.caption(
    "Dashboard de análisis comercial | PostgreSQL + Python + Streamlit"
)


# =========================================================
# FUNCIONES AUXILIARES
# =========================================================

def format_currency(value):
    return f"$ {float(value):,.2f}"


def get_filter_value(selected, all_options):
    """
    Si se seleccionan todas las opciones, devuelve una lista vacía
    para indicar que no se debe aplicar ese filtro.
    Si se selecciona una parte, devuelve las opciones elegidas.
    """
    if set(selected) == set(all_options):
        return []
    return selected


# =========================================================
# CARGA DEL DASHBOARD
# =========================================================

try:
    years, months_df, categories, regions = get_filter_options()

    # -----------------------------------------------------
    # FILTROS LATERALES
    # -----------------------------------------------------

    with st.sidebar:
        st.header("🔎 Filtros")

        st.caption(
            "Selecciona los valores que deseas analizar. "
            "Los indicadores y gráficos se actualizarán automáticamente."
        )

        selected_years = st.multiselect(
            "Año",
            options=years,
            default=years,
            key="filter_year",
        )

        month_options = (
            months_df["mes"]
            .dropna()
            .astype(int)
            .tolist()
        )

        month_labels = {
            int(row["mes"]): str(row["nombre_mes"]).capitalize()
            for _, row in months_df.iterrows()
        }

        selected_months = st.multiselect(
            "Mes",
            options=month_options,
            default=month_options,
            format_func=lambda month: month_labels.get(
                month, str(month)
            ),
            key="filter_month",
        )

        selected_categories = st.multiselect(
            "Categoría",
            options=categories,
            default=categories,
            key="filter_category",
        )

        selected_regions = st.multiselect(
            "Región",
            options=regions,
            default=regions,
            key="filter_region",
        )

        st.divider()

        if st.button("🔄 Restablecer filtros", use_container_width=True):
            for key in (
                "filter_year",
                "filter_month",
                "filter_category",
                "filter_region",
            ):
                st.session_state.pop(key, None)

            st.rerun()

    # -----------------------------------------------------
    # PREPARAR LOS PARÁMETROS
    # -----------------------------------------------------

    years_filter = get_filter_value(selected_years, years)

    months_filter = get_filter_value(
        selected_months, month_options
    )

    categories_filter = get_filter_value(
        selected_categories, categories
    )

    regions_filter = get_filter_value(
        selected_regions, regions
    )

    # Mostrar las selecciones activas
    st.subheader("Resumen de selección")

    active_filters = []

    if years_filter:
        active_filters.append(
            "Años: " + ", ".join(map(str, years_filter))
        )

    if months_filter:
        active_filters.append(
            "Meses: " + ", ".join(
                month_labels.get(month, str(month))
                for month in months_filter
            )
        )

    if categories_filter:
        active_filters.append(
            "Categorías: " + ", ".join(categories_filter)
        )

    if regions_filter:
        active_filters.append(
            "Regiones: " + ", ".join(regions_filter)
        )

    if active_filters:
        st.info("Filtros aplicados: " + " | ".join(active_filters))
    else:
        st.info("Mostrando todos los datos disponibles.")

    # -----------------------------------------------------
    # INDICADORES KPI
    # -----------------------------------------------------

    kpis = get_kpis(
        years_filter,
        months_filter,
        categories_filter,
        regions_filter,
    )

    col1, col2, col3, col4 = st.columns(4)

    col1.metric(
        "Órdenes",
        f"{int(kpis['ordenes']):,}",
    )

    col2.metric(
        "Ventas totales",
        format_currency(kpis["ventas"]),
    )

    col3.metric(
        "Ganancia total",
        format_currency(kpis["ganancias"]),
    )

    col4.metric(
        "Descuento promedio",
        f"{float(kpis['descuento_promedio']) * 100:.2f}%",
    )

    st.divider()

    # -----------------------------------------------------
    # CONSULTAS PARA GRÁFICOS Y DETALLE
    # -----------------------------------------------------

    ventas_categoria = get_sales_by_category(
        years_filter,
        months_filter,
        categories_filter,
        regions_filter,
    )

    ventas_mes = get_sales_by_month(
        years_filter,
        months_filter,
        categories_filter,
        regions_filter,
    )

    # =====================================================
    # PESTAÑAS
    # =====================================================

    tab1, tab2 = st.tabs(
        ["📈 Análisis comercial", "📋 Detalle de ventas"]
    )

    # -----------------------------------------------------
    # PESTAÑA 1: ANÁLISIS COMERCIAL
    # -----------------------------------------------------

    with tab1:
        left, right = st.columns(2)

        with left:
            st.subheader("Ventas por categoría")

            if not ventas_categoria.empty:
                st.bar_chart(
                    ventas_categoria.set_index("categoria")[["ventas"]]
                )
            else:
                st.info(
                    "No hay ventas para los filtros seleccionados."
                )

        with right:
            st.subheader("Evolución mensual de ventas")

            if not ventas_mes.empty:
                ventas_mes = ventas_mes.copy()

                ventas_mes["periodo"] = (
                    ventas_mes["anio"].astype(str)
                    + "-"
                    + ventas_mes["mes"].astype(str).str.zfill(2)
                )

                st.line_chart(
                    ventas_mes.set_index("periodo")[["ventas"]]
                )
            else:
                st.info(
                    "No hay datos mensuales para esta selección."
                )

        st.subheader("Ganancias por categoría")

        if not ventas_categoria.empty:
            st.bar_chart(
                ventas_categoria.set_index("categoria")[["ganancias"]]
            )
        else:
            st.info(
                "No hay ganancias para los filtros seleccionados."
            )

    # -----------------------------------------------------
    # PESTAÑA 2: DETALLE DE VENTAS
    # -----------------------------------------------------

    with tab2:
        st.subheader("Detalle por categoría y subcategoría")

        detalle = get_detail(
            years_filter,
            months_filter,
            categories_filter,
            regions_filter,
        )

        if not detalle.empty:
            detalle = detalle.rename(
                columns={
                    "categoria": "Categoría",
                    "sub_categoria": "Subcategoría",
                    "cantidad_ventas": "Registros de venta",
                    "ventas_totales": "Ventas totales",
                    "ganancia_total": "Ganancia total",
                    "descuento_promedio": "Descuento promedio",
                }
            )

            st.dataframe(
                detalle,
                use_container_width=True,
                hide_index=True,
            )

            st.download_button(
                "⬇️ Descargar detalle en CSV",
                data=detalle.to_csv(
                    index=False
                ).encode("utf-8-sig"),
                file_name="supermart_detalle.csv",
                mime="text/csv",
            )

        else:
            st.info(
                "No hay registros para los filtros seleccionados."
            )

except Exception as error:
    st.error("No se pudo cargar el dashboard.")
    st.exception(error)
