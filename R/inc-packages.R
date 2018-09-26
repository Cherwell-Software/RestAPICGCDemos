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

if (!require(tools)) install.packages('tools');
library(tools);

if (!require(devtools)) install.packages('devtools');
library(devtools);

if (!require(RSQLS)) install_github("martinkabe/RSQLS");
library(RSQLS);

if (!require(xml2)) install.packages('xml2');
library(xml2);

if (!require(plyr)) install.packages('plyr');
library(plyr);

if (!require(reshape2)) install.packages('reshape2');
library(reshape2);

if (!require(jsonlite)) install.packages('jsonlite');
library(jsonlite);

if (!require(httr)) install.packages('httr');
library(httr);

if (!require(tidyverse)) install.packages('tidyverse');
library(tidyverse);

if (!require(xlsx)) install.packages('xlsx');
library(xlsx);

if (!require(stringr)) install.packages('stringr');
library(stringr);

if (!require(sentimentr)) install.packages('sentimentr');
library(sentimentr);

if (!require(syuzhet)) install.packages('syuzhet');
library(syuzhet);

if (!require(tm)) install.packages('tm');
library("tm");

if (!require(SnowballC)) install.packages('SnowballC');
library("SnowballC");

if (!require(wordcloud)) install.packages('wordcloud');
library("wordcloud");

if (!require(RColorBrewer)) install.packages('RColorBrewer');
library("RColorBrewer");

if(!require(digest)) install.packages("digest");
library("digest");

if(!require(class)) install.packages("class");
library("class");

#javar package fix.
#Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jre-10.0.1')