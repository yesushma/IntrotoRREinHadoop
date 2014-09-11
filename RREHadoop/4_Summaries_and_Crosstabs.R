library(lattice)

## ------------------------------------------------------------------------
infile <- file.path(bigDir, "BankXDF", "BankXDF.xdf")
BankDS <- RxXdfData(file = infile, fileSystem=hdfsFS)

rxGetInfo(BankDS, getVarInfo=T)


rxGetVarNames(BankDS)
## class(rxGetVarNames(BankDS))
## dput(rxGetVarNames(BankDS))


## ----, eval = FALSE, tidy=FALSE------------------------------------------
## rxGetInfo(ChurnDS)
## rxGetVarInfo(ChurnDS)
## rxGetVarNames(ChurnDS)


## ----, eval = FALSE------------------------------------------------------
## DSSummary <- rxSummary(~ var1 + var2 + ... , data = DS)


## ------------------------------------------------------------------------
BankSummary <- rxSummary(~ balance + age, data = BankDS)
BankSummary     


## ------------------------------------------------------------------------
BankSummary2 <- rxSummary(balance ~  F(age), data = BankDS)
BankSummary2     


## ----, eval = FALSE------------------------------------------------------
## rxQuantile(varName, data, ... )


## ----, eval = FALSE------------------------------------------------------
## infile <- file.path("data", "BankSubXDF.xdf")
## BankSubDS <- RxXdfData(file = infile)
##
## rxSort(inData = BankSubDS, outFile = BankSubDS,
##        sortByVars="age", decreasing = FALSE,
##        overwrite=TRUE)
##
## rxGetInfo(BankSubDS, numRows=3)
rxQuantile(varName = "age", data = BankSubDS)


## ----, eval = FALSE------------------------------------------------------
## rxCrossTabs(formula, data, ... )


## ----, eval = FALSE------------------------------------------------------
## rxCube(formula, data, ... )


rxCrossTabs(balance~F(age, low=20, high=30):F(campaign, low=1, high=5), data = BankDS)


## ----, eval = FALSE------------------------------------------------------
##     rxHistogram( y, data = DS,  ... )


## ----, eval = TRUE-------------------------------------------------------
rxHistogram(~balance, data = BankSubDS)

rxHistogram(~balance|F(age), data = BankSubDS)


## ------------------------------------------------------------------------
rxDataStep(inData = BankSubDS, outFile = BankSubDS,
           transforms=list(Young = (age <= 43),
                           Middle = (age > 43 & age <= 61),
                           Old = (age > 61 & age <= 95)),
           overwrite = TRUE)

rxGetInfo(BankSubDS, getVarInfo=T)
## ------------------------------------------------------------------------
rxHistogram(~balance|Young, main = "Balance for Young Age", data = BankSubDS)



## ------------------------------------------------------------------------

rxHistogram(~balance|Middle, main = "Balance for Middle Age", data = BankSubDS)


## ------------------------------------------------------------------------

rxHistogram(~balance|Old, main = "Balance for Old Age", data = BankSubDS)


## ------------------------------------------------------------------------
