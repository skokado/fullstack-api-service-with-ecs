from fastapi import APIRouter

router = APIRouter()


@router.get("/")
def v1_hello():
    return {"message": "Hello from API v1!"}
