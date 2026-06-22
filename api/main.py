from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.staticfiles import StaticFiles
from fastapi.exception_handlers import (
    http_exception_handler,
    request_validation_exception_handler
)

from database.database import engine, Base

from routers import apple, users, devices

from findmy import AsyncAppleAccount
from findmy.reports.twofactor import AsyncSecondFactorMethod


@asynccontextmanager
async def lifespan(_app: FastAPI):
    # Startup
    _app.state.sessions = {} 
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    await engine.dispose()
    _app.state.sessions.clear()

# app = FastAPI()
app = FastAPI(lifespan=lifespan)
# app.mount("/media", StaticFiles(directory="media"), name="media")

app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(devices.router, prefix="/api/devices", tags=["devices"])
app.include_router(apple.router, prefix="/api/apple", tags=["apple login"])


@app.exception_handler(HTTPException)
async def general_http_exception_handler(request: Request, exception: HTTPException):
    # message = exception.detail if exception.detail else "An error occurred. Please check your request and try again."

    # return JSONResponse(
    #     content={"detail": message},
    #     status_code=exception.status_code
    # )
    return await http_exception_handler(request, exception)


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exception: RequestValidationError):
    # return JSONResponse(
    #     content={"detail": exception.errors()},
    #     status_code=status.HTTP_422_UNPROCESSABLE_ENTITY
    # )
    return await request_validation_exception_handler(request, exception)