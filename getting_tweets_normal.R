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
  access_secret = "X)

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
