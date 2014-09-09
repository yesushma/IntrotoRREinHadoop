
knit_child("config_knitr.R")


infile <- file.path("data", "bank-full.csv") 
outfile <- file.path("data", "BankXDF.xdf") 


colClasses <- c("integer", rep("factor",4), "integer", 
                rep("factor",3), "integer", "factor", rep("integer",4), rep("factor",2))

names(colClasses) <- c("age", "job", "marital", "education", "default", "balance", 
"housing", "loan", "contact", "day", "month", "duration", "campaign", 
"pdays", "previous", "poutcome", "y")

BankXDF <- rxImport(inData = infile, outFile = outfile,
                    colClasses=colClasses, rowsPerRead=10000,
                    overwrite = TRUE)


ChurnXDF <- file.path("data", "ChurnData.xdf")
rxGetInfo(ChurnXDF, numRows=6)


infile <- file.path("data", "bank-full.csv") 
BankDS <- RxTextData(file = infile) 

rxGetInfo(BankDS, numRows=6)


infile <- file.path("data", "BankXDF.xdf") 
BankDS <- RxXdfData(file = infile) 

rxGetInfo(BankDS, getVarInfo=TRUE, numRows=6)
rxSummary(~., BankDS)

