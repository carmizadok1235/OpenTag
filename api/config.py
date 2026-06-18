from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8"
    )

    secret_key: SecretStr
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    token_type: str = "bearer"
    account_store_path = "./accounts"
    anisette_sever = r"http://127.0.0.1:6969"
    anisette_libs_path = "ani_libs.bin" # change

settings = Settings()