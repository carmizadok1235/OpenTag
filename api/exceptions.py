from fastapi import HTTPException, status

class _NotFoundException(HTTPException):
    def __init__(self, detail):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=detail
        )

class UserNotFoundException(_NotFoundException):
    def __init__(self):
        super().__init__(
            "User not found"
        )

class AlreadyExistException(HTTPException):
    def __init__(self, field):
        super().__init__(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"{field} already exist"
        )

class _UnauthorizedException(HTTPException):
    def __init__(self, detail):
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
