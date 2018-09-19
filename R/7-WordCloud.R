source("inc-packages.R");
#Inspired from here:  http://onertipaday.blogspot.com/2011/07/word-cloud-in-r.html

storedData <- readRDS("RData/problemDemoSample.rds");
#lose everything but the description
abbrevDataFrame <- select(storedData, Description);

#rename columns for corpus as it wants a "text" column
colnames(abbrevDataFrame)[colnames(abbrevDataFrame)=="Description"] <- "text";
#Lets add a sequential doc_id for each row
abbrevDataFrame$doc_id <- 1:nrow(abbrevDataFrame);

#Load our text of interest into memory.
ap.corpus <- Corpus(DataframeSource(abbrevDataFrame));

#Lets remove extra white space and "\n"
ap.corpus <- tm_map(ap.corpus, content_transformer(stripWhitespace));

#Lets ditch punctuation so it won't pollute our word cloud.
ap.corpus <- tm_map(ap.corpus, removePunctuation);

#We only want to deal with lower case text
ap.corpus <- tm_map(ap.corpus, content_transformer(tolower));

#Remove common words such as a, the, it, and some we feel aren't valuable but used often.
stopwords <- append(stopwords("english"), 
                      c("cherwell", "please", "support", "will", "ticket", 
                        "supportcherwellcom", "incident", "intended", "can", 
                        "issue", "recipient", "information", "request", "steps", 
                        "2018", "regarding", "subject", "message","thank", "thanks", "may",
                        "regards"));

ap.corpus <- tm_map(ap.corpus, function(x) removeWords(x, stopwords));

#Stem words to get more meaningful meaning
#ap.corpus <- tm_map(ap.corpus, stemDocument);

#Lets re-assign so we aren't carrying around the original source.
ap.corpus <- Corpus(VectorSource(ap.corpus));
ap.tdm <- TermDocumentMatrix(ap.corpus);
ap.m <- as.matrix(ap.tdm);
ap.v <- sort(rowSums(ap.m),decreasing=TRUE);
ap.d <- data.frame(word = names(ap.v),freq=ap.v);

pal2 <- brewer.pal(8,"Dark2");
png("problemDemoSample.png", width=1280,height=800);

wordcloud(ap.d$word,ap.d$freq, scale=c(8,.2),min.freq=3,
          max.words=300, random.order=FALSE, rot.per=.15, colors=pal2);
dev.off(); #Release graphics context if writing to a file.

View(ap.d)
