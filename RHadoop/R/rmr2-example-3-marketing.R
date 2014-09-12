#!/usr/bin/env Rscript

#
# Example 3: marketing
#
# Implement a simple user-based collaborative filtering algorithm to group users
# by various attributes or activities ('items')
# 
# by Jeffrey Breen <jeffrey@jeffreybreen.com>
#

library(rmr2)
library(plyr)

# Set "LOCAL" variable to T to execute using rmr2's local backend.
# Otherwise, use Hadoop (which needs to be running, correctly configured, etc.)
LOCAL = T

DEBUG = T
source('R/functions-debug.R')

if (LOCAL)
{
	rmr.options(backend = 'local')
	
	# we have smaller extracts of the data in this project's 'local' directory
	hdfs.data.root = 'local/marketing'
	hdfs.data = file.path(hdfs.data.root, 'data', 'marketing-10.csv')

	hdfs.out.root = hdfs.data.root
	
} else {
	rmr.options(backend = 'hadoop')
	
	# assumes 'marketing/data' input path exists on HDFS under /rhadoop-training
	
	hdfs.data.root = '/rhadoop-training/marketing'
	hdfs.data = file.path(hdfs.data.root, 'data')
	
	# writes output to 'marketing' directory in user's HDFS home (e.g., /user/cloudera/marketing/)
	hdfs.out.root = 'marketing'
	}

hdfs.out = file.path(hdfs.out.root, 'out')
hdfs.step1 = file.path(hdfs.out, 'step1')
hdfs.step2 = file.path(hdfs.out, 'step2')

####
#
# STEP 1 -- indexing
#
####


#
# input.format.marketing.csv -- parse input files. Called by map.step1()
#
input.format.marketing.csv = make.input.format(format='csv', mode='text', 
											   streaming.format=NULL,
											   sep=',', stringsAsFactors=F)


#
# map.step1 -- our first mapper receives the data from the input CSV file
#   (via the input.format.marketing.csv input formatter) and picks out what
#   we're interested in.
#
#   Note: We assume we can ignore zero-valued scores (which may not be the case
#         if you intend to use formal correlation metrics like Pearson)
#
# input: ( NULL, [user.id, scores] )
# output: ( item.id, (user.id, score) )
#
map.step1 = function(key, val.df)
{
	if (DEBUG)
		debug.log('map-input', key, val.df, '/tmp/rhadoop/marketing/step1')
	
	# data comes in batches from read.table() via the input formatter:
	# key = NULL, val.df = file contents as a data.frame

	# label the data.frame columns
	colnames(val.df) = c('user.id', paste('item.', 1:(ncol(val.df)-1), sep='' ))

	# First, let's omit the header lines -- we can tell these lines because 
	# they have field names (like 'user.id') in place of actual values
	val.df = subset(val.df, user.id != 'user.id')
	
	# For each row of the input data.frame, we want to emit a keyval pair which 
	# looks like ( item.id, (user.id, score) ), so let's make a data.frame with
	# these columns
	output.val = ddply(val.df, 1, function(x) {

		# pull user.id out of the data
		user.id = x$user.id
		x = x[,-1]
		
		tmp.df = data.frame()
		
		# iterate through each data column
		for (col in colnames(x))
		{
			tmp = as.numeric(x[,col])
			if (tmp != 0)
				tmp.df = rbind(tmp.df, data.frame(item.id=col, user.id=user.id, score=tmp, stringsAsFactors=F) )
		}

		if (nrow(tmp.df) == 0) {
			return(NULL)
		} else {
			return(tmp.df)
		}
	} )

	# let's pull the item.id out of the output.val to be the key
	output.key = output.val[,1]
	output.val = output.val[,-1]
	
	if (DEBUG)
		debug.log('map-output', output.key, output.val, '/tmp/rhadoop/marketing/step1')
	
	return( keyval(output.key, output.val) )
}		


