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

#Very simple linear regression demo

distanceTravelled <- function(t)
{
  #Apply some fake randomness to the speed calc.
  delta <- as.numeric(runif(1, -8, 8));
  y <- 65*(t) + 100 + delta; #Driving for 65mph starting at a distance of 100
  return(y);
}

#Generate times in 10th hr increments for 10 hrs.
times <- as.list(as.numeric(1:100 * 0.1));
#Apply our function for each time slot
distance <- lapply(times, function(x) distanceTravelled(x));

#Create an object to hold our data
speedData <- list();
speedData$x <- times;
speedData$y <- distance;

#Plot out the data.
par(mai=c(1,2,1,1)); #Fix our margins so we can see our labels
plot(
  speedData,
  ylab="Distance in miles",
  xlab="Time in hours",
  main ="Regression Demo",
  cex.axis=2,
  cex.lab = 2,
  cex.main = 2
);

#Convert our data to an array so we can regress it.
times <- as.numeric(times);
distance <- as.numeric(distance);

#Do the regression!  If this works we now arrive at the 
#values used to generate our sample data.
fit<- lm(formula = distance ~ times);

#Show the data
show(summary(fit));
