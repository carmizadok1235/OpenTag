from typing import Annotated
from datetime import datetime, timedelta, UTC

import jwt
from fastapi.security import OAuth2PasswordBearer
from fastapi import Depends
from pwdlib import PasswordHash

from sqlalchemy.ext.asyncio import AsyncSession

from database.models import User
from database.database import get_db
import crud

from exceptions import InvalidTokenException, UserNotFoundException

from config import settings

password_hash = PasswordHash.recommended()

outh2_scheme = OAuth2PasswordBearer("/api/users/token")

def hash_password(password: str) -> str:
    return password_hash.hash(password)

def verify_password(password: str, hashed: str) -> bool:
    return password_hash.verify(password, hashed)

def create_access_token(
        data: dict,
        expires_data: timedelta | None = None
):
    to_encode = data.copy()
    if expires_data:
        expire = datetime.now(UTC) + expires_data
    else:
        expire = datetime.now(UTC) + timedelta(
            minutes=settings.access_token_expire_minutes
        )
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(
        to_encode,
        key=settings.secret_key.get_secret_value(),
        algorithm=settings.algorithm
    )

    return encoded_jwt

def verify_access_token(token: str) -> str | None:
    try:
        payload = jwt.decode(
            token,
            key=settings.secret_key.get_secret_value(),
            algorithms=[settings.algorithm],
            options={"require": ["exp", "sub"]}
        )
    except jwt.InvalidTokenError:
        return None
    else:
        return payload.get("sub")
    
async def get_current_user(
        token: Annotated[str, Depends(outh2_scheme)],
        db: Annotated[AsyncSession, Depends(get_db)]
):
    user_id = verify_access_token(token)

    if user_id is None:
        raise InvalidTokenException()
    
    try:
        user_id = int(user_id)
    except:
        raise InvalidTokenException()
    
    user = await crud.get_user_by_id(user_id, db)

    if user is None:
        raise UserNotFoundException()
    
    return user

CurrentUser = Annotated[User, Depends(get_current_user)]