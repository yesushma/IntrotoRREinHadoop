#!/usr/bin/env Rscript

#
# rhdfs Example: populate-hdfs
#
# Use rhdfs functions to create /rhadoop-training directory and subdirectories
# for use by the rmr examples in this training ('wordcount', 'airline', and 'marketing').
#
# Populate each directory from local 'data/' directory supplied with the
# training material.
#
# see bin/populate.hdfs.sh for `hadoop` command lines to perform the same
#
# by Jeffrey Breen <jeffrey@jeffreybreen.com>
#


library(rhdfs)

data.root = 'data'
hdfs.root = '/rhadoop-training'

# create in HDFS if needed

if ( !hdfs.exists( hdfs.root ) )
	hdfs.dircreate( hdfs.root )

for (project in c('wordcount', 'airline', 'marketing'))
{
	# local:
	data.path = file.path(data.root, project)
	# HDFS:
	target.path = file.path(hdfs.root, project)
	
	# create in HDFS if needed
	if ( !hdfs.exists( target.path ) )
		hdfs.dircreate( target.path )

	# 'data' subdirectory
	target.path = file.path(target.path, 'data')
	
	# create in HDFS if needed
	if ( !hdfs.exists( target.path ) )
		hdfs.dircreate( target.path )

	# get a list of local files
	local.files = list.files(data.path)
	
	# copy them to HDFS
	hdfs.put(file.path(data.path, local.files), target.path)
}
