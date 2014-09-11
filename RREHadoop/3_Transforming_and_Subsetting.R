

# bigDir <- paste("/user", Sys.info()[["user"]], sep="/")


## ?rxDataStep
## ------------------------------------------------------------------------
infile <- file.path(bigDir, "BankXDF", "BankXDF.xdf")
BankDS <- RxXdfData(file = infile, fileSystem=hdfsFS)

rxHadoopMakeDir(file.path(bigDir, "BankSub"))
outfile <- file.path(bigDir, "BankSub")
BankSubDS <- RxXdfData(outfile, fileSystem=hdfsFS)

## ------------------------------------------------------------------------
rxDataStep(inData = BankDS, outFile = BankSubDS,
                        varsToKeep = c("balance", "age"), overwrite = TRUE)


## ------------------------------------------------------------------------
rxGetInfo(BankSubDS, getVarInfo=T)



## ------------------------------------------------------------------------
rxDataStep(inData = BankSubDS, outFile = BankSubDS,
           transforms = list( newBalance = balance + 8019 + 1),
           overwrite=TRUE)


## ----, eval = FALSE------------------------------------------------------
## rxLinePlot(balance ~ age, type = "p", data = BankSubDS)


## ----, eval = TRUE-------------------------------------------------------
rxLinePlot(newBalance ~ age, type = "p", data = BankSubDS)


## This works only in native filesystem (rxSetVarInfo won't work in Hadoop)
# rxGetVarInfo( BankDS )
# 
# newVarInfo <- list(y = list(newName = "term.deposit",
#                              description = "Customer has subscribed to a term deposit"),
#                     poutcome = list(newName = "campaign.outcome",
#                                     description = "Outcome of prior marketing campaign"))
# 
# 
# 
# rxSetVarInfo(varInfo = newVarInfo, data = BankDS)
# rxGetVarInfo( BankDS )


## ----, eval = FALSE------------------------------------------------------
## rxSort(inData, outFile = NULL, sortByVars, decreasing = FALSE, ... )


## 'rxSort' calls are not inherently distributable
# rxSort(inData = BankSubDS, outFile = BankSubDS,
#        sortByVars=c('balance', 'age'),
#        decreasing = c(FALSE, TRUE),
#        overwrite=TRUE)