#
# reduce.step1 -- receives all the (user.id, score) pairs for a given item.id and
#   generates all the valid user.id, score combinations for matching items
#
# input: ( item.id, [ (user.id, score) ] ) 
# output: ( (user.id.1, user.id.2), (score.1, score.2) ) 
#         combinations for that item.id
#
# Optimization note: the mapper has already eliminated all zero-value scores
# This reducer eliminates the pairs required to compute the diagonal elements
# (user.id.1 = user.id.2) and the complementary pairs in the similarity matrix
# and the mirror elements (user.id.2, user.id.1). The diagonal elements are
# never interesting and the complements are easily generated later.
# No doubt, other optimizations are possible.
#
reduce.step1 = function(key, val.df)
{
	if (DEBUG)
		debug.log('reduce-input', key, val.df, '/tmp/rhadoop/marketing/step1')
		
	# A cartesian join will yield all permutations of users 
	# who have scores for this key (item.id)...
	val.df = merge(val.df, val.df, by=NULL, all=T, suffixes=c('.1', '.2'))
	
	# ...but this is symmetric so only keep rows where user.id.1 < user.id.2
	# This will save 50% of the calculations in step 2
	# We just need to remember to generate output for (user.id.1, user.id.2) 
	# and (user.id.2, user.id.1) when we calculate the similarity scores
	
	val.df = subset(val.df, user.id.1 < user.id.2 )
	
	# We want to emit keyvals like ( (user.id.1, userid.id.2), (score.1, score.2) )

	output.key = val.df[,c(1,3)]
	output.val = val.df[,c(2,4)]
	
	if (DEBUG)
		debug.log('reduce-output', output.key, output.val, '/tmp/rhadoop/marketing/step1')

	return( keyval(output.key, output.val) )
}


#
# mr.step1 - defines the MapReduce job for step1
#
# input: input, output HDFS paths for data & results
#
# if successful, returns the output HDFS path input so function calls can be
# nested to daisy-chain MapReduce jobs
#
mr.step1 = function (input, output, backend.parameters=list()) {
	mapreduce(input=input,
			  output=output,
			  map=map.step1,
			  reduce=reduce.step1,
			  input.format=input.format.marketing.csv,
			  backend.parameters=backend.parameters,
			  verbose=T)
}


####
#
# STEP 2 -- Calculate user similarity
#
####
#
# Coming out of step 1, we have indexed all the meaningful score pairs by 
# the (user.id.1, user.id.2) key. Hadoop automatically collects the results
# across all the nodes, groups them by the key, and distributes the workload
# intelligently across the available nodes.
#
# In this step, we only specify a reducer, so it will receive all the value pairs
# for a given (user.id.1, user.id.2) key.
#
####


#
# reduce.step2 - calculates a simple similarity metric for a given 
#    (user.id.1, user.id.2) key by adding up how many items they have purchased 
#    in common
#
# input: ( (user.id.1, user.id.2), [ (score.1, score.2) ] )
# output: ( (user.id.1, user.id.2), similarity )
#
reduce.step2 = function(key, val.df)
{
	if (DEBUG)
		debug.log('reduce-input', key, val.df,  '/tmp/rhadoop/marketing/step2')
	
	# we can't compute a correlation without data
	
	if (nrow(key) == 0)
		return(NULL)
	
	if (nrow(val.df) > 0)
	{
		x = as.numeric(val.df$score.1)
		y = as.numeric(val.df$score.2)
		
		similarity = sim.simple( x, y )
	} else {
		similarity = 0
	}
		
	# output key is the same as the input key: (user.id.1, user.id.2)
	
	output.key = key
	output.val = similarity
	
	if (DEBUG)
		debug.log('reduce-output', output.key, output.val,  '/tmp/rhadoop/marketing/step2')

	return( keyval(output.key, output.val) )
}


#
# mr.step2 - defines the MapReduce job for step2
#
# input: input, output HDFS paths for data & results
#
# if successful, returns the output HDFS path input so function calls can be
# nested to daisy-chain MapReduce jobs
#
mr.step2 = function (input, output, backend.parameters=list()) {
	mapreduce(input=input,
			  output=output,
			  reduce=reduce.step2,
			  backend.parameters=backend.parameters,
			  verbose=T)
}


# given two vectors (corresponding to scores for matching items) for two users,
# compute a simple similarity score based on shared item scores
# NB: This is by no means a real "correlation", just a tally of matching items
#
sim.simple = function(x,y) {
	return( sqrt( sum( (x * y)^2 ) ) )
}


# # the jobs can be run step-by-step:
# 
# step1.out = mr.step1(hdfs.data, hdfs.step1)
# step2.out = mr.step2(step1.out, hdfs.step2)
# results = from.dfs(step2.out)

# or we can take advantage of the fact that mapreduce() returns the path to its
# results to feed into a nested call:

out = mr.step2( input=mr.step1(input=hdfs.data, output=hdfs.step1), 
				output=hdfs.step2)

results = from.dfs( out )
results.df = as.data.frame( results )
colnames(results.df) = c('user.id.1', 'user.id.2', 'similarity')
results.df$similarity = as.numeric(results.df$similarity)

# don't forget, we're still missing the complementary score pairs (user.id.2, user.id.1)
# see exercise for third MR job to insert them and to find nearest neighbors.

# but for small data/result sets, and for a sanity check, we can sort by similarity
# and take a look now:

results.df = results.df[with(results.df, order(user.id.1, -similarity) ), ]
rownames(results.df) = NULL

print(head(results.df))
