#Simple demo to talk about nuances.
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

#Phrases to calc sentiment on
phrases <- c("Everything is awesome",  
             "Nothing is awesome", 
             "I am happy", 
             "I am not happy");

#Creating an empty vector
sentiment <- vector(mode="numeric", length=length(phrases)); 

#Not a best practice for using lists or dataframes in R, simply to illustrate the concept.
for(i in 1:length(phrases)){
  sentiment[i] <- sentiment_by(phrases[i])$ave_sentiment;

}

#Put it together for some charts!
mysentiment <- data.frame(phrases, sentiment);

colors <- c("dark red","blue");
pos <- mysentiment$sentiment >=0;

barplot(
  mysentiment$sentiment,
  names.arg=mysentiment$phrases,
  main ="Simple Sentiment", 
  xlab = "Phrase",
  col = colors[pos + 1],
  ylim=range(-1:1)
);


