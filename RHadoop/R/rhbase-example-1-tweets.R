#!/usr/bin/env Rscript

#
# rhbase Example 1: tweets
#
# Create and populate HBase table with tweets
#
# by Jeffrey Breen <jeffrey@jeffreybreen.com>
#

library(rhbase)
library(twitteR)


# 'raw' serialization = plain text (using base::charToRaw and base::rawToChar)
hb.init(serialize='raw')

tweets.table = 'tweets'

# create our table if it doesn't already exist
if ( !( tweets.table %in% names(hb.list.tables()) ) )
	hb.new.table(tweets.table,
				 "id", "screenName", "text","favorited",
				 "replyToSN","created","truncated","replyToSID",
				 "replyToUID","statusSource",
				 opts=list(maxversions=5L,
				 		  text=list(maxversions=1L,compression='GZ',
				 		  		  inmemory=FALSE)
				 		  )
				 )

# fetch the 25 most recent tweets using the '#rstats' hashtag
tweets = searchTwitter('#rstats', n=25)

# convert the list of Twitter status objects to a data.frame
tweets.df = twListToDF(tweets)

# use tweet ID as the row key
rownames(tweets.df) = tweets.df$id

hb.insert.data.frame(tweets.table, tweets.df)
