install.packages("tidyverse",dependencies = TRUE)
install.packages("stringr",dependencies = TRUE)
library(tidyverse)
library(stringr)
library(rtweet)

# read in the tweet files
tweets_normal <- read_csv("tweets_normal.csv")
tweets_normal1 <- read_csv("tweets_normal1.csv")
tweets_normal2 <- read_csv("tweets_normal2.csv") 
tweets_normal3 <- read_csv("tweets_normal3.csv")
tweets_normal4 <- read_csv("tweets_normal4.csv")
tweets_normal5 <- read_csv("tweets_normal5.csv")
tweets_normal6 <- read_csv("tweets_normal6.csv")
tweets_normal7 <- read_csv("tweets_normal7.csv")
tweets_famous <- read_csv("tweets_famous.csv")
# tweets <- read_csv("cleaned_up_tweets.csv")

# combine all tweet files into 1 dataframe
tweets <- do.call("rbind", list(tweets_famous,tweets_normal,tweets_normal1,
                                tweets_normal2,tweets_normal3,tweets_normal4,
                                tweets_normal5,tweets_normal6,tweets_normal7))

length(unique(tweets$text)) # check for number of unique tweets (data might have duplicated tweets)

tweets <- tweets[!duplicated(tweets$text),] # remove the duplicate row from dataframe

tweets <- tweets[tweets$is_retweet == FALSE,] # Only take tweets that are original tweets (not retweets)
nrow(tweets[tweets$retweet_count == 0,]) # find the number of tweets that have 0 retweets
nrow(tweets[tweets$retweet_count != 0,]) # find the number of tweets that have at least 1 retweet
tweets <- tweets[-sample(which(tweets$retweet_count == 0),294353),] # randomly remove tweets that have 0 
                                                                  # retweets so that we have 50/50 retweeted
                                                                  # and non-retweeted tweets
# nrow(tweets[tweets$hashtags == "NA",]) # number of tweets that have hashtags
tweets <- tweets[,c("followers_count","friends_count","statuses_count","favourites_count",
                    "text","hashtags","listed_count","symbols","urls_expanded_url","media_expanded_url",
                    "verified","media_type","mentions_user_id","status_url",
                    "retweet_count")] # only take these features

# save_as_csv(tweets,"cleaned_tweets.csv")

# mutate columns where number of tweets < 1 is unpopular
tweets <- mutate(tweets,popularity = ifelse(retweet_count>0,1,0))
tweets <- mutate(tweets,verified = ifelse(TRUE,1,0))

# replace the content of hashtags, symbols, urls, media column by the number of corresponding variables
tweets <- mutate(tweets,hashtags=str_count(tweets$hashtags,'\\w+'))
tweets <- mutate(tweets,symbols=str_count(tweets$symbols,'\\w+'))
tweets <- mutate(tweets,urls_expanded_url=str_count(tweets$urls_expanded_url, "http"))
tweets <- mutate(tweets,media_expanded_url=str_count(tweets$media_expanded_url,"http"))
tweets <- mutate(tweets,mentions_user_id=str_count(tweets$mentions_user_id,'\\w+'))
tweets[is.na(tweets)] <- 0 # replace all NA values with 0's
tweets$media_type <- sapply(tweets$media_type, function(x) paste(unique(unlist(str_split(x," "))),
                                                                 collapse = " ")) # remove duplicate words
tweets$media_type <- sapply(tweets$media_type, as.factor)
tweets$popularity <- sapply(tweets$popularity, as.factor)

# sentiment analysis
# pos.words <- read.csv("positive-words.csv",header=FALSE)
# neg.words <- read.csv("negative-words.csv",header=FALSE)
pos.words <- scan("positive-words.csv",what = 'character')
neg.words <- scan("negative-words.csv",what = 'character')

# function to score sentiment analysis of tweets
score.sentiment = function(sentences, pos.words, neg.words, .progress='none')
{
  require(plyr)
  require(stringr)
  
  # we got a vector of sentences. plyr will handle a list
  # or a vector as an "l" for us
  # we want a simple array ("a") of scores back, so we use 
  # "l" + "a" + "ply" = "laply":
  
  scores = laply(sentences, function(sentence, pos.words, neg.words) {
    
    # clean up sentences with R's regex-driven global substitute, gsub():
    sentence = gsub('[[:punct:]]', '', sentence)
    sentence = gsub('[[:cntrl:]]', '', sentence)
    sentence = gsub('\\d+', '', sentence)
    # and convert to lower case:
    sentence = tolower(sentence)
    
    # split into words. str_split is in the stringr package
    word.list = str_split(sentence, '\\s+')
    # sometimes a list() is one level of hierarchy too much
    words = unlist(word.list)
    
    # compare our words to the dictionaries of positive & negative terms
    pos.matches = match(words, pos.words)
    neg.matches = match(words, neg.words)
    
    # match() returns the position of the matched term or NA
    # we just want a TRUE/FALSE:
    pos.matches = !is.na(pos.matches)
    neg.matches = !is.na(neg.matches)
    
    # and conveniently enough, TRUE/FALSE will be treated as 1/0 by sum():
    score = sum(pos.matches)-sum(neg.matches)
    
    return(score)
  }, pos.words, neg.words, .progress=.progress )
  
  scores.df = data.frame(score=scores, text=sentences)
  return(scores.df)
}

