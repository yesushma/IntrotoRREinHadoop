
knit_child("config_knitr.R")


exp(7.669962)


infile <- file.path("data", "BankSubXDF.xdf") 
BankSubDS <- RxXdfData(file = infile) 

rxDataStep(inData = BankSubDS, outFile = BankSubDS,
                    transforms = list(logBalance = log(newBalance)), 
                    overwrite = TRUE)
BankSubSummary <- rxSummary(~ logBalance, data = BankSubDS)
BankSubSummary

rxHistogram(~logBalance, data = BankSubDS)


(minBal <- rxGetVarInfo(BankSubDS)$balance[[3]])
(maxBal <- rxGetVarInfo(BankSubDS)$balance[[4]])


simplyNormalize <- function(dataList) {
  dataList[["normBalance"]] <- (dataList[["balance"]] - minBalance) / (maxBalance-minBalance)
	dataList[["moreThanHalf"]] <- dataList[["normBalance"]] > 0.5
	dataList[["newConst"]] <- rep(23, length.out=length(dataList[[1]]))
	return(dataList)
}


rxDataStep(inData=BankSubDS,
           outFile=BankSubDS,
           transformFunc = simplyNormalize, 
           transformObjects = list(minBalance=minBal, maxBalance=maxBal),
           overwrite=TRUE)


rxGetInfo(data=BankSubDS, getVarInfo=TRUE)


rxHistogram(~normBalance, data=BankSubDS,xnNumTicks=15)


rxSummary(~normBalance, data=BankSubDS)


minBal; maxBal
rxDataStep(inData=BankSubDS,
           outFile=BankSubDS,
           transforms = list( normBalance3 = (balance - (-8019)) / (102127-(-8019))),
           overwrite=TRUE)


plot1 <- rxHistogram(~normBalance, data=BankSubDS,xnNumTicks=15)
plot2 <- rxHistogram(~normBalance3, data=BankSubDS,xnNumTicks=15) 


print(plot1, split=c(1,1,2,1), more=TRUE)
print(plot2, split=c(2,1,2,1), more=FALSE)   


newTransformFunc <- function(dataList) {
	
	dataList[["F_balance"]] <- cut(x=dataList[["balance"]], breaks = seq(0,110000,10000))
	dataList[["stringAge"]] <- as.character(dataList[["age"]])
	return(dataList)
	
}

smallBank <- file.path("data", "smallerBanks.xdf")

rxDataStep(inData=BankSubDS, 
	       outFile = smallBank, 
	       rowSelection=(Young=="TRUE") & (balance>0),  
		   transformFunc=newTransformFunc, 
		   overwrite=TRUE)

rxGetInfo(smallBank, getVarInfo=TRUE, numRows=3, startRow=1000)


manualFactorRecoding <- function(dataList) {
  dataList[["F_n.devices"]] <- factor(dataList[["n.devices"]])
	return(dataList)
}


infile <- file.path("data", "ChurnData.xdf") 
ChurnDS <- RxXdfData(file = infile) 




#  rxDataStep(inData=ChurnDS,
#             outFile = ChurnDS,
#             transformFunc=manualFactorRecoding,
#             overwrite=TRUE)
#  
#  # Rows Read: 500000, Total Rows Processed: 500000, Total Chunk Time: 0.686 seconds
#  # Existing and new value labels must be the same. There are fewer value labels in the new data for variable F_n.devices.
#  # Error in rxCall("RxDataStep", params) :


#  rxDataStep(inData=ChurnDS,
#             outFile = ChurnDS,
#             transformFunc=manualFactorRecoding,
#             overwrite=TRUE)
#  
#  # Rows Read: 500000, Total Rows Processed: 500000, Total Chunk Time: 0.686 seconds
#  # Existing and new value labels must be the same. There are fewer value labels in the new data for variable F_n.devices.
#  # Error in rxCall("RxDataStep", params) :


manualFactorRecoding <- function(dataList) {
  dataList[["F_n.devices"]] <- factor(dataList[["n.devices"]],levels=seq(1,10))
  return(dataList)
}

rxDataStep(inData=ChurnDS, 
           outFile = ChurnDS,
           transformFunc=manualFactorRecoding,  
           overwrite=TRUE)


rxFactors(inData=ChurnDS, 
	      outFile=ChurnDS, 
		  factorInfo=list(F_n.devices2 = list(levels=seq(1:10), varName="n.devices")),
		  overwrite=TRUE)

rxGetInfo(ChurnDS, getVarInfo=TRUE)


rxCrossTabs(~F(n.devices):F_n.devices, data=ChurnDS)


rxCrossTabs(~F(n.devices):F_n.devices2, data=ChurnDS)


rxDataStep(inData = BankSubDS,
           outFile = BankSubDS,
           transforms=list(urns = as.integer(runif(.rxNumRows,1,11))),
           # OR:
           # transforms=list(urns = as.integer(runif(length(DayOfWeek),1,11))),
           overwrite=TRUE)


rxGetInfo(BankSubDS,getVarInfo=TRUE,numRows=3)

rxHistogram(~urns, BankSubDS, xNumTicks=10)


BankSubDF <- rxDataStep(inData = BankSubDS, rowSelection = urns==1, overwrite=TRUE)

rxGetInfo(BankSubDF,getVarInfo=TRUE,numRows=3)

rxHistogram(~urns, BankSubDF, xNumTicks=10)

