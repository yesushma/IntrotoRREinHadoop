
#  RxHadoopMR()
#  
#    # RevoScaleR Hadoop MapReduce Local Object
#    # ----------------------------------------
#    # hdfsShareDir : "/user/RevoShare/luba"
#    # clientShareDir : "/tmp"
#    # hadoopRPath : "/usr/bin/Revo64"
#    # hadoopSwitches : ""
#    # sshUsername : "luba"
#    # sshHostname : "master.local"
#    # sshSwitches : ""
#    # sshProfileScript : NULL
#    # sshClientDir : ""
#    # nameNode : ""
#    # jobTrackerURL : NULL
#    # port : 8020
#    # showOutputWhileWaiting : TRUE


#    # fileSystem : NULL
#    # shareDir : "/var/RevoShare/luba"
#    # revoPath : "/usr/bin/Revo64"
#    # wait : TRUE
#    # consoleOutput : FALSE
#    # autoCleanup : TRUE
#    # workingDir : NULL
#    # dataPath : NULL
#    # outDataPath : NULL
#    # packagesToLoad : NULL
#    # email : NULL
#    # resultsTimeout : 15
#    # description : "hadoopmr"
#    # version : "1.0-2"


#  rxSetComputeContext("local")


#  myHadoopCluster <- RxHadoopMR()


#  rxSetComputeContext(myHadoopCluster)


#  # This is the same username you use to log on to the linux machine
#    mySshUsername <- "luba"
#    mySshHostname <- "master.local"
#  
#  # Port number of the Hadoop Name Node
#    myPort <- "8020"
#  
#  # Host name of the Hadoop Name Node
#    myNameNode <- "master.local"
#  
#  # Local location for writing various files onto the HDFS from the local file system
#    myShareDir <- "/home/Ben_Examples"
#  
#  # The HDFS share file location
#    myHdfsShareDir <- paste("/user/RevoShare",mySshUsername, sep="/")


#      myHadoopCluster <- RxHadoopMR(
#        	hdfsShareDir = myHdfsShareDir,
#    			shareDir     = myShareDir,
#    			sshUsername  = mySshUsername,
#    			autoCleanup = FALSE,
#    			nameNode = myNameNode)


#  		rxSetComputeContext(myHadoopCluster)


#      file.exists("localFilePath")


#      rxHadoopListFiles(bigDataDirRoot)


#      source <- "localFilePath"
#      inputDir <- file.path(bigDataDirRoot, "fileName")
#      rxHadoopMakeDir(inputDir)
#      rxHadoopCopyFromLocal(source, inputDir)


#      rxHadoopListFiles(inputDir)


#      infile <- "/home/Ben_Examples/bank-full.csv"


#  rxSetComputeContext("local")


#      BankXDFDS <- rxImport(inData = infile, outFile = "/home/Ben_Examples/BankXDF.xdf", overwrite = TRUE)
#      # Rows Read: 100000, Total Rows Processed: 100000, Total Chunk Time: 3.380 seconds


#  rxSetComputeContext(myHadoopCluster)


#      file.exists("/home/Ben_Examples/BankXDF.xdf")
#      # [1] TRUE


#      source <- "/home/Ben_Examples/BankXDF.xdf"
#      bigDir <- "/user/luba/share"


#      inputDir <- file.path(bigDir, "BankXDF")
#      rxHadoopMakeDir(inputDir)


#      rxHadoopCopyFromLocal(source, inputDir)
#      rxHadoopListFiles(inputDir)
#      # Found 1 items
#      # -rw-r--r--   3 luba hadoop     549817 2014-04-07 17:10 /user/luba/share/BankXDF/BankXDF.xdf


#      # [luba@master Ben_Examples]$ hadoop fs -ls /user/luba/share/BankXDF
#      # Found 2 items
#      # -rw-r--r--   3 luba hadoop   17165067 2014-03-05 17:01 /user/luba/Churn/ChurnData.dat
#      # -rw-r--r--   3 luba hadoop    4306814 2014-03-05 18:45 /user/luba/Churn/ChurnXDF.xdf


#      source <- "/home/Ben_Examples/ChurnXDF.xdf"
#      bigDir <- "/user/luba/share"


#      inputDir <- file.path(bigDir, "ChurnXDF")
#      rxHadoopMakeDir(inputDir)


#      rxHadoopCopyFromLocal(source, inputDir)


#      hdfsFS <- RxHdfsFileSystem(hostName = myNameNode, port = myPort)


#      colInfo <- list(DayOfWeek = list(type = "factor",  levels = c("Monday", "Tuesday", "Wednesday", "Thursday",  "Friday", "Saturday", "Sunday")))


#      DS <- RxTextData(file = inputDir, missingValueString = "missingValueString", colInfo = colInfo, fileSystem = hdfsFS)


#  hdfsFS <- RxHdfsFileSystem(hostName = "master.local", port = 8020)


#  BankDS <- RxXdfData(file = "/user/luba/share/BankXDF/BankXDF.xdf", fileSystem = hdfsFS)


#      ChurnDS <- RxXdfData(file = "/user/luba/share/ChurnXDF/ChurnXDF.xdf", fileSystem = hdfsFS)


#      rxHadoopCopyFromClient(source, nativeTarget="/tmp", hdfsDest,
#                         computeContext, sshUsername=NULL,
#                         sshHostname=NULL, sshSwitches=NULL, sshProfileScript=NULL)


#      rxHadoopCopyToLocal(source, destination, ...)


#      rxHadoopCommand(cmd, computeContext, sshUsername=NULL,
#                  sshHostname=NULL,
#                  sshSwitches=NULL,
#                  sshProfileScript=NULL)


#      rxHadoopMakeDir(path, ...)


#      rxHadoopListFiles(path="", recursive=FALSE, ...)


#      rxHadoopRemove(path, skipTrash=FALSE, ...)


#      rxHadoopCopy(source, dest, ...)


#      rxHadoopRemove(path, skipTrash=FALSE, ...)


#      rxHadoopMakeDir(path, ...)


#      rxHadoopRemoveDir(path, skipTrash=FALSE, ...)

