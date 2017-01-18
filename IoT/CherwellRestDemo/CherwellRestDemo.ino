/*

The MIT License (MIT)
Copyright (c) 2016 W. Jacob Harris

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be included 
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/


/*
 *
 * W5200 Ethernet Shield v2.2 12A14
 * www.seeedstudio.com
 Ethernet: SPI pins MOSI, MISO, SCK, and CS/SS of this chip are connected
 to digital pins 11, 12, 13, and 10 respectively.

 MicroSD card socket: A microSD card socket for projects that require memory storage.
 The SPI pins MOSI, MISO, SCK, and CS/SS of this socket are connected
 to digital pins 11, 12, 13, and 4 respectively.


 */

#include <SPI.h>
#include <EthernetV2_0.h>

#include <SD.h>

// Network support
// Enter a MAC address for your controller below.
byte _mac[] = {0xD6, 0xAD, 0xBC, 0xF1, 0xFC, 0xED };
#define W5200_CS  10

// CS pin of SD card
#define SDCARD_CS 7 ///THIS IS NOT THE DEFAULT, USUALLY 4 CHECK YOUR HARDWARE!!!!

#define TOKENLEN 575

#define FILE_RESPONSE "resp.txt"
#define FILE_REQUEST "req.txt"
#define FILE_TOKEN "token.txt"


//Globals
EthernetClient  _client;

//You should probably change this.
const char _server[] = "<Change Me>"; //IP Address of server i.e. 192.168.0.5
const int _port = 80;
const char _clientKey[] = "<Change Me>"; //The Rest API Key from admin
const char _userName[] = "<Change Me>"; //CSM User Name
const char _password[] = "<Change Me>"; //CSM Password


File _requestFile;
File _responseFile;
File _tokenFile;

void setup()
{
  Serial.begin(9600);
  /* 
  // Uncomment block to wait for USB Serial
  while (!Serial) {

  }
  */
  Serial.println(F("Init..."));
  pinMode(W5200_CS, OUTPUT);
  pinMode(SDCARD_CS, OUTPUT);
  digitalWrite(SDCARD_CS, HIGH); //Deselect the SD card
  digitalWrite(W5200_CS, HIGH); //Deselect the W5200 card
  delay(10);
  int retryCount = 0;
  
  // see if the card is present and can be initialized:
  while (SD.begin(SDCARD_CS) != 1 && retryCount < 10) {
    Serial.println(F("Card failed, retrying")); //May not be present.
    // don't do anything more:
    retryCount++;
    delay(50);
  }
  if (retryCount >= 10) {
    Serial.println(F("CARD FAIL!"));
    //return;
  }
  
  Serial.println(F("Card Init."));

  retryCount = 0;
  Serial.println(F("Starting DHCP "));

  while (Ethernet.begin(_mac) != 1 && retryCount < 10) {
    retryCount++;
    Serial.print(F("DHCP RETRY "));
    Serial.println(retryCount);
    delay(50);
  }

  if (retryCount >= 10) {
    Serial.println(F("DHCP FAIL!"));
    return;
  }

  Serial.println(F("DHCP success!"));
  Serial.println(Ethernet.localIP()); // Display the Ethernet shield's local IP address
  delay(1000); //Lets make sure our connection is solid ;)

  _requestFile = initFile(FILE_REQUEST);
  _responseFile = initFile(FILE_RESPONSE);
  //InitFile(_tokenFile, FILE_TOKEN);

  Serial.println(F("Setup complete!"));
}

void loop()
{
  checkEthernet();

  authToken();

  sendSampleData();

  logoutToken();

  delay(10000); //Wait 10 seconds.
}

