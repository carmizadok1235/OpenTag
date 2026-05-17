import requests
import hashlib
import srp._pysrp as srp
import plistlib as plist
import pprint
import hashlib, pbkdf2
from dataclasses import dataclass, fields, field
from abc import ABC
from enum import StrEnum
from Crypto.Hash import SHA256
import hmac
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
import base64
import uuid

import urllib3
urllib3.disable_warnings()

srp.rfc5054_enable()
srp.no_username_in_x()

USER_ID = uuid.uuid4()

APPLE_URL = r"https://gsa.apple.com/grandslam/GsService2"
ANISETTE_SERVER = r"http://127.0.0.1:6969"
APPLE_2FA_URL = r"https://gsa.apple.com/auth/verify/phone/"
LOGIN_DELEGATES = r"https://setup.icloud.com/setup/iosbuddy/loginDelegates"


class PasswordProtocols(StrEnum):
	S2K = "s2k"
	S2K_FO = "s2k_fo"

class Operations(StrEnum):
	INIT = "init"
	COMPLETE = "complete"

@dataclass
class ReqDataGENERAL(ABC):
	o: Operations

	def __iter__(self):
		for f in fields(self):
			attr = self[f.name]
			if isinstance(attr, StrEnum):
				attr = str(attr)
			
			yield (f.name, attr)

	def __getitem__(self, item):
		return getattr(self, item)

# {'A2k': A, 'ps': ['s2k', 's2k_fo'], 'u': username 'o': 'init'}
@dataclass
class ReqDataINIT(ReqDataGENERAL):
	# o: Operations = Operations.INIT
	A2k: bytes
	u: str
	ps: list[PasswordProtocols] = field(default_factory=lambda: [PasswordProtocols.S2K.value, PasswordProtocols.S2K_FO.value])

# {"c": r["c"], "M1": M, "u": username, "o": "complete"}
@dataclass
class ReqDataCOMPLETE(ReqDataGENERAL):
	# o: Operations = Operations.COMPLETE
	c: str
	M1: bytes
	u: str

def generate_headers() -> dict:
	headers = {
		# 'Host': 'gsa.apple.com',
		'Content-Type': 'text/x-xml-plist',
		'Accept': '*/*',
		'Accept-Language': 'en-us',
		'User-Agent': 'akd/1.0 CFNetwork/978.0.7 Darwin/18.7.0'
	}
	
	return headers

def check_response(res: dict) -> bool:
	if res['Response']['Status']['hsc'] != 200 or res['Response']['Status']['ec'] != 0:
			raise Exception(f"Request Failed - {res['Response']['Status']['em']}")

def request_2fa(identity_token: str, code: str | None = None, anisette_data: dict | None = None) -> None:
	if anisette_data is None:
		anisette_data = get_anisette_data()

	headers = {
		'X-Apple-Identity-Token': identity_token,
		'User-Agent': 'Xcode',
		'X-Xcode-Version': '11.2 (11B41)',
		'X-Apple-App-Info': 'com.apple.gs.xcode.auth',
		'Accept-Language': 'en-us',
		'Loc': 'en_US',
		'accept': 'application/json'
	}

	headers.update(anisette_data)

	body = {
		'phoneNumber': {'id': 1},
		'mode': 'sms',
		'securityCode': {'code': code}
	}

	request_url = APPLE_2FA_URL + ("securitycode" if code is not None else "")
	print(f"Sending 2fa Request to {request_url}")
	res = requests.post(
		url=request_url,
		json=body,
		headers=headers,
		verify=False
	)
	
	if not res.ok:
		raise Exception("Failed 2fa")
	print("Success 2fa")

def do_2fa(adsid, gsIdmsToken, anisette_data: dict | None = None) -> None:
	print("Statring 2FA Authentication")
	identity_token = base64.b64encode(f"{adsid}:{gsIdmsToken}".encode()).decode()
	# identity_token = input("Enter identity token: ")

	# print(f"identity token: {identity_token}")
	request_2fa(identity_token, anisette_data=anisette_data)

	code = input("Enter 2fa code: ")

	request_2fa(identity_token, code=code, anisette_data=anisette_data)



