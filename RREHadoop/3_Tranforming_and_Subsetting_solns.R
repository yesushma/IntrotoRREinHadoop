
## ------------------------------------------------------------------------
infile <- file.path(bigDir, "ChurnXDF", "churnXDF.xdf")
ChurnDS <- RxXdfData(file = infile, fileSystem=hdfsFS)

rxHadoopMakeDir(file.path(bigDir, "ChurnSub"))
outfile <- file.path(bigDir, "ChurnSub")
ChurnSubDS <- RxXdfData(outfile, fileSystem=hdfsFS)

rxDataStep(inData = ChurnDS, outFile= ChurnSubDS, varsToKeep = c("n.family.members", "n.devices"),
                      overwrite = TRUE)

rxGetInfo(ChurnSubDS, getVarInfo=T)


