from fastapi import FastAPI

app = FastAPI(title="Fullstack API Service")


@app.get("/")
async def hello():
    return {"message": "Hello FastAPI!"}


@app.get("/health")
async def health_check():
    return {"msg": "it works"}
