"""Pipeline entry point — orchestrates a full data refresh run."""
from db.writes import get_connection


def main() -> None:
    print("Starting pipeline run...")
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
            result = cur.fetchone()
            if result is None:
                raise RuntimeError("DB connectivity check failed")
    print("Database connection verified. Pipeline scaffold ready.")


if __name__ == "__main__":
    main()