///Round trips the token request to the server, creats a token file on sd card
void authToken()
{
  Serial.println(F("Start token request"));
  _requestFile = initFile(FILE_REQUEST);
  _requestFile = openFile(FILE_REQUEST);

  _requestFile.print(F("POST "));
  _requestFile.print(F("/Trebuchet.WebApi/token?auth_mode=Internal"));
  _requestFile.println(F(" HTTP/1.1"));

  _requestFile.print(F("Host: "));
  _requestFile.println(_server);

  _requestFile.println(F("Connection: close"));
  _requestFile.println(F("Content-Type: application/x-www-form-urlencoded"));

  _requestFile.print(F("Content-Length: "));
  //Calculating the length from below...
  int contentLen = 30 + strlen(_clientKey) + 10 + strlen(_userName) + 10 + strlen(_password);
  _requestFile.print(contentLen);
  _requestFile.print("\r\n\r\n"); //This is really important.
  _requestFile.print(F("grant_type=password&client_id="));
  _requestFile.print(_clientKey);
  _requestFile.print(F("&username="));
  _requestFile.print(_userName);
  _requestFile.print(F("&password="));
  _requestFile.print(_password);

  closeAllFiles();

  _requestFile = printFile(FILE_REQUEST);
  Serial.println();

  sendRequest();
  if (_responseFile.size() == 0)
  {
    return; //Nothing to do, retry.
  }

  _responseFile = printFile(FILE_RESPONSE);
  Serial.println();

  closeAllFiles();

  int tokenStart = getTokenStart();

  storeToken(tokenStart);
  _tokenFile = printFile(FILE_TOKEN);
  closeAllFiles();
  Serial.println();

}

void sendSampleData()
{
   Serial.println(F("Start token request"));
  _requestFile = initFile(FILE_REQUEST);
  _requestFile = openFile(FILE_REQUEST);

  _requestFile.print(F("POST "));
  _requestFile.print(F("/Trebuchet.WebApi/api/V1/savebusinessobject"));
  _requestFile.println(F(" HTTP/1.1"));

  _requestFile.print(F("Host: "));
  _requestFile.println(_server);

  _requestFile.println(F("Connection: close"));
  _requestFile.println(F("Content-Type: application/json")); //!NOTE THE DIFFERENCE!

   _requestFile = injectBearerHeader();

  _requestFile.print(F("Content-Length: "));
  //Calculating the length from below...
  int contentLen = 343;
  _requestFile.print(contentLen);
  _requestFile.print("\r\n\r\n"); //This is really important.
  //Body of post.
  
  _requestFile.print(F("{\"busObId\": \"9420a6553508cd0b129eee445aa88d30955d5531b5\",\"fields\": [ "));
  _requestFile.print(F("{\"dirty\": true,\"fieldId\": \"9420a65784caeb8ae7c63c405e8df49161bd798401\",\"value\": \""));
  _requestFile.print(F("MyTestValue")); //Supplied Value.
  _requestFile.print(F("\"}, "));
  _requestFile.print(F("{\"dirty\": true,\"fieldId\": \"9420a65a60a534ccb26f5046c38ce7501e83e02212\",\"value\": \""));
  _requestFile.print(F("1")); //Supplied Value.
  _requestFile.print(F("\"}, "));
  _requestFile.print(F("{\"dirty\": true,\"fieldId\": \"9420a65adf3b243b3362974532a0bb7f105eccf12d\",\"value\": \""));
  _requestFile.print(F("2.02")); //Supplied Value.
  _requestFile.print(F("\"} "));
  
  _requestFile.println(F("]}"));



/*
New Record Template
{"busObId": "941ade2a80bfc64c272ecb4b6a9aeb61f5a756750f","fields": [
    {"dirty": true,
      "fieldId": "941ade2e4ca30d9295e430407a8d5faa1a752165c8",
      "value": "some value"
      },
      {"dirty": true,
      "fieldId": "941b128e184bcb3bdca7fd46b5a7b9dc3ef12f72f5",
      "value": "1"
      },
      {"dirty": true,
      "fieldId": "941b128e483370e92495214ca392fa3f9bb62bac64",
      "value": "1"
      },
  ]
}

*/


  closeAllFiles();

  _requestFile = printFile(FILE_REQUEST);
  Serial.println();

  sendRequest();
  if (_responseFile.size() == 0)
  {
    return; //Nothing to do, retry.
  }

  _responseFile = printFile(FILE_RESPONSE);
  Serial.println();

  closeAllFiles();
  Serial.println();
}

