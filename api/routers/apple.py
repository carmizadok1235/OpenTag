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

from schemas import UserUpdate

from findmy import LoginState
from findmy.reports.account import AsyncAppleAccount

from exceptions import AppleAccountLoginException

from database import models
from database.database import get_db

from schemas import AppleAccountStatus

from apple_utils.login import login_async, get_account_async

router = APIRouter()

router.get("/login", response_model=AppleAccountStatus)
async def login_to_apple_account(
    curr_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)]
):
    if curr_user.json_account_path is not None:
        return AppleAccountStatus(appleid=curr_user.appleid, verified=True)

    account = await get_account_async(curr_user)
    try:
        state = await login_async(account, curr_user)
    except:
        raise AppleAccountLoginException()
    
    ver = False
    if state == LoginState.AUTHENTICATED:
        await crud.update_user(
            curr_user,
            UserUpdate(json_account_file=curr_user.build_json_file_name()),
            db
        )
        ver = True
    
    return AppleAccountStatus(
        appleid=curr_user.appleid,
        verified=ver
    )


# router.post("/verify2fa", response_model=)