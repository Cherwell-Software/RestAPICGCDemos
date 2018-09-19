#Simple demo, much of this can be found here and is the origninal author of this sample:  
#https://cran.r-project.org/web/packages/syuzhet/vignettes/syuzhet-vignette.html

source("inc-packages.R");

print("Running Basic Sentiment Demo-1");

my_example_text <- "I begin this story with a neutral statement.  
  Basically this is a very silly test.  
You are testing the Syuzhet package using short, inane sentences.  
I am actually very happy today. 
I have finally finished writing this package.  
Tomorrow I will be very sad. 
I won't have anything left to do. 
I might get angry and decide to do something horrible.  
I might destroy the entire package and start from scratch.  
Then again, I might find it satisfying to have completed my first R package. 
Honestly this use of the Fourier transformation is really quite elegant.  
You might even say it's beautiful!"

sentences <- get_sentences(my_example_text);
words <- get_tokens(sentences, pattern = "\\W");


nrcsentiment <- get_nrc_sentiment(sentences);

par(mai=c(1,2,1,1)); #Fix our margins so we can see our labels
barplot(
  sort(colSums(prop.table(nrcsentiment[, 1:8]))), 
  horiz = TRUE,
  cex.names = 2,
  cex.axis=2,
  cex.lab = 2,
  cex.main = 2,
  las=1,
  main = "Emotional Lexicon Demo", xlab="Value"
);


