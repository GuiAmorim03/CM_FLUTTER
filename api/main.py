# main.py
from uuid import uuid4
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import Dict, List, Optional
import models, schemas, auth
from database import Base, engine
from fastapi.security import OAuth2PasswordRequestForm
from datetime import timedelta
import os
from fastapi.staticfiles import StaticFiles
from fastapi import File, UploadFile
from api_url import host

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Init DB
Base.metadata.create_all(bind=engine)

# Image directory
IMAGE_DIR = "static/images"
os.makedirs(IMAGE_DIR, exist_ok=True)

# Static files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Login
@app.post("/login", response_model=schemas.Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(auth.get_db)):
    user = auth.authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Username or password is incorrect",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=auth.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = auth.create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer", "id": user.id}

# Register
@app.post("/users/", response_model=schemas.UserSchema)
def create_user(user: schemas.UserCreate, db: Session = Depends(auth.get_db)):
    db_user = db.query(models.User).filter(
        (models.User.username == user.username) | 
        (models.User.email == user.email)
    ).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Username already in use")
    hashed_password = auth.get_password_hash(user.password)
    new_user = models.User(
        username=user.username,
        hashed_password=hashed_password
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


# Get All Locals
@app.get("/locals/", response_model=List[schemas.LocalSchema])
def read_locals(skip: int = 0, limit: int = 100, db: Session = Depends(auth.get_db)):
    locals = db.query(models.Local).offset(skip).limit(limit).all()
    return locals

# Get All Locals grouped by Country
@app.get("/locals/country/", response_model=Dict[str, List[schemas.LocalSchema]])
def read_locals_grouped_by_country(skip: int = 0, limit: int = 100, search: Optional[str] = None, db: Session = Depends(auth.get_db)):
    locals = db.query(models.Local).offset(skip).limit(limit).all()
    localsGroupedByCountry = {}
    for local in locals:
        if search == None or search.lower() in local.name.lower() or search.lower() in local.country.lower():
            country = local.country
            if country not in localsGroupedByCountry:
                localsGroupedByCountry[country] = []
            localsGroupedByCountry[country].append(local)
    
    # sort by country
    localsGroupedByCountry = dict(sorted(localsGroupedByCountry.items()))

    return localsGroupedByCountry


# Get All Locals by User
@app.get("/locals/{user_id}/", response_model=List[schemas.LocalSchema])
def read_user_locals(
    user_id: int,
    db: Session = Depends(auth.get_db),
):
    
    # Check if the user exists
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Obter todos os Locais associados ao usuário
    locais = db.query(models.Local).join(models.UserLocal).filter(models.UserLocal.user_id == user_id).all()
    return locais

# Endpoint para listar um Local específico de um Usuário
@app.get("/locals/{user_id}/{local_id}", response_model=schemas.UserLocalSchema)
def read_user_local_detail(
    user_id: int,
    local_id: int,
    db: Session = Depends(auth.get_db),
):    
    # Check if the user exists
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Check if the local is associated with the user
    local = db.query(models.UserLocal).filter(
        models.UserLocal.local_id == local_id,
        models.UserLocal.user_id == user_id
    ).first()

    print(local)
    
    if not local:
        local = models.UserLocal(
            user_id=user_id,
            local_id=local_id,
            image_url=None,
            visited=None
        )
    
    return local

# Scan Local by User
@app.post("/userlocal/", response_model=schemas.UserLocalSchema)
def create_user_local(
    user_local: schemas.UserLocalCreate,
    db: Session = Depends(auth.get_db),
    # current_user: models.User = Depends(auth.get_current_user)
):
    # Check if the local exists
    local = db.query(models.Local).filter(models.Local.id == user_local.local_id).first()
    if not local:
        raise HTTPException(status_code=404, detail="Local not found")
    
    new_user_local = models.UserLocal(
        user_id=user_local.user_id,
        local_id=user_local.local_id,
        image_url=user_local.image_url,
        visited=user_local.visited,
    )

    db.add(new_user_local)
    db.commit()
    db.refresh(new_user_local)

    return new_user_local

# Upload Image from Photo
@app.post("/upload-image/")
async def upload_image(file: UploadFile = File(...)):
    print("python")
    print(file)
    file_name = f"{uuid4()}.jpg"
    file_location = f"{IMAGE_DIR}/{file_name}"


    with open(file_location, "wb") as f:
        f.write(await file.read())

    image_url = f"http://{host}/{file_location}"
    return {"image_url": image_url}
