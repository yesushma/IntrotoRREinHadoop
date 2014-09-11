

## ------------------------------------------------------------------------
houseCor <- rxCovCor(formula=~age + balance + noHousing, data = BankDS,
                  transforms = list(noHousing = (housing == "no")))


## ------------------------------------------------------------------------
houseCor



