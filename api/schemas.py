from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, EmailStr, FilePath

class UserBase(BaseModel):
    username: str = Field(min_length=5, max_length=30)

class UserCreate(UserBase):
    password: str = Field(min_length=8)
    appleid: EmailStr = Field(max_length=120)
    apple_password: str = Field(max_length=200)


class UserUpdate(UserBase):
    username: str | None = Field(default=None, min_length=1, max_length=50)
    appleid: EmailStr | None = Field(default=None, max_length=120)
    apple_password: str | None = Field(default=None, max_length=200)
    json_account_file: str | None = Field(default=None)

class UserPrivateResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    username: str
    appleid : EmailStr
    json_account_path: FilePath | None

class DeviceBase(BaseModel): 
    pass

class DeviceCreate(DeviceBase):
    symmetric_key: str
    private_key: str
    time_paired: datetime = Field(default=None)

class DeviceResponse(DeviceBase):
    model_config = ConfigDict(from_attributes=True)
    id: int
    user_id: int
    time_paired: datetime
    owner: UserPrivateResponse

class Token(BaseModel):
    access_token: str
    token_type: str

class AppleAccountStatus(BaseModel):
    appleid: str
    verified: bool

class AppleSubmit2faCode(BaseModel):
    code: str