///Logs out the token and removes it from sd card
void logoutToken()
{

  Serial.println(F("Start logout request"));
  _requestFile = initFile(FILE_REQUEST);
  _requestFile = openFile(FILE_REQUEST);

  _requestFile.print(F("DELETE "));
  _requestFile.print(F("/Trebuchet.WebApi/api/V1/logout"));
  _requestFile.println(F(" HTTP/1.1"));
  
  _requestFile.print(F("Host: "));
  _requestFile.println(_server);
  
  _requestFile.println(F("Connection: close"));
  _requestFile.println(F("Content-Type: application/x-www-form-urlencoded"));
  
  _requestFile = injectBearerHeader();

  _requestFile.print(F("Content-Length: "));
  //Calculating the length from below...
  int contentLen = 0;
  _requestFile.print(contentLen);
  _requestFile.print("\r\n\r\n"); //This is really important.
  

  closeAllFiles();

  _requestFile = printFile(FILE_REQUEST);
  Serial.println();

  sendRequest();
  if (_responseFile.size() == 0)
  {
    return; //Nothing to do, retry.
  }

  _responseFile = printFile(FILE_RESPONSE);
  Serial.println();

  closeAllFiles();
  _tokenFile = initFile(FILE_TOKEN);
  closeAllFiles();
  Serial.println();
  
}

//Takes the current response file and injects the bearer token.
File injectBearerHeader()
{
  int requestBookmark = 0;
  int tokenBookmark = 0;
  byte readBuffer[60];
  int readLength;
  int bytesRead = 0;
  bool available = false;
  int totalBytesWritten = 0;

  _requestFile.print(F("Authorization: Bearer "));
  requestBookmark = _requestFile.position();
  closeAllFiles();

  _tokenFile = openFile(FILE_TOKEN);
  _tokenFile.seek(0);

  readLength = sizeof(readBuffer) / sizeof(byte);

  available = _tokenFile.available();
  while(available)
  {
    bytesRead = _tokenFile.readBytes(readBuffer, readLength);
    tokenBookmark = _tokenFile.position();
    closeAllFiles();

    _requestFile = openFile(FILE_REQUEST);
    _requestFile.seek(requestBookmark);
    _requestFile.write(readBuffer, bytesRead);
    requestBookmark = _requestFile.position();
    closeAllFiles();

    _tokenFile = openFile(FILE_TOKEN);
    _tokenFile.seek(tokenBookmark);
    
    totalBytesWritten+= bytesRead;

    available = _tokenFile.available();
  }
  if(totalBytesWritten == 0)
  {
    Serial.println(F("No Token Written"));
  }
  closeAllFiles();

  _requestFile = openFile(FILE_REQUEST);
  _requestFile.seek(requestBookmark); //Leave at the end of all of this.
  _requestFile.println();
}


