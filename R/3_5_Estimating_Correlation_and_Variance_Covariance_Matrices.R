
knit_child("config_knitr.R")


infile <- file.path("data", "BankXDF.xdf") 
BankDS <- RxXdfData(file = infile) 

houseCor <- rxCor(formula=~age + balance + noHousing, data = BankDS, 
                  transforms = list(
                    noHousing = housing == "no"))


houseCor


#  yCor <- rxCor(formula=~age + duration + yesy, data = BankDS,
#                    transforms = list(
#                      yesy = y == "yes"))


#  yCor

