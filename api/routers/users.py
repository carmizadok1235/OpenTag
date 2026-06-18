from typing import Annotated
from datetime import datetime

from fastapi.security import OAuth2PasswordRequestForm
from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

import crud
from security import (
    create_access_token,
    verify_password,
    CurrentUser
)


from database import models
from database.database import get_db
from schemas import (
    DeviceResponse,
    UserCreate,
    UserPrivateResponse,
    UserUpdate,
    Token
)

from config import settings

from exceptions import (
    AlreadyExistException,
    IncorrectDetailsException,
    UserNotFoundException,
    InvalidTokenException
)

router = APIRouter()


@router.post("", response_model=UserPrivateResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_data: UserCreate,
    db: Annotated[AsyncSession, Depends(get_db)]
):
    if await crud.get_user_by_username(user_data.username, db):
        raise AlreadyExistException("username")
    
    return await crud.create_user(user_data, db)


@router.post("/token", response_model=Token)
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    user = await crud.get_user_by_username(form_data.username, db)

    if user is None or not verify_password(form_data.password, user.password_hash):
        raise IncorrectDetailsException()
    
    access_token = create_access_token({"sub": str(user.id)})

    return Token(access_token=access_token, token_type=settings.token_type)

@router.get("/me", response_model=UserPrivateResponse)
async def get_current_user(
    curr_user: CurrentUser
):
    return curr_user

@router.patch("/{user_id}", response_model=UserPrivateResponse)
async def update_user(
    user_id: int,
    user_data: UserUpdate,
    curr_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)]
):
    user = await crud.get_user_by_id(user_id, db)

    if user is None:
        raise UserNotFoundException()
    
    if user.id != curr_user.id:
        raise InvalidTokenException()
    
    if user_data.username is not None and user.username != user_data.username:
        if await crud.get_user_by_username(user_data.username, db):
            raise AlreadyExistException("username")
        
    return await crud.update_user(user, user_data, db)


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int,
    curr_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)]
):
    user = await crud.get_user_by_id(user_id, db)

    if user is None:
        raise UserNotFoundException()
    
    if curr_user.id != user.id:
        raise InvalidTokenException()
    
    await db.delete(user)
    await db.commit()

