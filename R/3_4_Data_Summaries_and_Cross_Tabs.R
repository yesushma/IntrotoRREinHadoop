
knit_child("config_knitr.R")


infile <- file.path("data", "BankXDF.xdf") 
BankDS <- RxXdfData(file = infile) 

rxGetInfo(BankDS)



#  rxGetVarInfo(BankDS)


#  rxGetVarNames(BankXDF)
#  class(rxGetVarNames(BankDS))
#  dput(rxGetVarNames(BankDS))


#  rxGetInfo(ChurnDS)
#  rxGetVarInfo(ChurnDS)
#  rxGetVarNames(ChurnDS)


#  DSSummary <- rxSummary(~ var1 + var2 + ... , data = DS)


BankSummary <- rxSummary(~ balance + age, data = BankDS) 
BankSummary      


BankSummary2 <- rxSummary(balance ~  F(age), data = BankDS) 
BankSummary2      


#  rxQuantile(varName, data, ... )


infile <- file.path("data", "BankSubXDF.xdf") 
BankSubDS <- RxXdfData(file = infile) 

rxSort(inData = BankSubDS, outFile = BankSubDS, 
       sortByVars="age", decreasing = FALSE,
       overwrite=TRUE)

rxGetInfo(BankSubDS, numRows=3)
rxQuantile(varName = "age", data = BankSubDS)


#  rxCrossTabs(formula, data, ... )


#  rxCube(formula, data, ... )


#  rxCrossTabs(balance~F(age, low=20, high=30):F(campaign, low=1, high=5), data = BankDS)


#  rxCrossTabs(~F(n.family.members):F(n.devices), data = ChurnDS)


#      rxLinePlot( y ~ x1 + x2 + ... , data = DS,  . )


rxLinePlot(balance ~ age, type = "p", data = BankSubDS)


#      rxHistogram( y, data = DS,  ... )


#      rxHistogram(~balance|F(age), data = BankSubDS)


rxDataStep(inData = BankSubDS, outFile = BankSubDS, 
           transforms=list(Young = (age <= 43),
                           Middle = (age > 43 & age <= 61), 
                           Old = (age > 61 & age <= 95)),
           overwrite = TRUE)


rxHistogram(~balance|Young, main = "Balance for Young Age", data = BankSubDS) 




rxHistogram(~balance|Middle, main = "Balance for Middle Age", data = BankSubDS) 



rxHistogram(~balance|Old, main = "Balance for Old Age", data = BankSubDS) 


outfile <- file.path("data", "BankFactors.xdf") 
                         
BankFactors <- rxDataStep(inData = BankSubDS, outFile = outfile,
                          transforms = list(
                            F_age = cut(age, 
                                        breaks=c(0,43,61,100),
                                        labels=c("young",
                                                 "middle",
                                                 "old"), 
                                        right=TRUE)),
                          overwrite=TRUE)

rxGetInfo(BankFactors, getVarInfo=TRUE, numRows=5)
rxSummary(~.,BankFactors)


rxHistogram(~balance|F_age, data = BankFactors) 

