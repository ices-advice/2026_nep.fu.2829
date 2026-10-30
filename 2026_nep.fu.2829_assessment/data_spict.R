## Build SPiCT data object
## Before: nep.fu.2829_input.csv (data)
## After:  inp.rds (data)

library(icesTAF)
library(spict)

mkdir("data")

## Read data ----
nep <- read.csv("data/nep.fu.2829_input.csv")


## Build SPiCT input object ----
inp <- list()

inp$timeC <- nep$Year
inp$obsC  <- nep$Catches
inp$timeI <- list(nep$Year + 0.5,
                  nep$Year + 9.5/12, ## mid of October
                  nep$Year + 5.5/12) ## mid of June
inp$obsI  <- list(nep$CPUE,
                  nep$IBTS_DeltaGAM,
                  nep$NepS)


inp$stdevfacI <- list(rep(1, length(inp$timeI[[1]])),
                      rep(1, length(inp$timeI[[2]])),
                      rep(1, length(inp$timeI[[3]])))

cv <- sqrt(exp((nep$IBTS_DeltaGAM_upp - nep$IBTS_DeltaGAM_low) / (2 * 1.96)) - 1)
cv <- cv/mean(cv, na.rm = TRUE)
inp$stdevfacI[[2]][!is.na(cv)] <- cv[!is.na(cv)]
cv <- sqrt(exp((nep$NepS_upp - nep$NepS_low) / (2 * 1.96)) - 1)
cv <- cv/mean(cv, na.rm = TRUE)
inp$stdevfacI[[3]][!is.na(cv)] <- cv[!is.na(cv)]


plotspict.data(inp, qlegend=TRUE)
plotspict.ci(inp)



## Write data object ----
saveRDS(inp, "data/inp.rds")






