
knit_child("config_knitr.R")


#      rxDataStep(inData = NULL, outFile = NULL, varsToKeep = NULL, varsToDrop = NULL,
#                 rowSelection = NULL,
#                 transforms = NULL, transformObjects = NULL, transformFunc = NULL, transformVars = NULL,
#                 transformPackages = NULL, transformEnvir = NULL, append = "none", overwrite = FALSE,
#                 removeMissings = FALSE, ... )


infile <- file.path("data", "BankXDF.xdf") 
BankDS <- RxXdfData(file = infile) 


outfile <- file.path("data", "BankSubXDF.xdf") 


BankSubDS <- rxDataStep(inData = BankDS, outFile = outfile, 
                        varsToKeep = c("balance", "age"), overwrite = TRUE)
BankSubDS


rxGetVarInfo(BankSubDS)


infile <- file.path("data", "ChurnData.xdf")
outfile <- file.path("data", "ChurnSubXDF.xdf") 

ChurnDS <- rxDataStep(inData = infile, outFile= outfile, 
                      varsToKeep = c("n.family.members", "n.devices"),
                      overwrite = TRUE)


rxDataStep(inData = BankSubDS, outFile = BankSubDS,
           transforms = list( newBalance = balance + 8019 + 1),
           overwrite=TRUE)


#  rxLinePlot(balance ~ age, type = "p", data = BankSubDS)


#  rxLinePlot(newBalance ~ age, type = "p", data = newDS)


#  rxGetVarInfo( BankDS )
#  
#  newVarInfo <- list(y = list(newName = "term.deposit",
#                              description = "Customer has subscribed to a term deposit"),
#                     poutcome = list(newName = "campaign.outcome",
#                                     description = "Outcome of prior marketing campaign"))


#  rxSetVarInfo(varInfo = newVarInfo, data = BankDS)
#  rxGetVarInfo( BankDS )


#  rxSort(inData, outFile = NULL, sortByVars, decreasing = FALSE, ... )


rxSort(inData = BankSubDS, outFile = BankSubDS, 
       sortByVars=c('balance', 'age'),
       decreasing = c(FALSE, TRUE),
       overwrite=TRUE)


#  rxGetInfo(BankSubDS, numRows=5)


#  outfile <- file.path("data", "BankSubXDF_sort2.xdf")
#  BankSubDS2 <- rxSort(inData = BankSubDS, outFile = outfile,
#                      sortByVars=c('balance', 'age'), decreasing = c(FALSE, TRUE),
#                      removeDupKeys=TRUE, dupFreqVar="Dup_Count")
#  
#  
#  rxGetInfo(BankSubDS, numRows=5)
#  rxGetInfo(BankSubDS2, numRows=5)


#  linMod <- rxLinMod(balance~age, data=BankSubDS2, fweights="Dup_Count")


#  newDS <- rxSort(inData = ChurnDS, sortByVars=c("n.family.members", "n.devices"),
#                  decreasing = c(FALSE, TRUE), removeDupKeys=TRUE, dupFreqVar="Dup_Count")
#  head(newDS)

