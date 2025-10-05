from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from edge_server.database import models, schemas
from edge_server.database.db import get_db
from edge_server.utils.security import get_password_hash, verify_password, create_access_token

router = APIRouter()

@router.post("/signup", response_model=schemas.UserOut)
def signup(user_in: schemas.UserCreate, db: Session = Depends(get_db)):
    # Prüfe, ob E-Mail bereits existiert
    if db.query(models.User).filter(models.User.email == user_in.email).first():
        raise HTTPException(status_code=400, detail="E-Mail ist bereits registriert.")

    # Prüfe, ob Username bereits existiert
    if db.query(models.User).filter(models.User.username == user_in.username).first():
        raise HTTPException(status_code=400, detail="Benutzername ist bereits vergeben.")

    # Passwort-Hash erstellen
    hashed_pw = get_password_hash(user_in.password)

    # Benutzer erstellen
    user = models.User(email=user_in.email, username=user_in.username, hashed_password=hashed_pw)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

@router.post("/login")
def login(user_in: schemas.UserLogin, db: Session = Depends(get_db)):
    # Benutzer anhand E-Mail finden
    user = db.query(models.User).filter(models.User.email == user_in.email).first()
    if not user or not verify_password(user_in.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Ungültige Anmeldedaten.")

    # Token erzeugen
    token = create_access_token({"sub": user.email})
    return {"access_token": token, "token_type": "bearer"}
