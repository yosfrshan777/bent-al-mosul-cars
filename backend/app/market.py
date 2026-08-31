import json
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, func
from sqlalchemy.orm import Session
from .db import get_db
from .models import User, Car
from .main import current_user, car_dict

router = APIRouter()

@router.get('/showrooms')
def showrooms(db: Session = Depends(get_db)):
    users = db.scalars(select(User).where(User.role == 'showroom')).all()
    return [{'id': u.id, 'name': u.name, 'phone': u.phone, 'city': ''} for u in users]

@router.get('/showrooms/{showroom_id}')
def showroom(showroom_id: int, db: Session = Depends(get_db)):
    u = db.get(User, showroom_id)
    if not u or u.role != 'showroom': raise HTTPException(404, 'المعرض غير موجود')
    cars = db.scalars(select(Car).where(Car.owner_id == u.id, Car.status == 'approved')).all()
    return {'id': u.id, 'name': u.name, 'phone': u.phone, 'cars': [car_dict(c) for c in cars]}

@router.get('/parts')
def parts(db: Session = Depends(get_db)):
    users = db.scalars(select(User).where(User.role == 'parts')).all()
    return [{'id': u.id, 'name': u.name, 'phone': u.phone, 'city': ''} for u in users]

@router.get('/parts/{store_id}')
def part_store(store_id: int, db: Session = Depends(get_db)):
    u = db.get(User, store_id)
    if not u or u.role != 'parts': raise HTTPException(404, 'محل قطع الغيار غير موجود')
    return {'id': u.id, 'name': u.name, 'phone': u.phone, 'delivery': True}

@router.get('/reels')
def reels(db: Session = Depends(get_db)):
    cars = db.scalars(select(Car).where(Car.status == 'approved').order_by(Car.created_at.desc()).limit(100)).all()
    return [car_dict(c) for c in cars]

@router.get('/admin/dashboard')
def dashboard(user: User = Depends(current_user), db: Session = Depends(get_db)):
    if user.role not in ('owner', 'admin'): raise HTTPException(403, 'غير مصرح')
    return {'cars': db.scalar(select(func.count(Car.id))) or 0, 'users': db.scalar(select(func.count(User.id))) or 0,
            'pending_cars': db.scalar(select(func.count(Car.id)).where(Car.status == 'pending')) or 0}

@router.get('/admin/cars')
def admin_cars(user: User = Depends(current_user), db: Session = Depends(get_db)):
    if user.role not in ('owner', 'admin'): raise HTTPException(403, 'غير مصرح')
    return [car_dict(c) for c in db.scalars(select(Car).order_by(Car.created_at.desc())).all()]

@router.post('/admin/cars/{car_id}/approve')
def approve_car(car_id: int, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if user.role not in ('owner', 'admin'): raise HTTPException(403, 'غير مصرح')
    car = db.get(Car, car_id)
    if not car: raise HTTPException(404, 'السيارة غير موجودة')
    car.status = 'approved'; db.commit(); return car_dict(car)

@router.post('/admin/cars/{car_id}/reject')
def reject_car(car_id: int, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if user.role not in ('owner', 'admin'): raise HTTPException(403, 'غير مصرح')
    car = db.get(Car, car_id)
    if not car: raise HTTPException(404, 'السيارة غير موجودة')
    car.status = 'rejected'; db.commit(); return car_dict(car)

@router.delete('/admin/cars/{car_id}')
def admin_delete_car(car_id: int, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if user.role not in ('owner', 'admin'): raise HTTPException(403, 'غير مصرح')
    car = db.get(Car, car_id)
    if not car: raise HTTPException(404, 'السيارة غير موجودة')
    db.delete(car); db.commit(); return {'ok': True}
