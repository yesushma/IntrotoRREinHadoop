yCor <- rxCovCor(formula=~age + duration + yesy, data = BankDS,
                 transforms = list(
                   yesy = y == "yes"))

yCor