from typing import Annotated, TypeAlias
from datetime import datetime

from fastapi.security import OAuth2PasswordRequestForm
from fastapi import APIRouter, Depends, status, Request
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

import app.crud as crud
from app.security import (
    create_access_token,
    verify_password,
    CurrentUser
)
from app.schemas import UserUpdatePrivate

from findmy import LoginState, AsyncAppleAccount
from findmy.reports.twofactor import AsyncSecondFactorMethod

from app.exceptions import InvalidCredentialsException, InvalidVerificationCodeException, TwoFactorAuthNotTriggeredException

from app.database.models import User
from app.database.database import get_db

from app.schemas import AppleAccountStatus, AppleSubmit2faCode

from app.apple_utils import login

from app.config import settings

ACCOUNT_INDEX = 0
METHOD_INDEX = 1

AppleLoginSessions: TypeAlias = dict[int, tuple[AsyncAppleAccount, AsyncSecondFactorMethod]]

def get_sessions(request: Request) -> dict:
    return request.app.state.sessions

async def on_verified(user: User, db: AsyncSession):
    await crud.update_user(
            user,
            UserUpdatePrivate(json_account_file=user.build_json_file_name()),
            db
        )

router = APIRouter()

@router.get("/login", response_model=AppleAccountStatus)
async def login_to_apple_account(
    curr_user: CurrentUser,
    sessions: Annotated[AppleLoginSessions, Depends(get_sessions)],
    db: Annotated[AsyncSession, Depends(get_db)]
):
    if curr_user.json_account_path is not None:
        return AppleAccountStatus(appleid=curr_user.appleid, verified=True)

    account = await login.get_account_async(curr_user)
    try:
        state = await login.login_async(account, curr_user)
        # print(f"State is {state}")
    except:
        raise InvalidCredentialsException()
    
    ver = False
    if state == LoginState.AUTHENTICATED or state == LoginState.LOGGED_IN:
        await on_verified(curr_user, db)
        login.logged_in(curr_user, account)
        ver = True
    elif state == LoginState.REQUIRE_2FA:
        sessions[curr_user.id] = (account, (await login.trigger_2fa(account)))

    return AppleAccountStatus(
        appleid=curr_user.appleid,
        verified=ver
    )


@router.post("/verify2fa", response_model=AppleAccountStatus, status_code=status.HTTP_202_ACCEPTED)
async def verfiy_2fa_code(
    curr_user: CurrentUser,
    sessions: Annotated[AppleLoginSessions, Depends(get_sessions)],
    data: AppleSubmit2faCode,
    db: Annotated[AsyncSession, Depends(get_db)]
):
    if curr_user.json_account_path is not None:
        return AppleAccountStatus(appleid=curr_user.appleid, verified=True)

    if sessions.get(curr_user.id) is None:
        raise TwoFactorAuthNotTriggeredException()
    
    account = sessions[curr_user.id][ACCOUNT_INDEX]
    
    try:
        state = (await sessions[curr_user.id][METHOD_INDEX].submit(data.code))
    except:
        raise InvalidVerificationCodeException()
    
    # print(state)
    if state == LoginState.LOGGED_IN:
        on_verified(curr_user, db)
        login.logged_in(curr_user, account)
    else:
        raise InvalidCredentialsException()
    
    del sessions[curr_user.id]
    await account.close()

    return AppleAccountStatus(appleid=curr_user.appleid, verified=True)
    