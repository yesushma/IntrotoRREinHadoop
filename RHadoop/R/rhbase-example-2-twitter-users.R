#!/usr/bin/env Rscript

#
# rhbase Example 2: twitter-users
#
# Start with table of tweets from Example 1, then retrieve information about
# authors and store in new 'users' table
#
# by Jeffrey Breen <jeffrey@jeffreybreen.com>
#

library(rhbase)
library(twitteR)


hb.init(serialize='raw')

users.table = 'users'

if ( !( users.table %in% names(hb.list.tables()) ) )
	hb.new.table(users.table,
				 "id", "screenName", "name", "description",
				 "url", "location", "account", "count", 
				 opts=list(maxversions=5,
				 		  description=list(maxversions=1L,compression='GZ',inmemory=FALSE)
				 		  )
				 )

# load the screenNames from all the tweets we have in our table
rs = hb.get.data.frame('tweets', start=1, end=NULL, columns=c('screenName') )
df = rs()

# de-dupe
users = sort(unique(df$screenName))

# query Twitter for information about each user and insert into HBase

for (user in users)
{
	u = getUser(user)
	
	u.df = as.data.frame(u)
	
	# first change the column names of the '*Count' columns to put into the 'count:' family
	colnames(u.df) = gsub('(.*)Count', 'count:\\1', colnames(u.df))
	# then rename the three 'account:' columns
	colnames(u.df) = gsub('(created|protected|verified)', 'account:\\1', colnames(u.df))

	# use Twitter screen name as row id
	rownames(u.df) = u.df$screenName
	hb.insert.data.frame(users.table, u.df)
}

