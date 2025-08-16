from fastapi import APIRouter

from .init_app import app

api = APIRouter()

# Register API routers
from .apps_v1.routers import router as v1_router  # noqa: E402

api.include_router(v1_router, prefix="/v1")

# Finally include the main app router
app.include_router(api, prefix="/api")
