import asyncio
from mavsdk import System
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()
drone = System()

@app.on_event("startup")
async def startup_event():
    # Verbinde zur SITL-Drohne in WSL2
    await drone.connect(system_address="tcp://172.19.140.91:5760")
    print("Drohne verbunden")

class ControlInput(BaseModel):
    pitch: float
    roll: float
    throttle: float
    yaw: float

@app.post("/control")
async def control_drone(input: ControlInput):
    await drone.manual_control.set_manual_control_input(
        input.pitch, input.roll, input.yaw, input.throttle
    )
    return {"status": "ok"}

@app.get("/telemetry")
async def telemetry():
    async for pos in drone.telemetry.position():
        return {
            "lat": pos.latitude_deg,
            "lon": pos.longitude_deg,
            "alt": pos.relative_altitude_m
        }
