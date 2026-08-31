from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .db import get_db
from .models import User
from .main import current_user

router = APIRouter()

PRICING = {
    "showroom_monthly": {"name": "اشتراك المعرض الشهري", "price": 100000, "currency": "IQD"},
    "parts_monthly": {"name": "اشتراك قطع الغيار الشهري", "price": 15000, "currency": "IQD"},
    "seller_plans": [
        {"id": "basic", "name": "إعلان أساسي", "price": 5000, "currency": "IQD"},
        {"id": "featured", "name": "إعلان مميز", "price": 15000, "currency": "IQD"},
        {"id": "vip", "name": "إعلان VIP", "price": 25000, "currency": "IQD"},
    ],
}

# Controlled by the owner/admin. A 100% discount makes the plan free.
DISCOUNTS = {"basic": 0, "featured": 0, "vip": 0}

def calculate_seller_price(plan_id: str, user: User):
    plan = next((p for p in PRICING["seller_plans"] if p["id"] == plan_id), None)
    if not plan: raise HTTPException(400, "الباقة غير موجودة")
    discount = 100 if user.role == "owner" else max(0, min(100, int(DISCOUNTS.get(plan_id, 0))))
    final_price = round(plan["price"] * (100 - discount) / 100)
    return {"plan": plan_id, "name": plan["name"], "original_price": plan["price"], "discount_percent": discount, "final_price": final_price, "currency": plan["currency"], "payment_required": final_price > 0}

@router.get('/pricing')
def pricing():
    return {**PRICING, "discounts": DISCOUNTS}

@router.get('/pricing/seller/{plan_id}')
def seller_price(plan_id: str, user: User = Depends(current_user)):
    return calculate_seller_price(plan_id, user)
