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
  consumer_key = "MO6yQEsEys0SJCb9pcQl5Bs8Z",
  consumer_secret = "swyUqTpbjMX4dkJ1WCGVRuqqmCjewGjTpwEXHByy5SpNrsuir7",
  access_token = "757085451555483648-OIc9CErvPN8yrrxRFffir4V7TFS5lt1",
  access_secret = "G6JI4BYfgDVqT8U4WW8yKWq3JV8Fi0RbLwmafwN5u9ve3")

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
