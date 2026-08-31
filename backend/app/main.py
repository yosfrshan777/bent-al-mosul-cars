import json
from fastapi import FastAPI, Depends, HTTPException, Header
from sqlalchemy import select
from sqlalchemy.orm import Session
from .db import Base, engine, get_db
from .models import User, Car
from .schemas import RegisterIn, LoginIn, UserOut, CarCreate
from .security import hash_password, verify_password, create_token, decode_token
from .market import router as market_router
from .brands import router as brands_router

Base.metadata.create_all(bind=engine)
app = FastAPI(title="ZYOCAR API", version="1.0.0")

def current_user(authorization: str | None = Header(default=None), db: Session = Depends(get_db)) -> User:
    if not authorization or not authorization.startswith("Bearer "): raise HTTPException(401, "تسجيل الدخول مطلوب")
    try: payload = decode_token(authorization[7:]); uid = int(payload["sub"])
    except Exception: raise HTTPException(401, "جلسة الدخول غير صالحة")
    user = db.get(User, uid)
    if not user: raise HTTPException(401, "المستخدم غير موجود")
    return user

def car_dict(c: Car):
    return {"id": c.id, "owner_id": c.owner_id, "brand": c.brand, "model": c.model, "year": c.year, "price": c.price, "km": c.km, "city": c.city, "fuel": c.fuel, "transmission": c.transmission, "description": c.description, "plan": c.plan, "images": json.loads(c.images_json or "[]"), "phone": c.phone, "body_type": c.body_type, "status": c.status, "created_at": c.created_at.isoformat()}

@app.get("/api/health")
def health(): return {"ok": True, "service": "zyocar-api"}

@app.post("/api/auth/register")
def register(data: RegisterIn, db: Session = Depends(get_db)):
    if db.scalar(select(User).where(User.phone == data.phone)): raise HTTPException(409, "رقم الهاتف مستخدم مسبقاً")
    user = User(name=data.name, phone=data.phone, password_hash=hash_password(data.password), role="user")
    db.add(user); db.commit(); db.refresh(user)
    return {"token": create_token(user.id, user.role), "user": UserOut.model_validate(user, from_attributes=True).model_dump()}

@app.post("/api/auth/login")
def login(data: LoginIn, db: Session = Depends(get_db)):
    user = db.scalar(select(User).where(User.phone == data.phone))
    if not user or not verify_password(data.password, user.password_hash): raise HTTPException(401, "رقم الهاتف أو كلمة المرور غير صحيحة")
    return {"token": create_token(user.id, user.role), "user": UserOut.model_validate(user, from_attributes=True).model_dump()}

@app.get("/api/auth/me")
def me(user: User = Depends(current_user)): return UserOut.model_validate(user, from_attributes=True)
@app.post("/api/auth/logout")
def logout(): return {"ok": True}

@app.get("/api/cars")
def cars(db: Session = Depends(get_db)): return [car_dict(c) for c in db.scalars(select(Car).where(Car.status == "approved").order_by(Car.created_at.desc())).all()]

@app.post("/api/cars")
def create_car(data: CarCreate, user: User = Depends(current_user), db: Session = Depends(get_db)):
    car = Car(owner_id=user.id, brand=data.brand, model=data.model, year=data.year, price=data.price, km=data.km, city=data.city, fuel=data.fuel, transmission=data.transmission, description=data.description, plan=data.plan, images_json=json.dumps(data.images, ensure_ascii=False), phone=data.phone or user.phone, body_type=data.body_type, status="pending")
    db.add(car); db.commit(); db.refresh(car); return car_dict(car)

@app.get("/api/cars/mine/list")
def my_cars(user: User = Depends(current_user), db: Session = Depends(get_db)): return [car_dict(c) for c in db.scalars(select(Car).where(Car.owner_id == user.id).order_by(Car.created_at.desc())).all()]

@app.delete("/api/cars/{car_id}")
def delete_car(car_id: int, user: User = Depends(current_user), db: Session = Depends(get_db)):
    car = db.get(Car, car_id)
    if not car or car.owner_id != user.id: raise HTTPException(404, "السيارة غير موجودة")
    db.delete(car); db.commit(); return {"ok": True}

app.include_router(market_router, prefix="/api")
app.include_router(brands_router, prefix="/api")
