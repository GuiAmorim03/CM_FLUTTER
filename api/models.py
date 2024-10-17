# models.py
from sqlalchemy import Column, ForeignKey, Integer, String, Float, DateTime, UniqueConstraint
from sqlalchemy.orm import relationship
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)

    local_images = relationship("UserLocal", back_populates="user", cascade="all, delete-orphan")


class Local(Base):
    __tablename__ = "locals"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True, nullable=False)
    country = Column(String, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)

    local_images = relationship("UserLocal", back_populates="local", cascade="all, delete-orphan")


class UserLocal(Base):
    __tablename__ = "user_local"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    local_id = Column(Integer, ForeignKey("locals.id"), nullable=False, index=True)
    image_url = Column(String, nullable=True)
    visited = Column(DateTime, nullable=True)

    user = relationship("User", back_populates="local_images")
    local = relationship("Local", back_populates="local_images")

    __table_args__ = (
        UniqueConstraint('user_id', 'local_id', name='_user_local_uc'),
    )
