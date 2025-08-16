from fastapi import APIRouter

router = APIRouter()

# register v1 routers
from .root.routers import router as v1_root_router  # noqa: E402

router.include_router(v1_root_router)