def decrypt_spd(spd: bytes, session_key: bytes) -> dict:
	# derive AES key
	aes_key = hmac.new(session_key, b"extra data key:", hashlib.sha256).digest()

	# derive IV
	aes_iv = hmac.new(session_key, b"extra data iv:", hashlib.sha256).digest()
	aes_iv = aes_iv[:16]   # truncate to 16 bytes for AES block size

	cipher = Cipher(algorithms.AES(aes_key), modes.CBC(aes_iv))
	decryptor = cipher.decryptor()
	padded_data = decryptor.update(spd) + decryptor.finalize()

	unpadder = padding.PKCS7(128).unpadder()
	decrypted = unpadder.update(padded_data) + unpadder.finalize()

	plist_header = b'<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
	return plist.loads(plist_header + decrypted)

def derive_password(password: str, salt: bytes, iterations: int, protocol: PasswordProtocols = PasswordProtocols.S2K) -> bytes:
	p = hashlib.sha256(password.encode("utf-8")).digest()
	if protocol == PasswordProtocols.S2K_FO:
		p = p.hex().encode("utf-8")
	return pbkdf2.PBKDF2(p, salt, iterations, SHA256).read(32)
	
def get_anisette_data() -> dict:
	print(f"Requesting anisette data from {ANISETTE_SERVER}")
	try:
		ani_data = requests.get(url=ANISETTE_SERVER).json()
	except Exception as e:
		print("Failed to connect to anisette server")
		exit(1)
	return ani_data

def generate_cpd(anisette_data: dict) -> dict:
	cpd = {
		'bootstrap': True,
		'capp': "Xcode",
		'prkgen': True,
		'loc': "en_US",
		'pbe': False,
		'svct': "iCloud",
		'icscrec': True
	}

	cpd.update(anisette_data)
	return cpd


def do_gsa_request(req_data: ReqDataGENERAL, anisette_data: dict | None = None) -> str:
	if anisette_data is None:
		anisette_data = get_anisette_data()

	headers = generate_headers()
	headers['X-MMe-Client-Info'] = anisette_data['X-MMe-Client-Info']

	data = {
		"Header": {"Version": "1.0.1"},
        "Request": {"cpd": generate_cpd(anisette_data)}
	}

	request: dict = data['Request']
	request.update(req_data)


	res = plist.loads(
		requests.post(
			url=APPLE_URL,
			data=plist.dumps(data),
			headers=headers, verify=False).content
	)
	pprint.pprint(res)
	check_response(res)
	return res

def gsa_login(username: str, password: bytes) -> dict:

	user = srp.User(username, bytes(), hash_alg=srp.SHA256, ng_type=srp.NG_2048)
	_, A = user.start_authentication()

	anisette_data = None

	print("Sending Request 1 - INIT")
	response1 = do_gsa_request(ReqDataINIT(o=Operations.INIT, A2k=A, u=username), anisette_data=anisette_data)['Response']

	protocol = PasswordProtocols.S2K if response1['sp'] == PasswordProtocols.S2K.value else PasswordProtocols.S2K_FO
	user.p = derive_password(password, response1['s'], response1['i'], protocol=protocol)
	
	M1 = user.process_challenge(response1['s'], response1['B'])

	print("Sending Request 2 - COMPLETE")
	response2 = do_gsa_request(ReqDataCOMPLETE(o=Operations.COMPLETE, c=response1['c'], M1=M1, u=username), anisette_data=anisette_data)['Response']

	M2 = response2['M2']

	user.verify_session(M2)
	if not user.authenticated():
		raise Exception("session is not verfied")
	
	spd = response2['spd']

	spd = decrypt_spd(spd, user.get_session_key())

	adsid = spd['adsid']
	gsIdmsToken = spd['GsIdmsToken']
	if response2['Status'].get('au') in ['secondaryAuth', 'trustedDeviceSecondaryAuth']:
		do_2fa(adsid, gsIdmsToken)

		return gsa_login(username, password)
	
	return spd

def icloud_login(username, password):

	spd = gsa_login(username, password)
	pet = spd['t']['com.apple.gs.idms.pet']['token']
	adsid = spd['adsid']

	headers = generate_headers()
	headers['X-Apple-ADSID'] = adsid
	headers.update(get_anisette_data())

	data = {
		'apple-id': username,
		'delegates': {'com.apple.mobileme':{}},
		'password': pet,
		'client-id': str(USER_ID)
	}

	print("Sending Login Delegates Request")
	r = requests.post(
		url=LOGIN_DELEGATES,
		auth=(username, pet),
		data=plist.dumps(data),
		headers=headers,
		verify=False
	)
	print(r)
	return plist.loads(r.content)



def main():
	res = icloud_login("","")

if __name__ == "__main__":
	main()

