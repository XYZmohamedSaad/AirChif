from passlib.hash import argon2
from jose import jwt, JWTError
from datetime import datetime, timedelta
from edge_server.config import settings

# --- Passwort Hash ---
def get_password_hash(password: str) -> str:
    """
    Hasht ein Passwort mit Argon2.
    """
    return argon2.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Prüft, ob das Passwort zum Hash passt.
    """
    return argon2.verify(plain_password, hashed_password)

# --- JWT Tokens ---
def create_access_token(data: dict, expires_delta: int = None) -> str:
    """
    Erstellt einen Access Token mit optionaler Ablaufzeit in Minuten.
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=expires_delta or settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm="HS256")

def create_refresh_token(data: dict, expires_delta: int = None) -> str:
    """
    Erstellt einen Refresh Token mit optionaler Ablaufzeit in Tagen.
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(days=expires_delta or settings.REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm="HS256")

def decode_token(token: str) -> dict | None:
    """
    Decodiert einen JWT-Token. Gibt None zurück, wenn der Token ungültig ist.
    """
    try:
        return jwt.decode(token, settings.SECRET_KEY, algorithms=["HS256"])
    except JWTError:
        return None
