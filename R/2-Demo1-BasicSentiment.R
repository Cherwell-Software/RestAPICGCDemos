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

#Other options exist for method, choices can be syuzhet, bing, afinn, nrc, stanford
sentiment <- get_sentiment(words, method="syuzhet"); 

#We'll perform a discrete cosine transformation with reverse transform.
#This is a really fancy way of saying we're going to do a fourier transform against our data
#You do this every time you make a jpeg :)
dct_values <- get_dct_transform(
  sentiment, 
  low_pass_size = 5, 
  x_reverse_len = 100,
  scale_vals = F,
  scale_range = T
);


plot(
  dct_values, 
  type ="l", 
  main ="Simple Sentiment Over Time", 
  xlab = "Narrative Time", 
  ylab = "Emotional Valence", 
  col = "red"
);

#Lets morph the raw into a moving avg
pwdw <- round(length(sentiment)*.1)
poa_rolled <- zoo::rollmean(sentiment, k=pwdw)
plot(poa_rolled, 
     type="l", 
     col="blue", 
     xlab="Narrative Time", 
     ylab="Emotional Valence",
     main = "Simple Sentiment Moving Avg"
);

plot(
  sentiment, 
  type ="l", 
  main ="Simple Sentiment", 
  xlab = "Narrative Time", 
  ylab = "Emotional Valence", 
  col = "red"
);
