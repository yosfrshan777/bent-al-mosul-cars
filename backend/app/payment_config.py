from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import String, DateTime
from sqlalchemy.orm import Mapped, mapped_column, Session
from .db import Base, get_db
from .models import User
from .main import current_user

router = APIRouter()

class PaymentConfig(Base):
    __tablename__ = 'payment_config'
    id: Mapped[int] = mapped_column(primary_key=True)
    provider: Mapped[str] = mapped_column(String(40), default='SuperQi')
    barcode_image: Mapped[str] = mapped_column(String(1000), default='')
    icon_image: Mapped[str] = mapped_column(String(1000), default='')
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

class PaymentConfigIn(BaseModel):
    provider: str = 'SuperQi'
    barcode_image: str
    icon_image: str = ''

@router.get('/payment-config')
def get_config(db: Session = Depends(get_db)):
    cfg = db.query(PaymentConfig).first()
    if not cfg:
        return {'provider': 'SuperQi', 'barcode_image': '', 'icon_image': ''}
    return {'provider': cfg.provider, 'barcode_image': cfg.barcode_image, 'icon_image': cfg.icon_image}

@router.put('/admin/payment-config')
def set_config(data: PaymentConfigIn, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if user.role not in ('owner', 'admin'): raise HTTPException(403, 'غير مصرح')
    cfg = db.query(PaymentConfig).first()
    if not cfg: cfg = PaymentConfig(); db.add(cfg)
    cfg.provider = data.provider; cfg.barcode_image = data.barcode_image; cfg.icon_image = data.icon_image; cfg.updated_at = datetime.utcnow()
    db.commit()
    return {'ok': True, 'provider': cfg.provider, 'barcode_image': cfg.barcode_image, 'icon_image': cfg.icon_image}
