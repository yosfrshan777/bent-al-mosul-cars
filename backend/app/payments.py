from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy import String, Integer, DateTime, Text
from sqlalchemy.orm import Mapped, mapped_column, Session
from .db import Base, get_db
from .models import User, Car
from .main import current_user
from .pricing import calculate_seller_price

router = APIRouter()

class Payment(Base):
    __tablename__ = 'payments'
    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(index=True)
    car_id: Mapped[int | None] = mapped_column(Integer, nullable=True, index=True)
    plan: Mapped[str] = mapped_column(String(40))
    amount: Mapped[int] = mapped_column(Integer)
    receipt_number: Mapped[str] = mapped_column(String(120), index=True)
    receipt_image: Mapped[str] = mapped_column(Text, default='')
    status: Mapped[str] = mapped_column(String(20), default='pending', index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class PaymentIn(BaseModel):
    plan: str = Field(min_length=2)
    receipt_number: str = Field(min_length=2, max_length=120)
    receipt_image: str = ''
    car_id: int | None = None

@router.post('/payments')
def submit_payment(data: PaymentIn, user: User = Depends(current_user), db: Session = Depends(get_db)):
    quote = calculate_seller_price(data.plan, user)
    if not quote['payment_required']:
        if data.car_id:
            car = db.get(Car, data.car_id)
            if car and car.owner_id == user.id: car.status = 'approved'
        return {'status': 'approved', 'amount': 0, 'message': 'الباقة مجانية وتم اعتمادها'}
    payment = Payment(user_id=user.id, car_id=data.car_id, plan=data.plan, amount=quote['final_price'], receipt_number=data.receipt_number, receipt_image=data.receipt_image, status='pending')
    db.add(payment); db.commit(); db.refresh(payment)
    return {'id': payment.id, 'status': payment.status, 'amount': quote['final_price'], 'message': 'تم إرسال الإيصال بانتظار موافقة الإدارة'}

@router.get('/payments/mine')
def my_payments(user: User = Depends(current_user), db: Session = Depends(get_db)):
    rows = db.query(Payment).filter(Payment.user_id == user.id).order_by(Payment.created_at.desc()).all()
    return [{'id': p.id, 'plan': p.plan, 'amount': p.amount, 'receipt_number': p.receipt_number, 'status': p.status, 'created_at': p.created_at.isoformat()} for p in rows]

@router.get('/admin/payments')
def admin_payments(user: User = Depends(current_user), db: Session = Depends(get_db)):
    if user.role not in ('owner', 'admin'): raise HTTPException(403, 'غير مصرح')
    rows = db.query(Payment).order_by(Payment.created_at.desc()).all()
    return [{'id': p.id, 'user_id': p.user_id, 'car_id': p.car_id, 'plan': p.plan, 'amount': p.amount, 'receipt_number': p.receipt_number, 'receipt_image': p.receipt_image, 'status': p.status, 'created_at': p.created_at.isoformat()} for p in rows]

@router.post('/admin/payments/{payment_id}/approve')
def approve_payment(payment_id: int, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if user.role not in ('owner', 'admin'): raise HTTPException(403, 'غير مصرح')
    p = db.get(Payment, payment_id)
    if not p: raise HTTPException(404, 'عملية الدفع غير موجودة')
    p.status = 'approved'
    if p.car_id:
        car = db.get(Car, p.car_id)
        if car: car.status = 'approved'
    db.commit(); return {'ok': True, 'status': p.status}

@router.post('/admin/payments/{payment_id}/reject')
def reject_payment(payment_id: int, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if user.role not in ('owner', 'admin'): raise HTTPException(403, 'غير مصرح')
    p = db.get(Payment, payment_id)
    if not p: raise HTTPException(404, 'عملية الدفع غير موجودة')
    p.status = 'rejected'; db.commit(); return {'ok': True, 'status': p.status}
