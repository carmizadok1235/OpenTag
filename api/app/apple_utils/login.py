

from findmy import (
    AsyncAppleAccount,
    LocalAnisetteProvider,
    LoginState,
    RemoteAnisetteProvider,
    SmsSecondFactorMethod
)
from findmy.reports.twofactor import AsyncSecondFactorMethod

from app.database.models import User

from app.exceptions import NoSmsTwoFactorMethodAuthException

from app.config import settings

def logged_in(user: User, account: AsyncAppleAccount):
    account.to_json(
        settings.account_store_path.joinpath(user.build_json_file_name())
    )


async def trigger_2fa(account: AsyncAppleAccount) -> AsyncSecondFactorMethod:
    # This only supports SMS methods for now
    methods: list[AsyncSecondFactorMethod] = await account.get_2fa_methods()

    # Print the (masked) phone numbers
    ind = None
    for i, method in enumerate(methods):
        if isinstance(method, SmsSecondFactorMethod):
            # print(f"{i} - SMS ({method.phone_number})")
            ind = i

    if ind is None:
        raise NoSmsTwoFactorMethodAuthException()
    method = methods[ind]
    await method.request()

    return method
    # code = input("Code? > ")

    # This automatically finishes the post-2FA login flow
    # await method.submit(code)

async def login_async(account: AsyncAppleAccount, user: User) -> LoginState:
    email = user.appleid
    password = user.apple_password

    state = await account.login(email, password)

    if state == LoginState.LOGGED_OUT: # need to change it
        print(f"--------- Login State is {state} --------- ")
        raise Exception()
    
    return state

async def get_account_async(
    user: User
) -> AsyncAppleAccount:
    """Tries to restore a saved Apple account, or prompts the user for login otherwise. (async)"""
    try:
        if user.json_account_file is None:
            raise FileNotFoundError()
        acc = AsyncAppleAccount.from_json(
            settings.account_store_path.joinpath(user.json_account_file),
            anisette_libs_path=settings.anisette_libs_path
        )
    except FileNotFoundError:
        ani = (
            LocalAnisetteProvider(libs_path=settings.anisette_libs_path)
            if settings.anisette_sever is None
            else RemoteAnisetteProvider(settings.anisette_sever)
        )
        acc = AsyncAppleAccount(ani)
        # await _login_async(acc, user)

        # acc.to_json(store_path)

    return acc
