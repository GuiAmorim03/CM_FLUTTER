# models.py
from sqlalchemy import Column, ForeignKey, Integer, String, Float, DateTime, UniqueConstraint, Table
from sqlalchemy.orm import relationship
from database import Base


friends_association = Table(
    'friends',
    Base.metadata,
    Column('user_id', Integer, ForeignKey('users.id'), primary_key=True),
    Column('friend_id', Integer, ForeignKey('users.id'), primary_key=True)
)

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)

    local_images = relationship("UserLocal", back_populates="user", cascade="all, delete-orphan")

    friends_obj = relationship(
        'User', 
        secondary=friends_association, 
        primaryjoin=id == friends_association.c.user_id,
        secondaryjoin=id == friends_association.c.friend_id,
        backref="friend_of"
    )

    @property
    def friends(self):
        return [friend.id for friend in self.friends_obj]



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
