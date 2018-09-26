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

#This script demonstrates taking email data and parsing it, performing sentiment analysis
#and storing the result for later.

storedData <- readRDS("RData/emailSample.rds");

#Create some columns to extract embedded information.
storedData$from <- "";
storedData$to <- "";
storedData$cmi <- "";
storedData$avgSentiment <- as.numeric(0);
storedData$sdSentiment <- as.numeric(0);
storedData$wordcount <- as.numeric(0);


print("Getting To from emails");
#Do it again for 'To:'
storedData$to <- str_extract(storedData$Details, "(To:.+[A-Z_a-z0-9-]+(\\.[A-Z_a-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,10})\\s)");
#Clean up those character(0) entries w/ something more appropriate
storedData$to[lengths(storedData$to) == 0] <- NA_character_

#Now lets ditch the 'To:'
storedData$to <- str_replace(storedData$to, "To: ", "");

print("Getting CMI from emails");
#Lets also pluck out the CMI Ids from the messages so that we can identify which messages are correlated for trending.
#i.e. {CMI: WXYZ010448}
storedData$cmi <- str_extract(storedData$Details, "\\{CMI:\\s+(\\w+)\\}");
#Clean up those character(0) entries w/ something more appropriate
storedData$cmi[lengths(storedData$cmi) == 0] <- NA_character_
#Now lets ditch the '{CMI: '
storedData$cmi <- str_replace(storedData$cmi, "\\{CMI:\\s+", "");
storedData$cmi <- str_replace(storedData$cmi, "\\}", "");

print("Getting sentiment from emails");
#Now we can do the core analysis
rawSentiment <- lapply(storedData$Details, function(x) sentiment_by(x, lexicon::hash_sentiment_jockers_rinker));

storedData$wordcount <- lapply(rawSentiment, function(x) x$word_count);
storedData$avgSentiment <- lapply(rawSentiment, function(x) x$ave_sentiment);
storedData$sdSentiment <- lapply(rawSentiment, function(x) x$sd);

print("Saving results");
saveRDS(storedData, "RData/processedSampleEmailAbbrev.rds");
