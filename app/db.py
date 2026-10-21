
import os

import pandas as pd
import streamlit as st
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL


@st.cache_resource
def get_engine():
    url = URL.create(
        drivername="postgresql+psycopg",
        username=os.getenv("DB_USER", "supermart"),
        password=os.getenv("DB_PASSWORD", ""),
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "5432")),
        database=os.getenv("DB_NAME", "supermart"),
    )

    return create_engine(
        url,
        pool_pre_ping=True,
        connect_args={"connect_timeout": 5},
    )


def test_connection():
    with get_engine().connect() as connection:
        return connection.execute(
            text("SELECT current_database(), current_user")
        ).fetchone()


def read_sql(query, params=None):
    with get_engine().connect() as connection:
        return pd.read_sql(
            text(query),
            connection,
            params=params or {},
        )
