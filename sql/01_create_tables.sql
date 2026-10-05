
-- ---------------------------------------------------------
-- DIMENSIÓN FECHA
-- ---------------------------------------------------------
CREATE TABLE dim_fecha (
    id_fecha SERIAL PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    dia INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    trimestre INTEGER NOT NULL,
    anio INTEGER NOT NULL
);

-- ---------------------------------------------------------
-- DIMENSIÓN PRODUCTO
-- ---------------------------------------------------------
CREATE TABLE dim_producto (
    id_producto SERIAL PRIMARY KEY,
    categoria VARCHAR(100) NOT NULL,
    sub_categoria VARCHAR(100) NOT NULL,
    CONSTRAINT uq_producto UNIQUE (categoria, sub_categoria)
);

-- ---------------------------------------------------------
-- DIMENSIÓN UBICACIÓN
-- ---------------------------------------------------------
CREATE TABLE dim_ubicacion (
    id_ubicacion SERIAL PRIMARY KEY,
    ciudad VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    estado VARCHAR(100) NOT NULL,
    CONSTRAINT uq_ubicacion UNIQUE (ciudad, region, estado)
);

-- ---------------------------------------------------------
-- DIMENSIÓN CLIENTE
-- ---------------------------------------------------------
CREATE TABLE dim_cliente (
    id_cliente SERIAL PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL UNIQUE
);

-- ---------------------------------------------------------
-- TABLA DE HECHOS
-- Granularidad:
-- Una fila representa una orden individual del dataset.
-- ---------------------------------------------------------
CREATE TABLE fact_ventas (
    id_venta SERIAL PRIMARY KEY,

    id_fecha INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    id_ubicacion INTEGER NOT NULL,
    id_cliente INTEGER NOT NULL,

    order_id VARCHAR(50) NOT NULL UNIQUE,

    sales NUMERIC(12,2) NOT NULL,
    discount NUMERIC(8,4) NOT NULL,
    profit NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_fact_fecha
        FOREIGN KEY (id_fecha)
        REFERENCES dim_fecha(id_fecha),

    CONSTRAINT fk_fact_producto
        FOREIGN KEY (id_producto)
        REFERENCES dim_producto(id_producto),

    CONSTRAINT fk_fact_ubicacion
        FOREIGN KEY (id_ubicacion)
        REFERENCES dim_ubicacion(id_ubicacion),

    CONSTRAINT fk_fact_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES dim_cliente(id_cliente)
);