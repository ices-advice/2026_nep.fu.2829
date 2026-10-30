## write TAF data tables  ------------- Do we need this?

## Before: nep.fu.2829_input.csv (data)
## After:  index.csv, landings.csv (data)


library(icesTAF)
library(dplyr)

mkdir("data")

## Read data ----

nep <- read.csv("boot/initial/data/nep.fu.2829_input.csv", header=TRUE, sep=";", dec=".")


## Extract data for TAF tables ----
landings <- nep %>% dplyr::select(Year, Catches)

index <- nep %>% 
  dplyr::select(Year, CPUE, NepS, IBTS_DeltaGAM) %>%
  rename(Index1 = CPUE, Index2 = NepS, Index3 = IBTS_DeltaGAM)



## Write TAF tables and data object ----
write.taf(landings, dir="data")
write.taf(index, dir="data")