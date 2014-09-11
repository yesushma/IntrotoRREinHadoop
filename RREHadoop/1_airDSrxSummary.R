myNameNode <- "master.local"
myPort <- 8020
bigDataDirRoot <- "/share"
hdfsShareDir <- paste( "/var/RevoShare", Sys.info()[["user"]], sep="/" )
myHadoopCluster <- RxHadoopMR(nameNode=myNameNode, hdfsShareDir=hdfsShareDir)

#rxSetComputeContext("local")
rxSetComputeContext(myHadoopCluster)

rxHadoopListFiles(bigDataDirRoot)

source <-system.file("SampleData/AirlineDemoSmall.csv",
                     package="RevoScaleR")
inputDir <- file.path(bigDataDirRoot,"AirlineDemoSmall")
rxHadoopMakeDir(inputDir)
rxHadoopCopyFromLocal(source, inputDir)

rxHadoopListFiles(inputDir)

hdfsFS <- RxHdfsFileSystem(hostName=myNameNode, port=myPort)

colInfo <- list(DayOfWeek = list(type = "factor",
                                 levels = c("Monday", "Tuesday", "Wednesday", "Thursday",
                                            "Friday", "Saturday", "Sunday")))

airDS <- RxTextData(file = inputDir, missingValueString = "M",
                    colInfo = colInfo, fileSystem = hdfsFS)

adsSummary <- rxSummary(~ArrDelay+CRSDepTime+DayOfWeek,
                        data = airDS)

adsSummary

