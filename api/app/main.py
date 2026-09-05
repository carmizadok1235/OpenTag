from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request, Response
from fastapi.exceptions import RequestValidationError
from fastapi.staticfiles import StaticFiles
from fastapi.exception_handlers import (
    http_exception_handler,
    request_validation_exception_handler
)
from starlette.background import BackgroundTask

from app.database.database import engine, Base

from app.routers import apple, devices
from app.routers import users

from findmy import AsyncAppleAccount
from findmy.reports.twofactor import AsyncSecondFactorMethod

from typing import Callable
import logging

@asynccontextmanager
async def lifespan(_app: FastAPI):
    # Startup
    _app.state.sessions = {} 
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    await engine.dispose()
    _app.state.sessions.clear()


def log(req_body, res_body) -> None:
    logging.info("-------------------------------------------------------------------------------")
    logging.info(f"Request Body:\n{req_body}")
    logging.info(f"Response Body:\n{res_body}")
    logging.info("-------------------------------------------------------------------------------")


# app = FastAPI()
app = FastAPI(lifespan=lifespan)
logging.getLogger("watchfiles.main").setLevel(logging.ERROR)
logging.basicConfig(filename="trace.log",level=logging.INFO)
# app.mount("/media", StaticFiles(directory="media"), name="media")

app.include_router(users.router, prefix="/api/users", tags=["users"])
app.include_router(devices.router, prefix="/api/devices", tags=["devices"])
app.include_router(apple.router, prefix="/api/apple", tags=["apple login"])


@app.middleware("http")
async def requests_logger_middleware(request: Request, call_next: Callable[[Request], Response]) -> Response:
    req_body = await request.body()
    response: Response = await call_next(request)

    chunks = []
    async for chunk in response.body_iterator:
        chunks.append(chunk)
    res_body = b"".join(chunks)

    task = BackgroundTask(log, req_body=req_body, res_body=res_body)

    return Response(
        res_body,
        response.status_code, 
        dict(response.headers), 
        response.media_type, 
        background=task
    )


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