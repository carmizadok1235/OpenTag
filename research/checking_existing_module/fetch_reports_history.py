import logging
import sys
import base64
from datetime import datetime, timedelta, timezone

from _login import get_account_sync

from findmy import KeyPair, FindMyAccessory


# Path where login session will be stored.
# This is necessary to avoid generating a new session every time we log in.
STORE_PATH = "account.json"

# URL to LOCAL anisette server. Set to None to use built-in Anisette generator instead (recommended)
# IF YOU USE A PUBLIC SERVER, DO NOT COMPLAIN THAT YOU KEEP RUNNING INTO AUTHENTICATION ERRORS!
# If you change this value, make sure to remove the account store file.
ANISETTE_SERVER = r"http://127.0.0.1:6969"

# Path where Anisette libraries will be stored.
# This is only relevant when using the built-in Anisette server.
# It can be omitted (set to None) to avoid saving to disk,
# but specifying a path is highly recommended to avoid downloading the bundle on every run.
ANISETTE_LIBS_PATH = "ani_libs.bin"

logging.basicConfig(level=logging.INFO)

def fetch_reports(priv_key: str, symmetric_key: str) -> int:
    # Step 0: construct an account instance
    # We use a helper for this to simplify interactive authentication
    acc = get_account_sync(STORE_PATH, ANISETTE_SERVER, ANISETTE_LIBS_PATH)

    print(f"Logged in as: {acc.account_name} ({acc.first_name} {acc.last_name})")

    # Step 1: construct a key object and get its location reports
    # key = KeyPair.from_b64(priv_key)
    # location = acc.fetch_location(key)
    accessory = FindMyAccessory(
        master_key=base64.b64decode(priv_key), 
        skn=base64.b64decode(symmetric_key), 
        sks=base64.b64decode(symmetric_key),
        paired_at=datetime(2026, 5, 16, 20, 13, 17, tzinfo=timezone.utc)
    )

    # print(accessory._primary_gen._get_keypair(1).private_key_b64)
    # for index, key in accessory.keys_between(
    #     datetime.now(tz=timezone.utc) - timedelta(minutes=35),
    #     datetime.now(tz=timezone.utc)
    # ):
    #     print(f"index {index}: {key.private_key_b64}")

    locations = acc.fetch_location_history(accessory)
    
    print(len(locations))
    # Step 2: print it!
    print(locations)
    print("Last known location:")
    if locations:
        print(f" - {locations[-1]}")

    # Step 3 (optional): We can save the location report to a file if we want.
    #                    BUT WATCH OUT! This file will contain the tag's private key!
    # if location is not None:
    #     location.to_json("last_report.json")

        # To load it later:
        # loc = LocationReport.from_json("last_report.json")

    # Step 4: Make sure to save account state when you're done!
    # Otherwise you have to log in again...
    acc.to_json(STORE_PATH)

    return 0


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <private key> <symmetric key>", file=sys.stderr)
        print(file=sys.stderr)
        print("The private key should be base64-encoded.", file=sys.stderr)
        sys.exit(1)

    sys.exit(fetch_reports(sys.argv[1], sys.argv[2]))