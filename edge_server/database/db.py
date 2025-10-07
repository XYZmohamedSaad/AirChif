from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# PostgreSQL Connection (Windows lokal)
DATABASE_URL = "postgresql+psycopg2://postgres:airchif@localhost:5432/airchif"

# Engine erstellen
engine = create_engine(DATABASE_URL, echo=True)  # echo=True zeigt SQL-Logs

# Session
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base-Klasse für Models
Base = declarative_base()

# Dependency für FastAPI
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