///Takes the response from the server and finds the start position of the token
///Uses the sd card as a buffer as this is very large data.
int getTokenStart()
{
  //Sample output...
  //{
  // "access_token":"AT2su0yujwytIwLTaVxI6nvqVYLp_QaC7BKglVB6eJR93FX8ubV2v3pgvg_d0hGZY0vbsgsrzGKgJdjB0dsyy7AbjBBN4QsU-kHZmnPIyZue2SfdZm9nBzLOBWn4LLUl2tktFZgjx66veRoNNTQEkLwgdXpm90CTcpa--fom3V6TwApzRFa2qPOEB0ntzbiw6NHSxCARPwHE2IZnPMeoKtGDXyYCH_kirI3dAxSYTQKhN3lf_vKDwaLAPKvwMLzHaO9LumJKJZMV19QrxITBMxcBmLT7zcfIZxUmPd7nfCvrW2NtgOD89Cb8CtK_lnv9pxJvEK3pcaqVXBs5-V0ZjK_AJwlinc5LRy57dktfjYRP8ZwcE497yMApyGwbdjm-k7ZANLikd29trqIhaUwu8yLBPQnklRMgVy0aImSFcZ-ug9YcBEbK_czxBtLZCRwpyq-s5BQHtEAfNGN4EDmnaWcEKOrh8uA6yPvLdX9BmQfkDvkOMALJdPOHWwDeRflSrCyVAdy6c0JO_9LBuC44OEbq7Z-fnTg1jPc78VR6Mlk",
  // "token_type":"bearer",
  // "expires_in":14399,
  // "refresh_token":"69dff888cfd94f60882f83531d6387ee",
  // "as:client_id":"510eb9d2-be3e-40d5-9e45-ead16950c41b",
  // "username":"CSDAdmin",
  // ".issued":"Tue, 27 Sep 2016 17:30:18 GMT",
  // ".expires":"Tue, 27 Sep 2016 21:30:18 GMT"
  //}

  char startOfFile[17] = "\"access_token\":\""; //We'll be matching on this.
  char readBuffer[61]; //A buffer for the token we'll store, it must be at least 2x the startOfFile string.
  int pos = 0;
  int matchIndex = 0;
  int readLength = sizeof(readBuffer) / sizeof(char) - 1; //Saving room for a terminator

  //Read parse token.
  _tokenFile = initFile(FILE_TOKEN);
  
  _responseFile = openFile(FILE_RESPONSE);
  _responseFile.seek(0);

  if (_responseFile.size() < TOKENLEN) //If our response couldn't possibly contian the token then we bail
  {
    Serial.println(F("No token detected, file too small"));
    return -1;
  }
  readBuffer[0] = 0; //Set to 0 for empty token buffer.

  //First pass over file to find match index.
  while (_responseFile.available())
  {
    int bytesRead = _responseFile.readBytes(readBuffer, readLength);
    readBuffer[bytesRead] = 0;

    matchIndex = strContains(readBuffer, startOfFile);
    if (matchIndex >= 0) {
      //Match found, adjust based on real postion and return.
      matchIndex += pos;
      _responseFile.seek(matchIndex);
      return matchIndex;
    } else {
      //If we're not at the end, backup stream (buffer size / 2) so that we can continue search,
      //we want to avoid missing a match because the text of interest is near the end of the buffer.

      if (bytesRead == readLength)
      {
        _responseFile.seek(_responseFile.position() - readLength / 2);
      }
    }
    pos = _responseFile.position();
  }

  //If we didn't find the token then we bail
  Serial.println(F("No token found"));
  return -1;

}
/// Stores the token from start position to '"'
void storeToken(int startPos)
{
  if (startPos < 0)
  {
    return;
  }

  char readBuffer[60];
  int readLength = sizeof(readBuffer) / sizeof(char) - 1;
  char breakStr[4] = "\",\"";
  bool responseAvail = false;
  bool tokenComplete = false;

  int responseBookmark = 0;
  int tokenBookmark = 0;
  //Get files ready and walk to start of token in response.
  closeAllFiles();
  _tokenFile = initFile(FILE_TOKEN);
  closeAllFiles();
  _responseFile = openFile(FILE_RESPONSE);
  _responseFile.seek(startPos);

  responseAvail = _responseFile.available();

  while (responseAvail) {
    int bytesRead = _responseFile.readBytes(readBuffer, readLength);
    readBuffer[bytesRead] = 0; //Terminate the array to treat as string.

    //Terminate string if we have the break char in the value
    int breakCharPos = strContains(readBuffer, breakStr);
    if (breakCharPos >= 0) {
      bytesRead = breakCharPos - strlen(breakStr); //Adjust for file write later on.
      readBuffer[bytesRead] = 0; //Terminate the array to treat as string.

      tokenComplete = true;
    }

    //Messy bit to swap files, the token burns too much ram to allocate
    //Bookmark where we are in response and close file
    responseBookmark = _responseFile.position();
    closeFile(_responseFile);

    //Seek to last spot in token file and write results.
    //Save location and Close file
    _tokenFile = openFile(FILE_TOKEN);
    _tokenFile.seek(tokenBookmark);
    _tokenFile.write(readBuffer, bytesRead);
    tokenBookmark = _tokenFile.position();
    closeFile(_tokenFile);

    //Back to response file, go to last location and get ready to read
    _responseFile = openFile(FILE_RESPONSE);
    _responseFile.seek(responseBookmark);

    if (tokenComplete)
    {
      break;
    }
    responseAvail = _responseFile.available();

  }

  closeAllFiles();


}


