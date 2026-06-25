from datetime import datetime, UTC

from base64 import b64decode

from app.database.models import Device
from app.schemas import LocationCoordinates

from findmy import FindMyAccessory, AsyncAppleAccount

from app.exceptions import JsonFileNotExistException, InvalidKeyException

from app.config import settings

async def fetch_report(
    device: Device, 
    json_file: str | None
) -> LocationCoordinates | None:
    if json_file is None:
        raise JsonFileNotExistException
    
    try:
        account = AsyncAppleAccount.from_json(
            settings.account_store_path.joinpath(json_file),
            anisette_libs_path=settings.anisette_libs_path
        )
    except FileNotFoundError:
        return None

    try:
        accessory = FindMyAccessory(
            master_key=b64decode(device.private_key),
            skn=b64decode(device.symmetric_key),
            sks=b64decode(device.symmetric_key),
            paired_at=device.time_paired.astimezone(UTC)
        )
    except:
        raise InvalidKeyException()
    
    location = None
    try:
        location = await account.fetch_location(accessory)
    except Exception as e:
        print(e)
    
    if location is None:
        return None

    return LocationCoordinates(
        longitude=location.longitude,
        latitude=location.latitude,
        minutes_updated_ago=(datetime.now(UTC) - location.timestamp).seconds//60
    )
