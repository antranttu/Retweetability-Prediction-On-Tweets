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

## search for 100,000 tweets sent from the US
rt <- search_tweets("lang:en", geocode = lookup_coords("usa"), n = 100000,
                    retryonratelimit = TRUE)

## create lat/lng variables using all available tweet and profile geo-location data
rt <- lat_lng(rt)

## plot state boundaries
par(mar = c(0, 0, 0, 0))
maps::map("state", lwd = .25)

## plot lat and lng points onto state map
with(rt, points(lng, lat, pch = 20, cex = .75, col = rgb(0, .3, .7, .75)))

# save the collected tweets as ".csv" file
save_as_csv(rt, "tweets_normal7.csv")
