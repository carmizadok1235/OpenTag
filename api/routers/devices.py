from typing import Annotated

from fastapi import APIRouter, status, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from database.database import get_db
from security import CurrentUser

import crud
from schemas import DeviceResponse, DeviceCreate

from exceptions import (
    DeviceNotFoundException,
    InvalidTokenException
)

router = APIRouter()


@router.post("", response_model=DeviceResponse, status_code=status.HTTP_201_CREATED)
async def create_device(
    device_data: DeviceCreate,
    curr_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)]
):
    return await crud.create_devcie(device_data, curr_user.id, db)


@router.get("", response_model=list[DeviceResponse])
async def get_devices(
    curr_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)]
):  
    return await crud.get_devices_of_user_id(curr_user.id, db)


@router.get("/{device_id}", response_model=DeviceResponse)
async def get_devices(
    device_id: int,
    curr_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)]
):
    device = await crud.get_device_by_id(device_id, db)

    if device is None:
        raise DeviceNotFoundException()
    
    if curr_user.id != device.user_id:
        raise InvalidTokenException()
    
    return device


@router.delete("/{device_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_device(
    device_id: int,
    curr_user: CurrentUser,
    db: Annotated[AsyncSession, Depends(get_db)]
):
    device = await crud.get_device_by_id(device_id, db)

    if device is None:
        raise DeviceNotFoundException()
    
    if curr_user.id != device.user_id:
        raise InvalidTokenException()
    
    await db.delete(device)
    await db.commit()