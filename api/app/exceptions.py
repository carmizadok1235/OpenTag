from fastapi import HTTPException, status

class _NotFoundException(HTTPException):
    def __init__(self, detail: str):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=detail
        )

class UserNotFoundException(_NotFoundException):
    def __init__(self):
        super().__init__(
            "User not found"
        )

class DeviceNotFoundException(_NotFoundException):
    def __init__(self):
        super().__init__(
            "Device not found"
        )

class AlreadyExistException(HTTPException):
    def __init__(self, field: str):
        super().__init__(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"{field} already exist"
        )

class _UnauthorizedException(HTTPException):
    def __init__(self, detail: str):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=detail,
            headers={"WWW-Authenticate": "Bearer"}
        )

class IncorrectDetailsException(_UnauthorizedException):
    def __init__(self):
        super().__init__(
            "Incorrect username or password"
        )

class InvalidTokenException(_UnauthorizedException):
    def __init__(self):
        super().__init__(
            "Invalid or expired token"
        )

class NoSmsTwoFactorMethodAuthException(HTTPException):
    def __init__(self):
        super().__init__(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="sms second factor method is not available"
        )

class _AppleAccountLoginException(HTTPException):
    def __init__(self, detail: str):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=detail
        )

class InvalidCredentialsException(_AppleAccountLoginException):
    def __init__(self):
        super().__init__(
            detail="Invalid AppleId or Password"
        )

class InvalidVerificationCodeException(_AppleAccountLoginException):
    def __init__(self):
        super().__init__(
            detail="Invalid Verfication Code"
        )

class TwoFactorAuthNotTriggeredException(HTTPException):
    def __init__(self):
        super().__init__(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="2fa is not triggered, first login"
        )
