import os
import re
import json 
import sys, getopt
import shutil
import requests
import getpass
from requests.auth import HTTPBasicAuth

def read_all(path):
    with open(path, 'r') as in_file:
        return in_file.read()

CONFIG_FILE = "C:\\config\\fmodauth.json"
BUILD_FILE = "C:\\3p-fmodstudio\\build-cmd.sh"

LOGIN_URL = "https://www.fmod.com/api-login"
LIST_URL = "https://www.fmod.com/api-downloads"
DOWNLOAD_URL = "https://www.fmod.com/api-get-download-link?path=%s&filename=%s&user_id=%s"

build_file_content = read_all(BUILD_FILE)
ver = re.search(r"FMOD_VERSION_PRETTY=\"([^\"]+)\"", read_all(BUILD_FILE)).group(1)

if len(sys.argv) > 1:
	wantver = sys.argv[1]
	if sys.argv[1] != "auto" and wantver != ver:
		print("Current version is '%s', but we want '%s'" % (ver, wantver))
		build_file_content = re.sub(r"FMOD_VERSION=\"([\"]+)\"", wantver.replace(".", ""), build_file_content)
		build_file_content = re.sub(r"FMOD_VERSION_PRETTY=\"([\"]+)\"", wantver, build_file_content)
		
		with open(BUILD_FILE, 'w') as out_file:
			out_file.write(build_file_content)
		
		ver = wantver
else:
    print('Version: ' + ver)

Username = ""
Password = ""

def download():
	login_response = requests.post(url = LOGIN_URL, auth = HTTPBasicAuth(Username, Password)).json()
	list_response = requests.get(url = LIST_URL, headers = { 'Authorization' : 'FMOD %s' % login_response['token'] }).json()

	fmod_list = next(x for x in list_response['downloads']['categories'] if x['title'] == 'FMOD Studio Suite')
	api_list = next(x for x in fmod_list['products'] if x['title'] == 'FMOD Engine')['versions']

	def extract_download(o):
		win = next(x for x in o['platforms'] if x['title'] == 'Windows')
		return { 'version': o['version'], 'ver': int(o['version'].replace('.', '')), 'note': win['platform_note'], 'path': win['dl1Path'], 'file': win['dl1filename'] }

	download_list = map(extract_download, api_list)

	correct_download = next(x for x in download_list if x['version'] == ver)
	correct_download_url = DOWNLOAD_URL % (correct_download['path'], correct_download['file'], login_response['user'])
	correct_download_response = requests.get(url = correct_download_url, headers = { 'Authorization' : 'FMOD %s' % login_response['token'] }).json()

	print("Downloading...")
	download_response = requests.get(url = correct_download_response['url'], stream=True)

	if not os.path.exists('3p-fmodstudio'):
		os.makedirs('3p-fmodstudio')

	with open("3p-fmodstudio/" + correct_download['file'], 'wb') as out_file:
		shutil.copyfileobj(download_response.raw, out_file)

	print('Downloaded FMOD!')

if os.path.exists(CONFIG_FILE):
	fmodconfig = json.loads(read_all(CONFIG_FILE))
	Username = fmodconfig['username']
	Password = fmodconfig['password']
	
	print('Loaded user: ' + Username)
	download()
else:
	print("You have to download FMOD API from 'https://www.fmod.com' (you need an account)")
	while True:
		opt = raw_input("Do you want to automate the proccess? (Y/n)")
		if opt == "" or opt.lower() == "y":
			print("Go to 'https://www.fmod.com' and register an account, then enter the login info here:")
			Username = raw_input("Username: ")
			Password = raw_input("Password: ")
			
			download()
			
			break
		elif opt.lower() == "n":
			raw_input("Download the FMOD API version " + ver + " from 'https://www.fmod.com/download' and put it in C:\\3p-fmodstudio")
			break