# run sentiment analysis scores of all the tweets and save 'result' dataframe
result <- score.sentiment(tweets$text,pos.words,neg.words) # 
summary(result$score)
hist(result$score,col ="yellow", main ="Score of tweets",
     xlab="score",ylab = "Count of tweets")

# merge 'score' column into tweets dataframe
tweets <- cbind(tweets,score=result[,1])

# decision tree with 'caret'
install.packages("caret",dependencies = TRUE)
library(caret)
library(rpart.plot)

# split data into training and testing set with ratio 80/20
set.seed(123)
tree_split <- createDataPartition(tweets$popularity, p = .80, list = FALSE)
tree_training <- tweets[tree_split,]
tree_testing  <- tweets[-tree_split,]

tc <-  trainControl(method="repeatedcv",number=10,repeats=3)
#rpart.grid <- expand.grid(.cp=0.2) # paramter tuning
train.rpart <- train(popularity ~., data=tree_training[,-c(5,11,14,15)],
                     method="rpart",
                     trControl=tc,
                     #preProcess=c("center"),
                     tuneLength=20)
rpart.plot(train.rpart$finalModel) # plot the finalized tree with the best parameters
plot(train.rpart) # plot the accuracy vs the tuning parameters
plot(varImp(train.rpart)) # important attributes in the classification process used in the tree

# prediction on training set
rpartTrainPred <- predict(train.rpart, newdata=tree_training)
# confusionMatrix(rpartPred, tweets$popularity)
confusion.matrix <- table(predicted=rpartTrainPred,actual=tree_training$popularity) # confusion matrix only good for
print(confusion.matrix)                                                   # classification problems
accuracy.train <- 100*(sum(diag(confusion.matrix))/sum(confusion.matrix))
print(paste("accuracy:",accuracy.train,"%"))

# prediction on testing set
rpartTestPred <- predict(train.rpart,newdata=tree_testing)
confusion.matrix <- table(predicted=rpartTestPred,actual=tree_testing$popularity)
print(confusion.matrix)
accuracy.test <- 100*(sum(diag(confusion.matrix))/sum(confusion.matrix))
print(paste("accuracy:",accuracy.test,"%"))

# use linear regression to predict number of retweets the popular tweets have
retweeted <- tree_training[which(rpartTrainPred==1),] # number of tweets that was predicted to be retweeted by decision tree
non_retweeted <- tree_training[which(rpartTrainPred==0),] # number of tweets that was predicted to not be retweeted by decision tree

# split training and testing data by 80/20 for the linear regression problem
lr_split <- createDataPartition(retweeted$retweet_count, p=.80, list = FALSE)
lr_training <- retweeted[lr_split,]
lr_testing  <- retweeted[-lr_split,]

lr <- train(retweet_count ~ ., data=lr_training[,-c(5,11,14,16)], method='glmnet', # linear regression
               tuneGrid=expand.grid(alpha=0,lambda=seq(0.01,10,length=100)),
               trControl=tc)
plot(varImp(lr))
plot(lr)

# fit model to training and testing set
lr_training$lr.retweet_count <- predict(lr,newdata=lr_training)
lr_training.corr <- cor(lr_training$retweet_count,lr_training$lr.retweet_count)
lr_training.rmse <- (sqrt(mean((lr_training$lr.retweet_count-lr_training$retweet_count)^2))) # Train RMSE
c((lr_training.corr^2),lr_training.rmse) # accuracy in terms of coefficient correlation square
                                         # and RMSE

lr_testing$lr.retweet_count <- predict(lr,newdata=lr_testing)
lr_testing.corr <- cor(lr_testing$retweet_count,lr_testing$lr.retweet_count)
lr_testing.rmse <- (sqrt(mean((lr_testing$lr.retweet_count-lr_testing$retweet_count)^2))) # Test RMSE
c((lr_testing.corr^2),lr_testing.rmse) # test accuracy & RMSE

