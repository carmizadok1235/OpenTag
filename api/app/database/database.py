from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

DATABASE_URL = "sqlite+aiosqlite:///./opentag.db"

class Base(DeclarativeBase):
    pass


engine = create_async_engine(
    url=DATABASE_URL,
    connect_args={"check_same_thread": False}
)

asyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False
)

async def get_db():
    async with asyncSessionLocal() as db:
        yield db