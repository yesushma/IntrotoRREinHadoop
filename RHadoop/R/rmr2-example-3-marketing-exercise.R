# assumes variables, etc. still in memory from example's run so no /usr/bin/env/Rscript header here

#
# Exercise 3: marketing
#
# Implement third step to find nearest neighbors based on similarity metric
#
# Requires rmr2 package (https://github.com/RevolutionAnalytics/RHadoop/wiki).
#
# by Jeffrey Breen <jeffrey@jeffreybreen.com>
#



#
# map.step3 - duplicate each keyval pair to produce missing complementary score
#   pairs due to optimization from Step 1. Also, change key from user pair to
#   first user id so our reducer will receive all matchups for each user.
#
# input: ( (user.id.1, user.id.2), similarity)
# output: [ (user.id.1, (user.id.2, similarity)),
#				(user.id.2, (user.id.1, similarity)) ]
#
map.step3 = function(key.df, val)
{
	if (DEBUG)
		debug.log('map-input', key.df, val, '/tmp/rhadoop/marketing/step3')
	
	user1 = key.df$user.id.1
	user2 = key.df$user.id.2
	
	similarity = as.numeric(val)

	output.key = data.frame(user.id.1=c(user1, user2), stringsAsFactors=F)
	output.val = data.frame(user.id.2=c(user2, user1), similarity=c(similarity,similarity),
							stringsAsFactors=F )

	if (DEBUG)
		debug.log('map-output', output.key, output.val, '/tmp/rhadoop/marketing/step3')
	
	return( keyval(output.key, output.val) )
}


#
# reduce.step3 - find users with highest similarity scores to given user
#
# input: (user.id.1, [user.id.2, similarity])
# output: list of top N: [ user.id.1, (user.id.2, similarity) ]
#
reduce.step3 = function(key.df, val.df)
{
	if (DEBUG)
		debug.log('reduce-input', key.df, val.df, '/tmp/rhadoop/marketing/step3')

	neighbor.count=10
	
	val.df$similarity = as.numeric(val.df$similarity)
	# sort (will put NA and NaN at bottom):
	val.df = val.df[rev(order(val.df$similarity)),]
	
	# trim:
	val.df = subset(val.df, similarity > 0)
	val.df = head(val.df, neighbor.count)
	
	output.key = key.df
	output.val = val.df	
	
	if (DEBUG)
		debug.log('reduce-output', output.key, output.val, '/tmp/rhadoop/marketing/step3')

	return( keyval(output.key, output.val) )
}

mr.step3 = function (input, output, backend.parameters=list()) {
	mapreduce(input=input,
			  output=output,
			  map=map.step3,
			  reduce=reduce.step3,
			  backend.parameters=backend.parameters,
			  verbose=T)
}


hdfs.step3 = file.path(hdfs.out, 'step3')

out = mr.step3(input=hdfs.step2, output=hdfs.step3)

results = from.dfs( out)
results.df = as.data.frame(results)
colnames(results.df) = c('user.id.1', 'user.id.2', 'similarity')

# again -- user.id.1-keyed subset will be internally sorted, but the groups
# themselves may not be, so a final sort will yield what we expect

results.df = results.df[with(results.df, order(user.id.1, -similarity) ), ]
rownames(results.df) = NULL

print(head(results.df))
