from pydantic import SecretStr, DirectoryPath, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict
from pathlib import Path
from asyncio import get_running_loop
from typing import Any
import logging

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8"
    )

    secret_key: SecretStr
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    token_type: str = "bearer"
    account_store_path: DirectoryPath = "./accounts"
    anisette_sever: str = r"http://127.0.0.1:6969"
    anisette_libs_path: str = "ani_libs.bin" # change

    @field_validator("account_store_path", mode="before")
    @classmethod
    def ensure_directory_exists(cls, v: Any) -> DirectoryPath:
        p: DirectoryPath = DirectoryPath(v)
        if not p.resolve().is_relative_to(Path.cwd()):
            logging.critical("Path Travesal identified - exit program")
            get_running_loop().stop()

        if not p.exists():
            p.mkdir()
        return p
        

settings = Settings()