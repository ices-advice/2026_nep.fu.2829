## Run SPiCT analysis, write model results

## Before: inp.rds (data)
## After:  fit.rds (model)

library(icesTAF)
library(spict)

mkdir("model")

## Read data object ----
inp <- readRDS("data/inp.rds")


## Define prior values and corresponding sd ----
prior_r <- 0.38    # estimated with stock specific life-history, using jbleslie function from JABBA package
prior_r_sd <- 0.3

prior_sdi <- 0.1
prior_sdi_sd <- 0.3

prior_sdb <- 0.15
prior_sdb_sd <- 0.3

prior_sdc <- 0.1
prior_sdc_sd <- 0.3



## Model settings  ----
inp$priors$logalpha <- c(0,0,0) #disabled
inp$priors$logbeta  <- c(0,0,0) #disabled
inp$priors$logn     <- c(0,0,0) #disable logn prior when fixing n

inp$phases$logn <- -1     #fixing n to resemble the Schaefer production model
inp$ini$logn    <- log(2) #good practice to always define value for logn when fixing

inp$priors$logr   <- c(log(prior_r) - 0.5 * prior_r_sd^2, prior_r_sd, 1)
inp$priors$logsdb <- c(log(prior_sdb) - 0.5 * prior_sdb_sd^2, prior_sdb_sd, 1)
inp$priors$logsdc <- c(log(prior_sdc)-0.5*prior_sdc_sd^2,prior_sdc_sd,1)
inp$priors$logsdi <- list(c(log(prior_sdi)-0.5*prior_sdi_sd^2,prior_sdi_sd,1),
                          c(0,0,0),
                          c(0,0,0))

inp$nspinup <- 160

inp$robflagi <- c(0,1,1) 


inp <- check.inp(inp)


## Fit SPiCT model ----
fit_Sc04_Mod03 <- fit.spict(inp)



## Compute model diagnostics ----
#   - OSA residuals: one-step-ahead residuals for catch and indices
#   - Process residuals
#   - Retrospective analysis (5 and 8 peels)
#   - Hindcast cross-validation (5 and 6 peels)

fit_Sc04_Mod03 <- calc.osa.resid(fit_Sc04_Mod03)
fit_Sc04_Mod03 <- calc.process.resid(fit_Sc04_Mod03)
retrofit_Sc04_Mod03 <- retro(fit_Sc04_Mod03)
hc.fit_Sc04_Mod03 <- hindcast(fit_Sc04_Mod03, npeels=5)
retrofit_Sc04_Mod03_8p <- retro(fit_Sc04_Mod03, nretroyear=8)
hc.fit_Sc04_Mod03_6p <- hindcast(fit_Sc04_Mod03, npeels=6)

fit_Sc04_Mod03


## Diagnostics check-list for acceptance

# 1: Convergence: 0 => OK
retrofit_Sc04_Mod03$opt$convergence

# 2: Finite Parameters: TRUE => OK
all(is.finite(retrofit_Sc04_Mod03$sd))

# 3&8: Violatiom of model assumptions
sumspict.diagnostics(fit_Sc04_Mod03)

# 4: Retrospective pattern: should be between -0.2 and 0.2 (-20% and 20%)
mohns_rho(retrofit_Sc04_Mod03, what=c("BBmsy","FFmsy"))

# 5: Realistic production curve: if between 0.1 and 0.9 => OK
calc.bmsyk(retrofit_Sc04_Mod03)

# 6: Assessment uncertainty: if order of magnitude < 2 => OK)
calc.om(retrofit_Sc04_Mod03)

# 7: Initial Values sensitivity - jitter
#    if same estimates for all initial values => OK (The distance should preferably be close to zero)
sens.ini_Sc04_Mod03 <- check.ini(fit_Sc04_Mod03, ntrials=30)
sens.ini_Sc04_Mod03$check.ini$resmat



## Write results ----

# Write model results
saveRDS(fit_Sc04_Mod03, "model/fit.rds")


# Write model diagnostics (retro and hindcast)
save(retrofit_Sc04_Mod03, hc.fit_Sc04_Mod03, 
     retrofit_Sc04_Mod03_8p, hc.fit_Sc04_Mod03_6p,
     file = "model/diagnostics.RData")
