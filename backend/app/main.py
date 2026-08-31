from fastapi import FastAPI

app = FastAPI(title="ZYOCAR API", version="1.0.0")

api = FastAPI(title="ZYOCAR API routes")

@api.get("/health")
def health():
    return {"ok": True, "service": "zyocar-api"}

app.mount("/api", api)
