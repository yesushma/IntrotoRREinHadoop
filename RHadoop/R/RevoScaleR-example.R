myNameNode <- "master.local"
myPort <- 8020
bigDataDirRoot <- "/share"
hdfsShareDir <- "/var/RevoShare/luba"
myHadoopCluster <- RxHadoopMR(nameNode=myNameNode, hdfsShareDir=hdfsShareDir)

myShareDir = paste( "/var/RevoShare", Sys.info()[["user"]], sep="/" )

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
