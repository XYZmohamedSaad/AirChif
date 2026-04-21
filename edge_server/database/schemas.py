# edge_server/database/schemas.py
from pydantic import BaseModel, EmailStr, Field, validator
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

# User
from pydantic import BaseModel, EmailStr, Field, validator

# Gemeinsames User-Model
class UserBase(BaseModel):
    email: EmailStr = Field(..., description="Gültige E-Mail-Adresse des Benutzers")
    username: str = Field(..., min_length=3, max_length=30, description="Eindeutiger Benutzername")

# Input für Signup
class UserCreate(UserBase):
    password: str = Field(..., min_length=8, description="Passwort mit mindestens 8 Zeichen")

    # Zusätzliche einfache Passwortprüfung
    @validator("password")
    def validate_password_strength(cls, v):
        if len(v) < 8:
            raise ValueError("Das Passwort muss mindestens 8 Zeichen lang sein.")
        if v.isdigit() or v.isalpha():
            raise ValueError("Das Passwort sollte Zahlen und Buchstaben enthalten.")
        return v

# Login
class UserLogin(BaseModel):
    email: EmailStr
    password: str

# Output (Response)
class UserOut(UserBase):
    id: int

    class Config:
        orm_mode = True

#Token
class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"

class TokenRefresh(BaseModel):
    refresh_token: str

# Waypoint
class WaypointBase(BaseModel):
    seq: int
    lat: float
    lon: float
    alt: Optional[float] = None

class WaypointCreate(WaypointBase):
    pass

class WaypointOut(WaypointBase):
    id: int
    class Config:
        orm_mode = True

# Journey
class JourneyCreate(BaseModel):
    name: str
    description: Optional[str] = None
    points: List[WaypointCreate]

class JourneyOut(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    owner_id: int
    created_at: datetime
    waypoints: List[WaypointOut]
    class Config:
        orm_mode = True

# Mission
class MissionCreate(BaseModel):
    journey_id: int

class MissionOut(BaseModel):
    id: int
    journey_id: int
    status: str
    started_at: datetime
    class Config:
        orm_mode = True

# Detection
class DetectionCreate(BaseModel):
    mission_id: int
    lat: float
    lon: float
    label: str
    score: Optional[float] = None

class DetectionOut(DetectionCreate):
    id: int
    created_at: datetime
    class Config:
        orm_mode = True


class UserUpdate(BaseModel):
    username: Optional[str] = Field(default=None, min_length=3, max_length=30)
    email: Optional[EmailStr] = None

class PasswordChange(BaseModel):
    current_password: str = Field(min_length=8)
    new_password: str = Field(min_length=8)

    @validator("new_password")
    def validate_password_strength(cls, v):
        if len(v) < 8:
            raise ValueError("Das Passwort muss mindestens 8 Zeichen lang sein.")
        if v.isdigit() or v.isalpha():
            raise ValueError("Das Passwort sollte Zahlen und Buchstaben enthalten.")
        return v

