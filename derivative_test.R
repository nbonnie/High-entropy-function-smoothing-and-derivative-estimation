library(dplyr)
library(tidyr)
library(ggplot2)
library(caTools)

bootstrap_smooth <- function(y,r,p,n) {
  # y - matrix of values to be bootstrapped
  # r - range of sampling
  # p - probability of point in range of being sampled
  # n - number of times to sample for a given point
  if (r%%2 == 0){
    r = r/2
  } else {
    r = floor(r/2)
  }
  adj_r <- 
    desti <- matrix(0,1,length(y))
  for (i in (1 + r):(length(desti)- r)) {
    sample_data <- y[(i-r):(i+r)]
    means <- matrix(0,1,length(n))
    for (j in 1:n) {
      split <- sample.split(sample_data, SplitRatio = p)
      train <- subset(sample_data, split == TRUE)
      #test <- subset(df, split == FALSE)
      means[j] <- mean(train, na.rm = T)
    }
    desti[i] <- mean(means)
  }
  # First tail
  # n <- floor(n/2)
  for (i in 1:r) {
    sample_data <- y[(1):(2*i-1)]
    means <- matrix(0,1,length(n))
    for (j in 1:n) {
      split <- sample.split(sample_data, SplitRatio = p)
      train <- subset(sample_data, split == TRUE)
      #test <- subset(df, split == FALSE)
      means[j] <- mean(train, na.rm = T)
    }
    desti[i] <- mean(means)
  }
  # Last tail
  for (i in (length(y)-r+1):length(y)) {
    #sample_data <- y[((2*i)-length(y)):(length(y))]
    sample_data <- y[(i-r):i]
    means <- matrix(0,1,length(n))
    for (j in 1:n) {
      split <- sample.split(sample_data, SplitRatio = p)
      train <- subset(sample_data, split == TRUE)
      #test <- subset(df, split == FALSE)
      means[j] <- mean(train, na.rm = T)
    }
    desti[i] <- mean(means)
  }
  return(t(desti))
}
slope <- function(x,y) {
  desti <- matrix(NA,1,length(x))
  for (i in 2:length(x)) {
    desti[i] <- (y[i] - y[(i-1)]) /  (x[i] - x[(i-1)])
  }
  return(t(desti))
}

aapl <- readRDS('~/R/NolansDTF.rds')
aapl <- aapl %>% filter(ticker == "AAPL") %>% select(close) # 241 observations

aapl$seq <- seq(1,nrow(aapl))

z <- ggplot(aapl, aes(x=seq, y=close)) + geom_point() + geom_smooth(method = "lm", formula = y~poly(x,5))
print(z)

aapl$b1 <- bootstrap_smooth(aapl$close,15,0.6,180)
aapl$b2 <- bootstrap_smooth(aapl$b1,15,0.6,75)
aapl$b3 <- bootstrap_smooth(aapl$b2,10,0.5,50)
aapl$b4 <- bootstrap_smooth(aapl$b3,15,0.6,25)

z = (ggplot(aapl, aes(x=seq, y=close)) + geom_point() 
     + geom_line(aes(y=b1), color = "red") 
     + geom_line(aes(y=b2), color = "orange") 
     + geom_line(aes(y=b3), color="green")
     + geom_line(aes(y=b4), color="purple"))
print(z)

print( ggplot(aapl, aes(x=seq, y=close)) + geom_point() + geom_point(aes(y=b4), color = "purple")  )



# Now that we have a smoothed representation, let's take the derivatives

aapl$aapl_dx <- slope(aapl$seq, aapl$b3)
aapl$aapl_dx_adj <- aapl$aapl_dx %>% bootstrap_smooth(20,0.6,50) %>%  bootstrap_smooth(15,0.6,50) 
aapl$aapl_ddx <- slope(aapl$seq,aapl$aapl_dx_adj)
aapl$aapl_ddx_adj <- aapl$aapl_ddx %>% bootstrap_smooth(20,0.6,50) %>%  bootstrap_smooth(15,0.6,50) %>%  bootstrap_smooth(10,0.6,50) 


z = {(ggplot(aapl, aes(x=seq)) 
      + geom_line(aes(y=aapl_dx), color = "red") 
      + geom_line(aes(y=aapl_dx_adj), color = "blue")
      + ggtitle("First derivative scaled values"))}
print(z)

z = {(ggplot(aapl, aes(x=seq)) 
      + geom_line(aes(y=aapl_ddx), color = "red") 
      + geom_line(aes(y=aapl_ddx_adj), color = "blue")
      + ggtitle("Second derivative scaled values"))}
print(z)
