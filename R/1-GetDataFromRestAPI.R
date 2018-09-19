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

source("inc-packages.R");

#This demonstrates a simple pull of data from restapi
webApiUrl = "http://localhost/Trebuchet.WebApi";
clientKey = "RESTAPIKEYFROMADMIN";
myUser <- "CHERWELLUSERNAMEHERE";
myPass <- "CHERWELLPASSWORDHERE";

tokenReqBody <- "grant_type=password&client_id=%CLIENTKEY%&username=%USER%&password=%PASS%&auth_mode=Internal";

#Replace %placeholders% with their real values.
tokenReqBody <- str_replace(tokenReqBody, "%CLIENTKEY%", clientKey);
tokenReqBody <- str_replace(tokenReqBody, "%USER%", myUser);
tokenReqBody <- str_replace(tokenReqBody, "%PASS%", myPass);

#Post to the rest api for an auth token
req <- httr::POST(paste(webApiUrl, "/token", sep=""),
                  httr::add_headers(
                    "Accept" = "application/json"
                  ),
                  body = tokenReqBody
);

#Extract the access token
token <- paste("Bearer", httr::content(req)$access_token)
finalData <- NA;
for(i in 1:1000)
{
  reqBody <- "{\"busObId\": \"9344be92d5b7b4c290437c4110bc5b7147c9e3e98a\",
  \"fields\": [ ], 
  \"filters\": [ ], 
  \"includeAllFields\": true, 
  \"includeSchema\": false,
  \"pageNumber\": %PAGE%, 
  \"pageSize\": 100, 
  \"sorting\": [ ], \"promptValues\": [ ] }";
  reqBody <-str_replace(reqBody, "%PAGE%", as.character(i-1));
  
  #Pass httr a "c(use_proxy("127.0.0.1", 8888))" parameter after the headers if fidder or other proxy is needed for debugging.
  
  # Now do some work
  req <- httr::POST(paste(webApiUrl, "/api/V1/getsearchresults", sep=""), 
                    httr::add_headers(
                      "Authorization" = token,
                      "Accept" = "application/json",
                      "Content-Type" = "application/json"
                    ),
                    body = reqBody
  )
  print(paste("processing page ", i));
  #Take the contents as text and convert to json so we get dataframes.
  convJson <- fromJSON(httr::content(req, "text"));
  
  #If our JSON has no data, abort.
  if(length(convJson[["businessObjects"]]) == 0)
  {
    break;
  }
  tallData <- reshape2::melt(convJson$businessObjects$fields, 
                id.vars=c("displayName", "fieldId", "html", "name", "value"))[, c("L1", "name", "value")];
  
  wideData <- dcast(tallData, L1 ~ name);
  if(i==1)
  {
    finalData <- wideData;
  }else
  {
    finalData <- rbind(finalData, wideData);
  }
}

#Logout to cleanup session
req <- httr::DELETE(paste(webApiUrl, "/api/V1/logout", sep=""), 
                    httr::add_headers(
                      "Authorization" = token
                    ),
                    body=""
);


#Store for later.
saveRDS(finalData, file="RData/problemDemoSample.rds");



