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

#This script demonstrates taking email data and performing sentiment over time.

storedData <- readRDS("RData/processedSampleEmailAbbrev.rds");

#If we wanted to use a specific cmi i.e. WXYZ010575
#sentiment <- subset(storedData, cmi == "WXYZ010575");

#For this demo we'll use all email data
sentiment <- storedData;

sentimentValues <- as.numeric(sentiment[order(sentiment$CreatedDateTime),]$avgSentiment);
sentimentTimes <- sentiment[order(sentiment$CreatedDateTime),]$CreatedDateTime;

#We'll perform a discrete cosine transformation with reverse transform.
#This is a really fancy way of saying we're going to do a fourier transform against our data
#You do this every time you make a jpeg :)
dct_values <- get_dct_transform(
  sentimentValues,
  low_pass_size = 8, 
  x_reverse_len = 100,
  scale_vals = F,
  scale_range = T
);


plot(
  dct_values, 
  type ="l", 
  main ="Email Discussion Sentiment Over Time", 
  xlab = "Narrative Time", 
  ylab = "Emotional Valence", 
  col = "red"
);

#Lets morph the raw into a moving avg
pwdw <- round(length(sentimentValues)*.1)
poa_rolled <- zoo::rollmean(sentimentValues, k=pwdw)
plot(poa_rolled, 
     type="l", 
     col="blue", 
     xlab="Narrative Time", 
     ylab="Emotional Valence",
     main = "Email Discussion Sentiment Moving Avg"
);

plot(
  sentimentValues, 
  type ="l", 
  main ="Email Sentiment", 
  xlab = "Narrative Time", 
  ylab = "Emotional Valence", 
  col = "red"
);
