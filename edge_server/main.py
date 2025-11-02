from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from edge_server.config import settings
from edge_server.database.db import Base, engine
from edge_server.api.endpoints import auth, journeys, missions, detections, drone_ws

# -----------------------------
# Datenbanktabellen erstellen
# -----------------------------
Base.metadata.create_all(bind=engine)

# -----------------------------
# FastAPI App erstellen
# -----------------------------
app = FastAPI(title=settings.PROJECT_NAME)

# -----------------------------
# CORS Middleware
# -----------------------------
origins = [
    "http://localhost:5173",
    "http://127.0.0.1:5173",
    "https://airchif.netlify.app",
    "https://air-chif-five.vercel.app"
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------
# API-Router
# -----------------------------
app.include_router(auth.router, prefix=f"{settings.API_V1_STR}/auth", tags=["auth"])
app.include_router(journeys.router, prefix=f"{settings.API_V1_STR}/journeys", tags=["journeys"])
app.include_router(missions.router, prefix=f"{settings.API_V1_STR}/missions", tags=["missions"])
app.include_router(detections.router, prefix=f"{settings.API_V1_STR}/detections", tags=["detections"])
app.include_router(drone_ws.router, prefix=f"{settings.API_V1_STR}/missions", tags=["websocket"])
