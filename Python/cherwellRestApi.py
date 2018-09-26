#Copyright 2018 Cherwell Software, LLC
#
#Permission is hereby granted, free of charge, to any person 
#obtaining a copy of this software and associated documentation
#files (the "Software"), to deal in the Software without restriction, 
#including without limitation the rights to use, copy, modify, merge, publish, 
#distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in 
#all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
#IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
#DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
#TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
#SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import requests
#requests module can be installed by "pip install requests"

#bind for proxy, 'http': '127.0.0.1:8888' default for fidder.
proxies = {}

webApiUrl = "http://localhost/Trebuchet.WebApi"
clientKey = "RESTAPIKEYFROMADMIN"
myUser = "CHERWELLUSERNAMEHERE"
myPass = "CHERWELLPASSWORDHERE"

tokenReqBody = "grant_type=password&client_id=[CLIENTKEY]&username=[USER]&password=[PASS]&auth_mode=Internal"

tokenReqBody = tokenReqBody.replace("[CLIENTKEY]", clientKey)
tokenReqBody = tokenReqBody.replace("[USER]", myUser)
tokenReqBody = tokenReqBody.replace("[PASS]", myPass)

resp = requests.post(webApiUrl + "/token", data=tokenReqBody, headers={'Accept':'application/json'}, proxies=proxies)

if resp.status_code != 200:
    # This means something went wrong.
    raise Exception('POST /token {}'.format(resp.status_code))

respDict = resp.json()

accessToken = "Bearer " + respDict['access_token']

#Setup our query to the web api
reqBody = """{"busObId": "9344be92d5b7b4c290437c4110bc5b7147c9e3e98a",
  "fields": [ ], 
  "filters": [ ], 
  "includeAllFields": true, 
  "includeSchema": false,
  "pageNumber": 0, 
  "pageSize": 1000, 
  "sorting": [ ], "promptValues": [ ] }"""

headers = {
	'Authorization': accessToken,
	'Accept':'application/json',
	'Content-Type': 'application/json'
}

#Do the query
resp = requests.post(webApiUrl + "/api/V1/getsearchresults", data=reqBody, headers=headers, proxies=proxies)
print(resp.json());
if resp.status_code != 200:
    # This means something went wrong.
	raise Exception('POST /api/V1/getsearchresults {}'.format(resp.status_code))

#Cleanup Logout.
resp = requests.delete(webApiUrl + "/api/V1/logout", data=reqBody, headers=headers, proxies=proxies)
if resp.status_code != 200:
    # This means something went wrong.
	raise Exception('POST /api/V1/logout {}'.format(resp.status_code))

print("Completed.")