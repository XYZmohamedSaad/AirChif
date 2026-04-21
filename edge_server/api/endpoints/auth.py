from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from edge_server.api.deps import get_current_user
from edge_server.database import models, schemas
from edge_server.database.db import get_db
from edge_server.utils.security import (
    get_password_hash, verify_password,
    create_access_token, create_refresh_token,
    decode_token
)

router = APIRouter()

# --- Signup ---
@router.post("/signup", response_model=schemas.UserOut)
def signup(user_in: schemas.UserCreate, db: Session = Depends(get_db)):
    if db.query(models.User).filter(models.User.email == user_in.email).first():
        raise HTTPException(status_code=400, detail="E-Mail ist bereits registriert.")
    if db.query(models.User).filter(models.User.username == user_in.username).first():
        raise HTTPException(status_code=400, detail="Benutzername ist bereits vergeben.")

    hashed_pw = get_password_hash(user_in.password)
    user = models.User(email=user_in.email, username=user_in.username, hashed_password=hashed_pw)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user

# --- Login ---
@router.post("/login", response_model=schemas.Token)
def login(user_in: schemas.UserLogin, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.email == user_in.email).first()
    if not user or not verify_password(user_in.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Ungültige Anmeldedaten.")

    access_token = create_access_token({"sub": user.email})
    refresh_token = create_refresh_token({"sub": user.email})

    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}

@router.get("/me", response_model=schemas.UserOut)
def me(current_user: models.User = Depends(get_current_user)):
    return current_user


@router.patch("/me")
def update_me(
        payload: schemas.UserUpdate,
        db: Session = Depends(get_db),
        current_user: models.User = Depends(get_current_user),
):
    if payload.email and payload.email != current_user.email:
        if db.query(models.User).filter(models.User.email == payload.email).first():
            raise HTTPException(status_code=409, detail="E-Mail ist bereits registriert.")
        current_user.email = payload.email

    if payload.username and payload.username != current_user.username:
        if db.query(models.User).filter(models.User.username == payload.username).first():
            raise HTTPException(status_code=409, detail="Benutzername ist bereits vergeben.")
        current_user.username = payload.username

    db.commit()
    db.refresh(current_user)

    access_token = create_access_token({"sub": current_user.email})
    refresh_token = create_refresh_token({"sub": current_user.email})

    return {
        "user": current_user,
        "token": {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"},
    }


@router.post("/me/change-password", status_code=204)
def change_password(
        payload: schemas.PasswordChange,
        db: Session = Depends(get_db),
        current_user: models.User = Depends(get_current_user),
):
    if not verify_password(payload.current_password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Aktuelles Passwort ist falsch.")

    current_user.hashed_password = get_password_hash(payload.new_password)
    db.commit()
    return

# --- Refresh Token ---
@router.post("/refresh", response_model=schemas.Token)
def refresh_token(token_in: schemas.TokenRefresh, db: Session = Depends(get_db)):
    payload = decode_token(token_in.refresh_token)
    if not payload or "sub" not in payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Ungültiger Refresh Token.")

    user = db.query(models.User).filter(models.User.email == payload["sub"]).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Benutzer nicht gefunden.")

    access_token = create_access_token({"sub": user.email})
    refresh_token = create_refresh_token({"sub": user.email})

    return {"access_token": access_token, "refresh_token": refresh_token, "token_type": "bearer"}
