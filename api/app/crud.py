from app.database.models import User, Device

from sqlalchemy import select, func
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.schemas import (
    UserUpdate,
    UserUpdatePrivate,
    UserCreate,
    DeviceCreate
)

from base64 import b64decode

from app.security import hash_password

from app.exceptions import InvalidBase64KeyException


async def get_user_by_id(id: int, db: AsyncSession) -> User | None:
    result = await db.execute(
        select(User)
        .where(User.id == id)
    )

    return result.scalars().first()

async def get_user_by_username(username: str, db: AsyncSession) -> User | None:
    result = await db.execute(
        select(User)
        .where(func.lower(User.username) == username.lower())
    )

    return result.scalars().first()

async def get_devices_of_user_id(user_id: int, db: AsyncSession) -> list[Device]:
    result = await db.execute(
        select(Device)
        .options(selectinload(Device.owner))
        .where(Device.user_id == user_id)
    )

    return result.scalars().all()

async def update_user(user: User, user_data: UserUpdate, db: AsyncSession):
    # for f, v in user_data.model_dump(exclude_unset=True).items():
    #     setattr(user, f, v.lower() if isinstance(v, str) else v)
    if user_data.username is not None:
        user.username = user_data.username.lower()
    if user_data.appleid is not None:
        user.appleid = user_data.appleid.lower()
    if user_data.apple_password is not None:
        user.apple_password = user_data.apple_password
    if isinstance(user_data, UserUpdatePrivate) and user_data.json_account_file is not None:
        user.json_account_file = user_data.json_account_file

    await db.commit()
    await db.refresh(user)

    return user

async def create_user(user_data: UserCreate, db: AsyncSession) -> User:
    new_user = User(
        username=user_data.username.lower(),
        password_hash=hash_password(user_data.password),
        appleid=user_data.appleid,
        apple_password=user_data.apple_password
    )

    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)

    return new_user

async def get_device_by_id(device_id: int, db: AsyncSession):
    result = await db.execute(
        select(Device)
        .options(selectinload(Device.owner))
        .where(Device.id == device_id)
    )

    return result.scalars().first()

async def create_devcie(device_data: DeviceCreate, curr_user_id: int, db: AsyncSession):
    try: # check if the keys are valid base64
        b64decode(device_data.private_key)
        b64decode(device_data.symmetric_key)
    except:
        raise InvalidBase64KeyException()

    new_device = Device(
        user_id=curr_user_id,
        symmetric_key=device_data.symmetric_key,
        private_key=device_data.private_key
    )

    db.add(new_device)
    await db.commit()
    await db.refresh(new_device)

    return new_device