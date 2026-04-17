import requests
import hashlib
import time
import base64
import srp
import base64
from datetime import datetime
import plistlib as plist
import json
import pprint


# APPLE_URL = r"https://gateway.icloud.com/acsnservice/fetch"
APPLE_URL = r"https://gsa.apple.com/grandslam/GsService2"
ANISETTE_SERVER = r"http://127.0.0.1:6969"


def get_anisette_data() -> dict:
	ani_data = requests.get(url=ANISETTE_SERVER).json()
	# del ani_data['X-Apple-I-MD-LU']
	# del ani_data['X-Apple-I-TimeZone']
	# del ani_data['X-Apple-Locale']
	# del ani_data['X-MMe-Client-Info']
	return ani_data

def build_plist_data(username: str, a2k: bytes, anisette_data: dict | None = None) -> str:
	if anisette_data is None:
		anisette_data = get_anisette_data()

	with open("./apples_GSA_first_request_plist.plist", 'rb') as file:
		plist_parsed_data = plist.load(file)

	request = plist_parsed_data['Request']

	request['A2k'] = a2k

	request['cpd'] = request['cpd'] | anisette_data
	print(request['u'])
	request['u'] = username
	return plist.dumps(plist_parsed_data)

def GSA_authenticate(username, password):

	# Create the a2k section of the plist payload.
	a2k_data = srp.create_salted_verification_key(username, password, hash_alg=srp.SHA256, ng_type=srp.NG_2048)
	a2k = a2k_data[1]
	# a2k = base64.b64encode(a2k_data[1])
	# a2k = base64.b64encode(a2k_data[1]).decode("utf-8")
	print(base64.b64encode(a2k_data[1]).decode("utf-8"))
	# time = datetime.utcnow().isoformat()[:-7]+'Z'

	# Get the anisette data
	anisette_data = requests.get(url=ANISETTE_SERVER).json()
	# print(f"X-MMe-Client-Info: {anisette_data['X-MMe-Client-Info']}")
	# Request headers for Apple's GSA API.

	headers = {
		# 'Host': 'gsa.apple.com',
		'Content-Type': 'text/x-xml-plist',
		# 'X-Mme-Client-Info': '<iPhone6,1> <iPhone OS;12.4.8;16G201> <com.apple.akd/1.0 (com.apple.akd/1.0)>',
		# 'X-Mme-Client-Info': "<MacBookPro18,3> <Mac OS X;13.4.1;22F8> <com.apple.AOSKit/282 (com.apple.dt.Xcode/3594.4.19)>",
		'X-Mme-Client-Info': anisette_data["X-MMe-Client-Info"],
		'Accept': '*/*',
		'Accept-Language': 'en-us',
		'User-Agent': 'akd/1.0 CFNetwork/978.0.7 Darwin/18.7.0'
	}

	# url = "https://gsa.apple.com/grandslam/GsService2"
	
	data = build_plist_data(username, a2k, anisette_data=anisette_data).decode()
	print(data)
	r = requests.post(url=APPLE_URL, data=data, headers=headers, verify=False)
	content = r.content

	print(content.decode())

	# with open("./apples_GSA_first_request_plist.plist", 'rb') as file:
	# 	plist_parsed_data = plist.load(file)

	# plist_parsed_data = plist.loads(data)
	# plist_parsed_data = plist.dumps(plist_parsed_data)
	# print(data)
	# print(build_plist_data(username, a2k).decode())


def main():

	GSA_authenticate("","")


if __name__ == "__main__":
	main()

