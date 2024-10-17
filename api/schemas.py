#schemas.py
from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# User Schema
class UserBase(BaseModel):
    username: str
    email: str

class UserCreate(UserBase):
    password: str

class UserSchema(UserBase):
    id: int

    class Config:
        orm_mode = True


# Local Schema
class LocalBase(BaseModel):
    name: str
    country: str
    latitude: float
    longitude: float

class LocalCreate(LocalBase):
    pass

class LocalSchema(LocalBase):
    id: int

    class Config:
        orm_mode = True


# UserLocal Schema
class UserLocalBase(BaseModel):
    user_id: int
    local_id: int
    image_url: Optional[str] = None
    visited: Optional[datetime] = None

class UserLocalCreate(UserLocalBase):
    pass

class UserLocalSchema(UserLocalBase):

    class Config:
        orm_mode = True


# Authentication Schema
class Token(BaseModel):
    access_token: str
    token_type: str
    id: int
