from fastapi import APIRouter

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

@router.get('/pricing')
def pricing():
    return PRICING
