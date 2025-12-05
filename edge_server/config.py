import os

class Settings:
    PROJECT_NAME: str = "AirChif"
    API_V1_STR: str = "/api/v1"

    SECRET_KEY: str = os.getenv("SECRET_KEY", "pojarböck")

    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # DATABASE_URL: auf Render immer aus Environment lesen
    DATABASE_URL: str = os.getenv("DATABASE_URL")

    # Fallback nur lokal (wenn keine DATABASE_URL gesetzt ist)
    if not DATABASE_URL:
        POSTGRES_USER: str = os.getenv("POSTGRES_USER", "airchif")
        POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "airchif")
        POSTGRES_DB: str = os.getenv("POSTGRES_DB", "airchif_db")
        POSTGRES_HOST: str = os.getenv("POSTGRES_HOST", "localhost")
        POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")

        DATABASE_URL = f"postgresql+psycopg2://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"

settings = Settings()
