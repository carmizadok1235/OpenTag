from datetime import datetime, UTC

from sqlalchemy import DateTime, ForeignKey, Integer, String, LargeBinary
from sqlalchemy.orm import Mapped, mapped_column, relationship

from database.database import Base


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    username: Mapped[str] = mapped_column(String(30), unique=False, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(200), nullable=False)
    appleid: Mapped[str] = mapped_column(String(120), nullable=False)
    apple_password: Mapped[str] = mapped_column(String(200), nullable=False)
    json_account_file: Mapped[str | None] = mapped_column(String(200), nullable=True, default=None)

    devices: Mapped[list['Device']] = relationship(back_populates="owner", cascade="all, delete-orphan")

    @property
    def json_account_path(self) -> str | None:
        if self.json_account_file is None:
            return None
        return f"/accounts/{self.json_account_file}"

class Device(Base):
    __tablename__ = "devices"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
    symmetric_key: Mapped[str] = mapped_column(String(200), nullable=False)
    private_key: Mapped[str] = mapped_column(String(200), nullable=False)
    time_paired: Mapped[datetime] = mapped_column(DateTime(timezone=UTC), default=lambda: datetime.now(UTC))

    owner: Mapped[User] = relationship(back_populates="devices")
