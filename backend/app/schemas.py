from pydantic import BaseModel, Field

class RegisterIn(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    phone: str = Field(min_length=5, max_length=40)
    password: str = Field(min_length=6, max_length=128)

class LoginIn(BaseModel):
    phone: str
    password: str

class CarCreate(BaseModel):
    brand: str
    model: str
    year: int = Field(ge=1900, le=2100)
    price: int = Field(ge=0)
    km: int = Field(ge=0, default=0)
    city: str
    fuel: str = "بنزين"
    transmission: str = "أوتوماتيك"
    description: str = ""
    plan: str = "standard"
    images: list[str] = []
    phone: str = ""
    body_type: str = "سيارة"

class UserOut(BaseModel):
    id: int
    name: str
    phone: str
    role: str

class CarOut(CarCreate):
    id: int
    owner_id: int
    status: str
    created_at: str
