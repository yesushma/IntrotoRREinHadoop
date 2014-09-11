

infile <- "/Data/data/bank-full.csv"


rxSetComputeContext("local")

colClasses <- c("integer", rep("factor",4), "integer", 
                rep("factor",5), "integer", rep("factor",5))

names(colClasses) <- c("age", "job", "marital", "education", "default", "balance", 
                       "housing", "loan", "contact", "day", "month", "duration", "campaign", 
                       "pdays", "previous", "poutcome", "y")

BankXDF <- rxImport(inData = infile, outFile = file.path("bank.xdf"),
                    colClasses=colClasses,
                    overwrite = TRUE)


rxSetComputeContext(myHadoopCluster)


file.exists("/Data/data/BankXDF.xdf")
source <- "/Data/data/BankXDF.xdf"
bigDir <- paste("/user", Sys.info()[["user"]], sep="/")


inputDir <- file.path(bigDir, "BankXDF")
rxHadoopMakeDir(inputDir)


rxHadoopCopyFromLocal(source, inputDir)
rxHadoopListFiles(inputDir)


source <- "/Data/data/churnXDF.xdf"


inputDir <- file.path(bigDir, "ChurnXDF")
rxHadoopMakeDir(inputDir)


rxHadoopCopyFromLocal(source, inputDir)


hdfsFS <- RxHdfsFileSystem(hostName = myNameNode, port = myPort)


BankDS <- RxXdfData(file = file.path(bigDir, "/BankXDF/BankXDF.xdf"), fileSystem = hdfsFS)


ChurnDS <- RxXdfData(file = file.path(bigDir, "/ChurnXDF/churnXDF.xdf"), fileSystem = hdfsFS)




