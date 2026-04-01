import os

import psycopg
from dotenv import load_dotenv

load_dotenv()  # loads pipeline/.env when run from pipeline/ directory

DATABASE_URL = os.environ.get("DATABASE_URL")


def get_connection() -> psycopg.Connection:
    """Return an open psycopg3 connection using DATABASE_URL.

    Callers are responsible for closing the connection.
    Prefer using as a context manager: `with get_connection() as conn: ...`
    """
    if not DATABASE_URL or not DATABASE_URL.strip():
        raise EnvironmentError(
            "DATABASE_URL is not set. Copy .env.example to .env and fill in the value."
        )
    return psycopg.connect(DATABASE_URL)
