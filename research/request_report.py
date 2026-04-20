import requests
import hashlib
import srp._pysrp as srp
import plistlib as plist
import pprint
import hashlib, pbkdf2
from dataclasses import dataclass, fields, field
from enum import StrEnum
from Crypto.Hash import SHA256

import urllib3
urllib3.disable_warnings()

srp.rfc5054_enable()
srp.no_username_in_x()


# APPLE_URL = r"https://gateway.icloud.com/acsnservice/fetch"
APPLE_URL = r"https://gsa.apple.com/grandslam/GsService2"
ANISETTE_SERVER = r"http://127.0.0.1:6969"



class PasswordProtocols(StrEnum):
	S2K = "s2k"
	S2K_FO = "s2k_fo"

class Operations(StrEnum):
	INIT = "init"
	COMPLETE = "complete"

	# def __getattribute__(self, name):
	# 	return str()

@dataclass
class ReqDataGENERAL:
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

def derive_password(password: str, salt: bytes, iterations: int) -> bytes:
	p = hashlib.sha256(password.encode("utf-8")).digest()
	return pbkdf2.PBKDF2(p, salt, iterations, SHA256).read(32)
	

def get_anisette_data() -> dict:
	print(f"Requesting anisette data from {ANISETTE_SERVER}")
	ani_data = requests.get(url=ANISETTE_SERVER).json()

	return ani_data

def generate_cpd(anisette_data: dict):
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

	headers = {
		# 'Host': 'gsa.apple.com',
		'Content-Type': 'text/x-xml-plist',
		# 'X-Mme-Client-Info': '<iPhone6,1> <iPhone OS;12.4.8;16G201> <com.apple.akd/1.0 (com.apple.akd/1.0)>',
		# 'X-Mme-Client-Info': "<MacBookPro18,3> <Mac OS X;13.4.1;22F8> <com.apple.AOSKit/282 (com.apple.dt.Xcode/3594.4.19)>",
		'X-MMe-Client-Info': anisette_data["X-MMe-Client-Info"],
		'Accept': '*/*',
		'Accept-Language': 'en-us',
		'User-Agent': 'akd/1.0 CFNetwork/978.0.7 Darwin/18.7.0'
	}

	data = {
		"Header": {"Version": "1.0.1"},
        "Request": {"cpd": generate_cpd(anisette_data)},
	}

	request: dict = data['Request']
	request.update(req_data)

	

	res = requests.post(url=APPLE_URL, data=plist.dumps(data), headers=headers, verify=False)
	return plist.loads(res.content)

def icloud_login(username: str, password: bytes):

	user = srp.User(username, bytes(), hash_alg=srp.SHA256, ng_type=srp.NG_2048)
	_, A = user.start_authentication()

	anisette_data = get_anisette_data()

	print("Sending Request 1 - INIT")
	response1 = do_gsa_request(ReqDataINIT(o=Operations.INIT, A2k=A, u=username), anisette_data=anisette_data)['Response']
	pprint.pprint(response1)

	if response1['Status']['hsc'] != 200:
		raise Exception("Request 1 Failed")
	if response1['sp'] != PasswordProtocols.S2K.value:
		raise Exception("s2k_fo derivition protocol still not implemented")

	user.p = derive_password(password, response1['s'], response1['i'])
	
	M1 = user.process_challenge(response1['s'], response1['B'])

	print("Sending Request 2 - COMPLETE")
	response2 = do_gsa_request(ReqDataCOMPLETE(o=Operations.COMPLETE, c=response1['c'], M1=M1, u=username), anisette_data=anisette_data)
	pprint.pprint(response2)
	exit()
	


def main():

	icloud_login("","")


if __name__ == "__main__":
	main()

