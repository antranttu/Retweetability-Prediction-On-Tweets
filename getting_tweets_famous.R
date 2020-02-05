## install rtweet from CRAN
install.packages("rtweet")

## load rtweet package
library(rtweet)

## install devtools package if it's not already
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

## install dev version of rtweet from github
devtools::install_github("mkearney/rtweet")

## load rtweet package
library(rtweet)

## access token method: create token and save it as an environment variable
create_token(
  app = "my_twitter_research_app",
  consumer_key = "X", # For security purposes, i'm not showing my keys here. Just replace the X's with your own keys
  consumer_secret = "X",
  access_token = "X",
  access_secret = "X")

## lookup users by screen_name or user_id
users <- c("KimKardashian", "justinbieber", "taylorswift13",
           "espn", "JoelEmbiid", "cstonehoops", "KUHoops",
           "upshotnyt", "fivethirtyeight", "hadleywickham",
           "cnn", "foxnews", "msnbc", "maddow", "seanhannity",
           "potus", "epa", "hillaryclinton", "realdonaldtrump",
           "natesilver538", "ezraklein", "annecoulter", "TheEllenShow",
           "selenagomez","Oprah","Cristiano","jimmyfallon")

## get user IDs of accounts followed by CNN
tweets_famous <- get_timelines(users, n = 2000,retryonratelimit=TRUE)

# save the collected tweets as ".csv" file
save_as_csv(tweets_famous, "tweets_famous.csv")
