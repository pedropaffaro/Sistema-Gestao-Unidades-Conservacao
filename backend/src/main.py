from contextlib import asynccontextmanager
from fastapi import FastAPI
from database import get_env_pool, close_pool
from routers import unidades

@asynccontextmanager
async def lifespan(app: FastAPI):
  
    await get_env_pool()
    yield
    await close_pool()

app = FastAPI(
    title="Unidades de Conservação",
    version="1.0.0",
    lifespan=lifespan 
)

app.include_router(unidades.router)