/// Sends request and reads response from http server
/// This uses the sd card as a buffer for the data as it can theoretically get large.
byte sendRequest()
{
  byte clientBuffer[30];
  int readLength = sizeof(clientBuffer) / sizeof(byte);
  if (_client.connect(_server, _port) == 1)
  {
    closeAllFiles();
    _requestFile = openFile(FILE_REQUEST);
    _requestFile.seek(0);

    ////WRITE REQUEST TO SERVER
    while (_requestFile.available()) {
      int bytesRead = _requestFile.readBytes(clientBuffer, readLength);
      _client.write(clientBuffer, bytesRead);

    }
    delay(10);
    closeFile(_requestFile);
    _responseFile = initFile(FILE_RESPONSE);
    _responseFile = openFile(FILE_RESPONSE); //After closing request, lets open response.
    _responseFile.seek(0);
  }
  else
  {
    ///ERROR, BAIL
    Serial.println(F("Failed"));
    closeAllFiles();
    return 0;
  }
  delay(10);
  int connectLoop = 0;
  while (_client.connected())
  {

    ///READ RESPONSE FROM SERVER
    while (_client.available())
    {
      int bytesRead = _client.readBytes(clientBuffer, readLength);
      _responseFile.write(clientBuffer, bytesRead);

      connectLoop = 0;
    }

    closeFile(_responseFile);

    delay(1);
    connectLoop++;
    ///WAITING FOR CONNECTION FAILED
    if (connectLoop > 30000)
    {
      Serial.println();
      Serial.println(F("Timeout"));
      _client.stop();
      closeAllFiles();
      return 1; //Timeout
    }
  }

  Serial.println();
  Serial.println(F("Disconnecting."));
  _client.stop();
  closeAllFiles();
  return 1;
}


void checkEthernet() {
  switch (Ethernet.maintain())
  {
    case 1:
      //renewed fail
      Serial.println(F("Error: renewed fail"));
      break;

    case 2:
      //renewed success
      Serial.println(F("Renewed success"));
      //print your local IP address:
      Serial.println(Ethernet.localIP());
      break;

    case 3:
      //rebind fail
      Serial.println(F("Error: rebind fail"));
      break;

    case 4:
      //rebind success
      Serial.println(F("Rebind success"));

      //print your local IP address:
      Serial.println(Ethernet.localIP());
      break;

    default:
      //nothing happened, probably a 0, which means nothing to really do...
      break;

  }

}

///Initializes file on sd card by removing existing name
///and replacing with empty file.  Will close when complete
File initFile(char* fileName)
{
  if (SD.exists(fileName)) {
    SD.remove(fileName);
  }
  File file = SD.open(fileName, FILE_WRITE);

  file.close();

  return file;
}

///Closes file
void closeFile(File file)
{
  file.close();
}

///Closes all known files.
void closeAllFiles()
{
  closeFile(_requestFile);
  closeFile(_responseFile);
  closeFile(_tokenFile);
}

///Opens file by name and returns file object.
File openFile(char* fileName)
{
  closeAllFiles(); //Close any file before opening a new one.

  File file = SD.open(fileName, FILE_WRITE);

  return file;
}

///Prints file to serial and closes
File printFile(char* fileName)
{
  int maxLen = 2000; //Silly cap to keep from flooding the serial output

  File file = openFile(fileName);
  Serial.println(fileName);
  // read from the file until there's nothing else in it:
  file.seek(0);
  while (file.available() && maxLen > 0) {
    Serial.write(file.read());
    maxLen--;
  }
  closeFile(file);

  return file;
}

// Adapted from here http://forum.arduino.cc/index.php?topic=290459.0
// Searches for the string sfind in the string str
// returns startPos if string found
// returns -1 if string not found
int strContains(char* str, char* sfind)
{
  int foundPos = 0;
  int indexPos = 0;
  int len;
  int startPos = 0;

  len = strlen(str);

  if (strlen(sfind) > len) {
    return -1;
  }

  // find ade within zabcadef
  // on z, foundpos = 0
  // on a, foundpos = 1, startPos = 1
  // on b, foundpos = 0
  //...
  // on a, foundpos = 1, startPos = 4
  // on d, foundpos = 2
  // on e, foundpos = 3, returns 6

  while (indexPos < len) {
    if (str[indexPos] == sfind[foundPos]) {
      if (foundPos == 0)
      {
        startPos = indexPos;
      }
      foundPos++;
      if (strlen(sfind) == foundPos) {
        return (startPos + foundPos);
      }
    }
    else {
      foundPos = 0;
    }
    indexPos++;
  }

  return -1;
}




