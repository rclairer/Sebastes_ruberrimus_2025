#CONTENTS
#stepAIC_delta: prints out the step AIC results (instead of just outputting chosen model)
###################Functions using separate models for the bionomial and log/gamma models#################################
##deltalogmix:      uses different models for binomial and lognormal model
##deltagammix:      uses different models for binomial and gamma model
##GeoAvgmix:        Calculates geometic average to compare with deltamix models
##deltabootmix:     Bootstraps deltamix models
##CPUEanalysismix:  Produces CPUEs for deltalog, deltagamma, Geometric average with bootstrapped CVs
##########################################################################################################################
##########################################################################################################################
##################Functions using separate models for the bionomial and log/gamma models##################################
##deltalog:     CPUE from deltalog model
##deltagam:     CPUE from deltagamma model
##GeoAvg:       Calculates geometic average
##deltaboot:        Bootstraps CVs for chosen model
##CPUEanalysis:     Produces CPUEs for deltalog, deltagamma, Geometric average with bootstrapped CVs for chosen model
##########################################################################################################################
##########################################################################################################################
##########################Delta models incorporating model selection######################################################
##deltaglmselect:   Calculates and prints to file the AIC for inputted model for the binomial, lognormal, and gamma models
##mod_sel_CPUE:     Calculates and prints to file the AIC for all stepwise models for the binomial, lognormal, and gamma models
##deltalog.step:    Outputs AIC and delta CPUE index from each of the best models for the binomial and lognormal models
##deltagam.step:    Outputs AIC and delta CPUE index from each of the best models for the binomial and gamma models
##deltalogII:       Same as deltalog.step, but doesn't include a correction for area factors with low representation
##########################################################################################################################
##deltalog.interactions: Provides summary of Year:last factor (area) interactions 
##########################################################################################################################


#LOAD LIBRARIES
#library(MASS)
library(lattice)
library(boot)
#################



stepAIC_delta<-function (object, model_name, scope, scale = 0, direction = c("both", "backward", 
    "forward"), trace = 1, keep = NULL, steps = 1000, use.start = FALSE, 
    k = 2, ...) 
{
    mydeviance <- function(x, ...) {
        dev <- deviance(x)
        if (!is.null(dev)) 
            dev
        else extractAIC(x, k = 0)[2]
    }
    cut.string <- function(string) {
        if (length(string) > 1) 
            string[-1] <- paste("\n", string[-1], sep = "")
        string
    }
    re.arrange <- function(keep) {
        namr <- names(k1 <- keep[[1]])
        namc <- names(keep)
        nc <- length(keep)
        nr <- length(k1)
        array(unlist(keep, recursive = FALSE), c(nr, nc), list(namr, 
            namc))
    }
    step.results <- function(models, fit, object, usingCp = FALSE) {
        change <- sapply(models, "[[", "change")
        rd <- sapply(models, "[[", "deviance")
        dd <- c(NA, abs(diff(rd)))
        rdf <- sapply(models, "[[", "df.resid")
        ddf <- c(NA, abs(diff(rdf)))
        AIC <- sapply(models, "[[", "AIC")
        heading <- c("Stepwise Model Path \nAnalysis of Deviance Table", 
            "\nInitial Model:", deparse(as.vector(formula(object))), 
            "\nFinal Model:", deparse(as.vector(formula(fit))), 
            "\n")
        aod <- if (usingCp) 
            data.frame(Step = change, Df = ddf, Deviance = dd, 
                "Resid. Df" = rdf, "Resid. Dev" = rd, Cp = AIC, 
                check.names = FALSE)
        else data.frame(Step = change, Df = ddf, Deviance = dd, 
            "Resid. Df" = rdf, "Resid. Dev" = rd, AIC = AIC, 
            check.names = FALSE)
        attr(aod, "heading") <- heading
        class(aod) <- c("Anova", "data.frame")
        fit$anova <- aod
        fit
    }
    aod.list<-list()
    aod.list[[1]]<-paste(model_name, "model selection", sep=" ")
    names(aod.list)[[1]]<-"Model"
    Terms <- terms(object)
    object$formula <- Terms
    if (inherits(object, "lme")) 
        object$call$fixed <- Terms
    else if (inherits(object, "gls")) 
        object$call$model <- Terms
    else object$call$formula <- Terms
    if (use.start) 
        warning("'use.start' cannot be used with R's version of glm")
    md <- missing(direction)
    direction <- match.arg(direction)
    backward <- direction == "both" | direction == "backward"
    forward <- direction == "both" | direction == "forward"
    if (missing(scope)) {
        fdrop <- numeric(0)
        fadd <- attr(Terms, "factors")
        if (md) 
            forward <- FALSE
    }
    else {
        if (is.list(scope)) {
            fdrop <- if (!is.null(fdrop <- scope$lower)) 
                attr(terms(update.formula(object, fdrop)), "factors")
            else numeric(0)
            fadd <- if (!is.null(fadd <- scope$upper)) 
                attr(terms(update.formula(object, fadd)), "factors")
        }
        else {
            fadd <- if (!is.null(fadd <- scope)) 
                attr(terms(update.formula(object, scope)), "factors")
            fdrop <- numeric(0)
        }
    }
    models <- vector("list", steps)
    if (!is.null(keep)) 
        keep.list <- vector("list", steps)
    if (is.list(object) && (nmm <- match("nobs", names(object), 
        0)) > 0) 
        n <- object[[nmm]]
    else n <- length(residuals(object))
    fit <- object
    bAIC <- extractAIC(fit, scale, k = k, ...)
    edf <- bAIC[1]
    bAIC <- bAIC[2]
    if (is.na(bAIC)) 
        stop("AIC is not defined for this model, so stepAIC cannot proceed")
    nm <- 1
    nm_i<-nm
    Terms <- terms(fit)
    if (trace) {
        cat("Start:  AIC=", format(round(bAIC, 2)), "\n", cut.string(deparse(as.vector(formula(fit)))), 
            "\n\n")
     mod_start<-paste("Start model:", cut.string(deparse(as.vector(formula(fit)))),";","AIC=", format(round(bAIC, 2)),  sep=" ")
     aod.list[[nm+1]]<-mod_start
     names(aod.list)[[nm+1]]<-paste("Model",nm,sep=" ")
       
        flush.console()
    }
    models[[nm]] <- list(deviance = mydeviance(fit), df.resid = n - 
        edf, change = "", AIC = bAIC)
    if (!is.null(keep)) 
        keep.list[[nm]] <- keep(fit, bAIC)
    usingCp <- FALSE
    while (steps > 0) {
        steps <- steps - 1
        AIC <- bAIC
        ffac <- attr(Terms, "factors")
        if (!is.null(sp <- attr(Terms, "specials")) && !is.null(st <- sp$strata)) 
            ffac <- ffac[-st, ]
        scope <- factor.scope(ffac, list(add = fadd, drop = fdrop))
        aod <- NULL
        change <- NULL
        if (backward && length(scope$drop)) {
            aod <- dropterm(fit, scope$drop, scale = scale, trace = max(0, 
                trace - 1), k = k, ...)
            rn <- row.names(aod)
            row.names(aod) <- c(rn[1], paste("-", rn[-1], sep = " "))
            if (any(aod$Df == 0, na.rm = TRUE)) {
                zdf <- aod$Df == 0 & !is.na(aod$Df)
                nc <- match(c("Cp", "AIC"), names(aod))
                nc <- nc[!is.na(nc)][1]
                ch <- abs(aod[zdf, nc] - aod[1, nc]) > 0.01
                if (any(ch)) {
                  warning("0 df terms are changing AIC")
                  zdf <- zdf[!ch]
                }
                if (length(zdf) > 0) 
                  change <- rev(rownames(aod)[zdf])[1]
            }
        }
        if (is.null(change)) {
            if (forward && length(scope$add)) {
                aodf <- addterm(fit, scope$add, scale = scale, 
                  trace = max(0, trace - 1), k = k, ...)
                rn <- row.names(aodf)
                row.names(aodf) <- c(rn[1], paste("+", rn[-1], 
                  sep = " "))
                aod <- if (is.null(aod)) 
                  aodf
                else rbind(aod, aodf[-1, , drop = FALSE])
            }
            attr(aod, "heading") <- NULL
            if (is.null(aod) || ncol(aod) == 0) 
                break
            nzdf <- if (!is.null(aod$Df)) 
                aod$Df != 0 | is.na(aod$Df)
            aod <- aod[nzdf, ]
            if (is.null(aod) || ncol(aod) == 0) 
                break
            nc <- match(c("Cp", "AIC"), names(aod))
            nc <- nc[!is.na(nc)][1]
            o <- order(aod[, nc])
        aod.list[[nm_i+2]]<-aod[o,]
        names(aod.list)[[nm_i+2]]<-paste("Table",nm,sep=" ")
            if (trace) {
                print(aod[o, ])
                flush.console()
            }
            if (o[1] == 1) 
                break
            change <- rownames(aod)[o[1]]
        }
        usingCp <- match("Cp", names(aod), 0) > 0
        fit <- update(fit, paste("~ .", change), evaluate = FALSE)
        fit <- eval.parent(fit)
        if (is.list(fit) && (nmm <- match("nobs", names(fit), 
            0)) > 0) 
            nnew <- fit[[nmm]]
        else nnew <- length(residuals(fit))
        if (nnew != n) 
            stop("number of rows in use has changed: remove missing values?")
        Terms <- terms(fit)
        bAIC <- extractAIC(fit, scale, k = k, ...)
        edf <- bAIC[1]
        bAIC <- bAIC[2]
        if (trace) {
            cat("\nStep:  AIC=", format(round(bAIC, 2)), "\n", cut.string(deparse(as.vector(formula(fit)))),"\n\n")
        mod_start<-paste("Start model:", cut.string(deparse(as.vector(formula(fit)))),";","AIC=", format(round(bAIC, 2)),  sep=" ")
        aod.list[[nm_i+3]]<-mod_start
        names(aod.list)[[nm_i+3]]<-paste("Model",nm+1,sep=" ")
            flush.console()
        }
        if (bAIC >= AIC + 1e-07) 
            break
        nm <- nm + 1
    nm_i<-nm_i+2
        models[[nm]] <- list(deviance = mydeviance(fit), df.resid = n - 
            edf, change = change, AIC = bAIC)
        if (!is.null(keep)) 
            keep.list[[nm]] <- keep(fit, bAIC)
    }
    if (!is.null(keep)) 
        fit$keep <- re.arrange(keep.list[seq(nm)])
    step.results(models = models[seq(nm)], fit, object, usingCp)
    return(aod.list)
}

#######################################**************####################################################
#######################################LOAD CPUE CODE####################################################
#######################################**************####################################################
#*********************************************General Delta Lognormal Code*********************************************************
 deltalogmix<-function(DataFilebi,DataFileErr)
{
 #DataFile should be ordered as follows
  # Column 1: CPUE
  # Column 2: Year (always Factor 1)
  # Remaining columns: Additional factors
  #Create factors
  for (i in 2:ncol(DataFilebi)) 
    {
         DataFilebi[[i]] <- as.factor(DataFilebi[[i]])
     }
  for (i in 2:ncol(DataFileErr)) 
    {
         DataFileErr[[i]] <- as.factor(DataFileErr[[i]])
     }
  #Create non-zero data set
  nonOdatabi <- DataFilebi[DataFilebi[,1]>0,]
  nonOdatalog <- DataFileErr[DataFileErr[,1]>0,]

   #Create weigth vector
  wt.vec = rep(1,nrow(DataFileErr))

  #Sort factor levels
  for (i in 2:ncol(DataFilebi)) 
    {
        DataFilebi[[i]] <- factor(DataFilebi[[i]], levels=(names(sort(table(nonOdatabi[[i]]),decreasing=T))))
    } 
  nonOdatabi <- DataFilebi[DataFilebi[,1]> 0,]
 
 for (i in 2:ncol(DataFileErr)) 
    {
        DataFileErr[[i]] <- factor(DataFileErr[[i]], levels=(names(sort(table(nonOdatalog[[i]]),decreasing=T))))
    } 
  nonOdatalog <- DataFileErr[DataFileErr[,1]> 0,]
 
  #Create binary data set
  Bidat<-DataFilebi
  Bidat[, 1] <- as.numeric(DataFilebi[, 1] > 0)
  #Binomial GLM formulas   
  bifactors<-paste(names(Bidat)[2:length(Bidat)],collapse="+")
  biform<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),bifactors))
  #Binomial Glm
  GLMbi <- glm(biform,data=Bidat,family="binomial",maxit=100)
  #print(paste("Binomial AIC:",GLMbi$aic))
  #print(paste("Binomial Deviance:",GLMbi$deviance))
  
  #Calculate mean effects  
  bitemp<-0
  if (length(dummy.coef(GLMbi))>2)
     {
     for (i in 3:length(dummy.coef(GLMbi)))
        {
    bitemp[i-1]<-mean(dummy.coef(GLMbi)[[i]])
    }
    bifact<-sum(bitemp)
     }
  if (length(dummy.coef(GLMbi))==2)
     bifact<-0
  bisumcoeff<-dummy.coef(GLMbi)[[1]] + dummy.coef(GLMbi)[[2]] + bifact
  biindex<- exp(bisumcoeff)/(1+exp(bisumcoeff))
  
  #Lognormal GLM
  formfact<-names(DataFileErr)[2]
  wts <- wt.vec[as.numeric(rownames(nonOdata))]
  if (length(names(DataFileErr))>2)
     {
     for (j in 3:length(names(DataFileErr)))
        {
        formfact<-paste(cbind(formfact,names(DataFileErr)[j]),collapse="+")
    }
    logfactors<-formfact
      }
   if (length(names(DataFileErr))==2)
       logfactors<-formfact
  logform<-as.formula(paste(paste("log(",(names(DataFileErr)[1]),")","~",collapse=NULL),logfactors))
  GLMlog<-glm(logform,data=nonOdatalog, weights=wts, family=gaussian,maxit=100)
  #print(paste("Lognormal AIC:",GLMlog$aic))
  #print(paste("Lognormal Deviance:",GLMlog$deviance))
  #plot(GLMlog)
  biascorr <- GLMlog$deviance/GLMlog$df.residual/2     
  
  logtemp<-0
    if (length(dummy.coef(GLMlog))>2)
     {
     for (i in 3:length(dummy.coef(GLMlog)))
        {
    logtemp[i-1]<-mean(dummy.coef(GLMlog)[[i]])
    }
    logfact<-sum(logtemp)
     }
  if (length(dummy.coef(GLMlog))==2)
     logfact<-0
  logindex<-exp(dummy.coef(GLMlog)[[1]] + dummy.coef(GLMlog)[[2]] + logfact+biascorr)
  biindex<-biindex[names(logindex)]
  deltaindex<-cbind(biindex*logindex)
  DeltaIndex<-c(1:length(levels(DataFilebi[,2])))*0
  dim(DeltaIndex)<-c(length(DeltaIndex),1)
  numrows<-levels(DataFilebi[,2])
  names(DeltaIndex)<-matrix(numrows,1)
  DeltaIndex[1:length(deltaindex)]<-deltaindex[,1]
  ord<-order(names(DeltaIndex))
  deltaindex<-cbind(DeltaIndex[ord])
  deltalogindex<-cbind(as.numeric(deltaindex))
  }
#CPUElogmix<-deltalogmix(DataFileN_yrmoday,DataFileN_yrmoday)

#***********************************************************************************************************************************

#***********************************************************************************************************************************
deltagammix<-function(DataFilebi,DataFileErr)
{
 #DataFile should be ordered as follows
  # Column 1: CPUE
  # Column 2: Binary form of CPUE
  # Column 3: Year (always Factor 1)
  # Remaining columns: Additional factors
  #Create factors
  for (i in 2:ncol(DataFilebi)) 
    {
         DataFilebi[[i]] <- as.factor(DataFilebi[[i]])
     }
  for (i in 2:ncol(DataFileErr)) 
    {
         DataFileErr[[i]] <- as.factor(DataFileErr[[i]])
     }
  #Create non-zero data set
  nonOdatabi <- DataFilebi[DataFilebi[,1]>0,]
  nonOdatagam <- DataFileErr[DataFileErr[,1]>0,]
  
  #Sort factor levels
  for (i in 2:ncol(DataFilebi)) 
    {
        DataFilebi[[i]] <- factor(DataFilebi[[i]], levels=(names(sort(table(nonOdatabi[[i]]),decreasing=T))))
    } 
  nonOdatabi <- DataFilebi[DataFilebi[,1]> 0,]

  for (i in 2:ncol(DataFileErr)) 
    {
        DataFileErr[[i]] <- factor(DataFileErr[[i]], levels=(names(sort(table(nonOdatagam[[i]]),decreasing=T))))
    } 
  nonOdatagam <- DataFileErr[DataFileErr[,1]> 0,]
 #Create binary data set
  Bidat<-DataFilebi
  Bidat[, 1] <- as.numeric(DataFilebi[, 1] > 0)
  #Binomial GLM formulas   
  bifactors<-paste(names(Bidat)[2:length(Bidat)],collapse="+")
  biform<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),bifactors))
  #Binomial Glm
  GLMbi <- glm(biform,data=Bidat,family="binomial",maxit=100)
  #print(paste("Binomial gamma AIC:",GLMbi$aic))
  #print(paste("Binomial gamma Deviance:",GLMbi$deviance))
  #Calculate mean effects  
  bitemp<-0
  if (length(dummy.coef(GLMbi))>2)
     {
     for (i in 3:length(dummy.coef(GLMbi)))
        {
    bitemp[i-1]<-mean(dummy.coef(GLMbi)[[i]])
    }
    bifact<-sum(bitemp)
     }
  if (length(dummy.coef(GLMbi))==2)
     bifact<-0
  
  bisumcoeff<-dummy.coef(GLMbi)[[1]] + dummy.coef(GLMbi)[[2]] + bifact
  biindex<- exp(bisumcoeff)/(1+exp(bisumcoeff))
  
  #Gamma GLM
  #Replace zeros with NA in CPUE for log transformation
  #DataFilegam[,1]<-ifelse(DataFileErr[,1]>0,DataFileErr[,1],NA)
  formfact<-names(DataFileErr)[2]
  if (length(names(DataFileErr))>2)
     {
     for (j in 3:length(names(DataFileErr)))
        {
        formfact<-paste(cbind(formfact,names(DataFileErr)[j]),collapse="+")
    }
    gamfactors<-formfact
      }
   if (length(names(DataFileErr))==2)
       gamfactors<-formfact
  gamform<-as.formula(paste(paste(names(DataFileErr)[1],"~",collapse=NULL),gamfactors))
  GLMgam<-glm(gamform,data=nonOdatagam,family=Gamma(link=log),maxit=100)
  #print(paste("Gamma AIC:",GLMgam$aic))
  #print(paste("Gamma Deviance:",GLMgam$deviance))
  #plot(GLMlog)
  #biascorr <- GLMgam$deviance/GLMgam$df.residual/2     
  
  gamtemp<-0
    if (length(dummy.coef(GLMgam))>2)
     {
     for (i in 3:length(dummy.coef(GLMgam)))
        {
    gamtemp[i-1]<-mean(dummy.coef(GLMgam)[[i]])
    }
    gamfact<-sum(gamtemp)
     }
  if (length(dummy.coef(GLMgam))==2)
     gamfact<-0
  gamindex<-exp(dummy.coef(GLMgam)[[1]] + dummy.coef(GLMgam)[[2]] + gamfact)
  biindex<-biindex[names(gamindex)]
  deltagamindex<-cbind(biindex*gamindex)
  DeltaGamIndex<-c(1:length(levels(DataFileErr[,2])))*0
  dim(DeltaGamIndex)<-c(length(DeltaGamIndex),1)
  numrows<-levels(DataFilebi[,2])
  names(DeltaGamIndex)<-matrix(numrows,1)
  DeltaGamIndex[1:length(deltagamindex)]<-deltagamindex[,1]
  ord<-order(names(DeltaGamIndex))
  deltagamindex<-cbind(DeltaGamIndex[ord])
  deltagamindex<-cbind(as.numeric(deltagamindex))
}
#gamCPUEmix<-deltagammix(DataFileS_yrmoday,DataFileS_yrmoday)
#******************************************************************************************************************************

#*******************************************************************************************************************************
GeoAvgmix<-function(DataFileErr)
{
#Convert to factors for easy manipulation
 
 DataFileErr[,2]<-as.factor(DataFileErr[,2])
 
#Geometric average calculation
  yr<-as.numeric(levels(DataFileErr[,2]))
  geoavg<-0
  for (n in 1:length(yr))
     {
     y<-DataFileErr[,1]>0 & DataFileErr[,2]==yr[n]
     geoavg[n]<-exp(sum(log(DataFileErr[,1][y]))/table(DataFileErr[,2])[n])
     }
   geoavg<-ifelse(geoavg!=1,geoavg,0)
   geoavg<-cbind(geoavg)
}  
#**************************************************Bootstrapped Delta Lognormal Code************************************************
deltabootmix<-function(DataFilebi,DataFileErr,B,years,model)
{
FileSize<-dim(DataFileErr)
index<-FileSize[1]
BootIndex<-matrix(nrow=years,ncol=B)
Freqs<-table(DataFileErr[,2])
indexyears<-order(DataFileErr[,2])
cumyrcounts<-cumsum(Freqs)
#To resample the DataFileErr
for (i in 1:B)
{
  print(i)
  Bootrows<-sample(indexyears[1:cumyrcounts[1]],Freqs[1],replace=T)
  for (j in 2:years)
    {
      booti<-sample(indexyears[(cumyrcounts[j-1]+1):cumyrcounts[j]],Freqs[j],replace=T)
      Bootrows<-c(Bootrows,booti)
    }
  BootData<-Rows(DataFileErr,Bootrows)
  if (model==1)
  BtIndex<-deltalogmix(DataFilebi,BootData)
  if (model==2)
  BtIndex<-deltagammix(DataFilebi,BootData)
  tempindex<-as.data.frame(BtIndex)
  BootIndex[,i]<-tempindex[,1]
}
BootSE<-sd(t(BootIndex),na.rm = T)
cbind(BootSE)
}
#***********************************************************************************************************************************

#**********************************************************Full Analysis************************************************************
CPUEanalysismix<-function(DataFilebi,DataFileErr,B,years,model)
{
   CPUElogmix<-deltalogmix(DataFilebi,DataFileErr)
   colnames(CPUElogmix)<-"lognormal"
   CPUEgammix<-deltagammix(DataFilebi,DataFileErr)
   colnames(CPUEgammix)<-"gamma"
   Geoxbarmix<-GeoAvgmix(DataFileErr)
   BootStdevmix<-deltabootmix(DataFilebi,DataFileErr,B,years,model)
   CV1<-BootStdevmix/CPUElogmix
   CV2<-BootStdevmix/CPUEgammix
   if (model==1)
   CV<-CV1
   if(model==2)
   CV<-CV2
   colnames(CV)<-"CV"
   Year<-as.numeric(levels(as.factor(DataFileErr[,2])))
   CPUE<-cbind(Year,Geoxbarmix,CPUEgammix,CPUElogmix,BootStdevmix,CV)
}

#*********************************************General Delta Lognormal Code*********************************************************
 deltalog<-function(DataFile)
{
 #DataFile should be ordered as follows
  # Column 1: CPUE
  # Column 2: Year (always Factor 1)
  # Remaining columns: Additional factors
  #Create factors
  rownames(DataFile)<-c(1:nrow(DataFile)) #Ensures rows are consecutive numbers
  for (i in 2:ncol(DataFile))
    {
         DataFile[[i]] <- as.factor(DataFile[[i]])
     }
  #Create non-zero data set
  nonOdata <- DataFile[DataFile[,1]>0,]
  
  #Create weigth vector
  wt.vec = rep(1,nrow(DataFile))
  
  #Sort factor levels
  for (i in 2:ncol(DataFile)) 
    {
        DataFile[[i]] <- factor(DataFile[[i]], levels=(names(sort(table(nonOdata[[i]]),decreasing=T))))
    } 
  nonOdata <- DataFile[DataFile[,1]> 0,]
  #Create binary data set
  Bidat<-DataFile
  Bidat[, 1] <- as.numeric(DataFile[, 1] > 0)
  #Binomial GLM formulas   
  bifactors<-paste(names(Bidat)[2:length(Bidat)],collapse="+")
  biform<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),bifactors))
  #Binomial Glm
  GLMbi <- glm(biform,data=Bidat,family="binomial",maxit=100)
  print(paste("Binomial AIC:",GLMbi$aic))
  #print(paste("Binomial Deviance:",GLMbi$deviance))
  
  #Calculate mean effects  
  bitemp<-0
  if (length(dummy.coef(GLMbi))>2)
     {
     for (i in 3:length(dummy.coef(GLMbi)))
        {
    bitemp[i-1]<-mean(dummy.coef(GLMbi)[[i]])
    }
    bifact<-sum(bitemp)
     }
  if (length(dummy.coef(GLMbi))==2)
     bifact<-0
  bisumcoeff<-dummy.coef(GLMbi)[[1]] + dummy.coef(GLMbi)[[2]] + bifact
  biindex<- exp(bisumcoeff)/(1+exp(bisumcoeff))
  
  #Lognormal GLM
  formfact<-names(DataFile)[2]
  wts <- wt.vec[as.numeric(rownames(nonOdata))]
  if (length(names(DataFile))>2)
     {
     for (j in 3:length(names(DataFile)))
        {
        formfact<-paste(cbind(formfact,names(DataFile)[j]),collapse="+")
    }
    logfactors<-formfact
      }
   if (length(names(DataFile))==2)
       logfactors<-formfact
  logform<-as.formula(paste(paste("log(",(names(DataFile)[1]),")","~",collapse=NULL),logfactors))
  GLMlog<-glm(logform,data=nonOdata,weights=wts, family=gaussian,maxit=100)
  print(paste("Lognormal AIC:",GLMlog$aic))
  #print(paste("Lognormal Deviance:",GLMlog$deviance))
  #plot(GLMlog)
  biascorr <- GLMlog$deviance/GLMlog$df.residual/2     
  
  logtemp<-0
    if (length(dummy.coef(GLMlog))>2)
     {
     for (i in 3:length(dummy.coef(GLMlog)))
        {
    logtemp[i-1]<-mean(dummy.coef(GLMlog)[[i]])
    }
    logfact<-sum(logtemp)
     }
  if (length(dummy.coef(GLMlog))==2)
     logfact<-0
  logindex<-exp(dummy.coef(GLMlog)[[1]] + dummy.coef(GLMlog)[[2]] + logfact+biascorr)
  biindex<-biindex[names(logindex)]
  deltaindex<-cbind(biindex*logindex)
  DeltaIndex<-c(1:length(levels(DataFile[,2])))*0
  dim(DeltaIndex)<-c(length(DeltaIndex),1)
  numrows<-levels(DataFile[,2])
  names(DeltaIndex)<-matrix(numrows,1)
  DeltaIndex[1:length(deltaindex)]<-deltaindex[,1]
  ord<-order(names(DeltaIndex))
  deltaindex<-cbind(DeltaIndex[ord])
  deltalogindex<-cbind(as.numeric(deltaindex))
  }
#CPUElog<-deltalog(DataFile)
#***********************************************************************************************************************************

#***********************************************************************************************************************************
deltagam<-function(DataFile)
{
 #DataFile should be ordered as follows
  # Column 1: CPUE
  # Column 2: Binary form of CPUE
  # Column 3: Year (always Factor 1)
  # Remaining columns: Additional factors
  rownames(DataFile)<-c(1:nrow(DataFile)) #Ensures rows are consecutive numbers
  #Create factors
  for (i in 2:ncol(DataFile))
    {
         DataFile[[i]] <- as.factor(DataFile[[i]])
     }
  #Create non-zero data set
  nonOdata <- DataFile[DataFile[,1]>0,]
  
  #Create weigth vector
  wt.vec = rep(1,nrow(DataFile))
 
  #Sort factor levels
  for (i in 2:ncol(DataFile)) 
    {
        DataFile[[i]] <- factor(DataFile[[i]], levels=(names(sort(table(nonOdata[[i]]),decreasing=T))))
    } 
  nonOdata <- DataFile[DataFile[,1]> 0,]
  #Create binary data set
  Bidat<-DataFile
  Bidat[, 1] <- as.numeric(DataFile[, 1] > 0)
  #Binomial GLM formulas   
  bifactors<-paste(names(Bidat)[2:length(Bidat)],collapse="+")
  biform<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),bifactors))
  #Binomial Glm
  GLMbi <- glm(biform,data=Bidat,family="binomial",maxit=100)
  #print(paste("Binomial gamma AIC:",GLMbi$aic))
  #print(paste("Binomial gamma Deviance:",GLMbi$deviance))
  #Calculate mean effects  
  bitemp<-0
  if (length(dummy.coef(GLMbi))>2)
     {
     for (i in 3:length(dummy.coef(GLMbi)))
        {
    bitemp[i-1]<-mean(dummy.coef(GLMbi)[[i]])
    }
    bifact<-sum(bitemp)
     }
  if (length(dummy.coef(GLMbi))==2)
     bifact<-0
  
  bisumcoeff<-dummy.coef(GLMbi)[[1]] + dummy.coef(GLMbi)[[2]] + bifact
  biindex<- exp(bisumcoeff)/(1+exp(bisumcoeff))
  
  #Gamma GLM
  #Replace zeros with NA in CPUE for log transformation
  #DataFile[,1]<-ifelse(DataFile[,1]>0,DataFile[,1],NA)
  formfact<-names(DataFile)[2]
  wts <- wt.vec[as.numeric(rownames(nonOdata))]  
  if (length(names(DataFile))>2)
     {
     for (j in 3:length(names(DataFile)))
        {
        formfact<-paste(cbind(formfact,names(DataFile)[j]),collapse="+")
    }
    gamfactors<-formfact
      }
   if (length(names(DataFile))==2)
       gamfactors<-formfact
  gamform<-as.formula(paste(paste(names(DataFile)[1],"~",collapse=NULL),gamfactors))
  GLMgam<-glm(gamform,data=nonOdata,weights=wts,family=Gamma(link=log),maxit=100)
  #print(paste("Gamma AIC:",GLMgam$aic))
  #print(paste("Gamma Deviance:",GLMgam$deviance))
  #plot(GLMlog)
  #biascorr <- GLMgam$deviance/GLMgam$df.residual/2     
  
  gamtemp<-0
    if (length(dummy.coef(GLMgam))>2)
     {
     for (i in 3:length(dummy.coef(GLMgam)))
        {
    gamtemp[i-1]<-mean(dummy.coef(GLMgam)[[i]])
    }
    gamfact<-sum(gamtemp)
     }
  if (length(dummy.coef(GLMgam))==2)
     gamfact<-0
  gamindex<-exp(dummy.coef(GLMgam)[[1]] + dummy.coef(GLMgam)[[2]] + gamfact)
  biindex<-biindex[names(gamindex)]
  deltagamindex<-cbind(biindex*gamindex)
  DeltaGamIndex<-c(1:length(levels(DataFile[,2])))*0
  dim(DeltaGamIndex)<-c(length(DeltaGamIndex),1)
  numrows<-levels(DataFile[,2])
  names(DeltaGamIndex)<-matrix(numrows,1)
  DeltaGamIndex[1:length(deltagamindex)]<-deltagamindex[,1]
  ord<-order(names(DeltaGamIndex))
  deltagamindex<-cbind(DeltaGamIndex[ord])
  deltagamindex<-cbind(as.numeric(deltagamindex))
}
#gamCPUE<-deltagam(DataFile)
#******************************************************************************************************************************

#*******************************************************************************************************************************
GeoAvg<-function(DataFile)
{
#Convert to factors for easy manipulation
 
 DataFile$SurveyYear<-as.factor(DataFile$SurveyYear)
 
#Geometric average calculation
  yr<-as.numeric(levels(DataFile$SurveyYear))
  geoavg<-0
  for (n in 1:length(yr))
     {
     y<-DataFile[,1]>0 & DataFile[,2]==yr[n]
     geoavg[n]<-exp(sum(log(DataFile[,1][y]))/table(DataFile[,2])[n])
     }
   geoavg<-ifelse(geoavg!=1,geoavg,0)
   geoavg<-cbind(geoavg)
}  
# Geoxbar<-GeoAvg(DataFile)
# CPUE<-cbind(as.numeric(levels(as.factor(DataFile[,2]))),Geoxbar,CPUElog)
#**************************************************Bootstrapped Delta Lognormal Code************************************************
deltaboot<-function(DataFile,B,years,model)
{
FileSize<-dim(DataFile)
index<-FileSize[1]
BootIndex<-matrix(nrow=years,ncol=B)
Freqs<-table(DataFile[,2])
indexyears<-order(DataFile[,2])
cumyrcounts<-cumsum(Freqs)
#To resample the DataFile
for (i in 1:B)
{
  print(i)
  Bootrows<-sample(indexyears[1:cumyrcounts[1]],Freqs[1],replace=T)
  for (j in 2:years)
    {
      booti<-sample(indexyears[(cumyrcounts[j-1]+1):cumyrcounts[j]],Freqs[j],replace=T)
      Bootrows<-c(Bootrows,booti)
    }
  BootData<-Rows(DataFile,Bootrows)
  if (model==1)
  BtIndex<-deltalog(BootData)
  else BtIndex<-deltagam(BootData)
  tempindex<-as.data.frame(BtIndex)
  BootIndex[,i]<-tempindex[,1]
}
BootSE<-sd(t(BootIndex),na.rm = T)
cbind(BootSE)
}
#BootStdev<-deltaboot(DataFile,5,length(CPUElog))
#CPUE<-cbind(CPUE,BootStdev)

deltaboot.EJ<-function(DataFile,B,years,model,types.in)
{
FileSize<-dim(DataFile)
index<-FileSize[1]
BootIndex<-matrix(nrow=years,ncol=B)
Freqs<-table(DataFile[,2])
indexyears<-order(DataFile[,2])
cumyrcounts<-cumsum(Freqs)
#types.in<-c("C",rep("F",(FileSize[2]-1)))
#To resample the DataFile
for (i in 1:B)
{
  print(i)
  Bootrows<-sample(indexyears[1:cumyrcounts[1]],Freqs[1],replace=T)
  for (j in 2:years)
    {
      booti<-sample(indexyears[(cumyrcounts[j-1]+1):cumyrcounts[j]],Freqs[j],replace=T)
      Bootrows<-c(Bootrows,booti)
    }
  BootData<-Rows(DataFile,Bootrows)
  if (model==1)
  #BtIndex<-deltalog(BootData)
  BtIndex<-deltaglm(BootData, dist="lognormal",types=types.in)$deltaGLM.index[,1]
  #else BtIndex<-deltagam(BootData)
  else BtIndex<-deltaglm(BootData, dist="gamma",types=types.in)$deltaGLM.index[,1]
  #tempindex<-as.data.frame()
  BootIndex[,i]<-BtIndex
}
BootSE<-apply(BootIndex,1,sd,na.rm = T)
cbind(BootSE)
}

#***********************************************************************************************************************************

#**********************************************************Full Analysis************************************************************
CPUEanalysis<-function(DataFile,B,years,model)
{
#   rownames(DataFile)<-c(1:nrow(DataFile)) #Ensures rows are consecutive numbers
   CPUElog<-deltalog(DataFile)
#   CPUElog<-deltalogII(DataFile)
   colnames(CPUElog)<-"lognormal"
   CPUEgam<-deltagam(DataFile)
   colnames(CPUEgam)<-"gamma"
   Geoxbar<-GeoAvg(DataFile)
   BootStdev<-deltaboot(DataFile,B,years,model)
   CV1<-BootStdev/CPUElog
   CV2<-BootStdev/CPUEgam
   if (model==1)
   CV<-CV1
   else CV<-CV2
   colnames(CV)<-"CV"
   Year<-as.numeric(levels(as.factor(DataFile[,2])))
   CPUE<-cbind(Year,Geoxbar,CPUEgam,CPUElog,BootStdev,CV)
}

CPUEanalysis.EJ<-function(DataFile,B,years,model,types.in=c("C","F",rep("F",ncol(DataFile)-2)),plotting=1,plotID.in,J.in=FALSE)
{
#   rownames(DataFile)<-c(1:nrow(DataFile)) #Ensures rows are consecutive numbers
   Year<-as.numeric(levels(as.factor(DataFile$SurveyYear)))
   print("Lognormal diagnostics plots")
   CPUElogmodel<-deltaglm(DataFile, dist="lognormal", J=J.in,types=types.in,plot.diags=plotting,plotID=plotID.in)
   CPUElog<-as.data.frame(CPUElogmodel$deltaGLM.index[,1])
   colnames(CPUElog)<-"lognormal"
   print("Gamma diagnostics plots")
   CPUEgammodel<-deltaglm(DataFile, dist="gamma", J=J.in,types=types.in,plot.diags=plotting,plotID=plotID.in)
   CPUEgam<-as.data.frame(CPUEgammodel$deltaGLM.index[,1])
   colnames(CPUEgam)<-"gamma"
   Geoxbar<-GeoAvg(DataFile)
   if(B>0)
   {
   BootStdev<-deltaboot.EJ(DataFile,B,years,model,types.in)
   CV1<-BootStdev/CPUElog
   CV2<-BootStdev/CPUEgam
   if (model==1)
   {
     CV<-CV1
     model.out<-CPUElog
   }
   else 
     {
       CV<-CV2
      model.out<-CPUEgam
     }
   colnames(CV)<-"CV"
   CPUE<-cbind(Year,Geoxbar,CPUEgam,CPUElog,BootStdev,CV)
   }
   else CPUE<-cbind(Year,Geoxbar,CPUEgam,CPUElog)
   results.out<-list(CPUE,CPUElogmodel,CPUEgammodel)
   names(results.out)<-c("Index table","LogN Model","Gamma model")
   return(results.out)
}

#######################################*************************#########################################
#######################################LOAD MODEL SELECTION CODE#########################################
#######################################*************************#########################################
#*********************************************Delta GLM code for model selection*********************************************************
 deltaglmselect<-function(DataFile, outfile)
{
 #DataFile should be ordered as follows
  # Column 1: CPUE
  # Column 2: Binary form of CPUE
  # Column 3: Year (always Factor 1)
  # Remaining columns: Additional factors
  #Create factors
  for (i in 2:ncol(DataFile)) 
    {
         DataFile[[i]] <- as.factor(DataFile[[i]])
     }
  #Create non-zero data set
  nonOdata <- DataFile[DataFile[,1]>0,]
  #Create weigth vector
  wt.vec = rep(1,nrow(DataFile))
  
  #Sort factor levels
  for (i in 2:ncol(DataFile)) 
    {
        DataFile[[i]] <- factor(DataFile[[i]], levels=(names(sort(table(nonOdata[[i]]),decreasing=T))))
    } 
  nonOdata <- DataFile[DataFile[,1]> 0,]
  #Create binary data set
  Bidat<-DataFile
  Bidat[, 1] <- as.numeric(DataFile[, 1] > 0)
  #Binomial GLM formulas   
  bifactors<-paste(names(Bidat)[2:length(Bidat)],collapse="+")
  biform<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),bifactors))
  #Binomial Glm
  GLMbi <- glm(biform,data=Bidat,family="binomial",maxit=100)
  print(paste("Binomial AIC:",GLMbi$aic))
  print(paste("Binomial Deviance:",GLMbi$deviance))
  #Calculate mean effects  
  bitemp<-0
  if (length(dummy.coef(GLMbi))>2)
     {
     for (i in 3:length(dummy.coef(GLMbi)))
        {
    bitemp[i-1]<-mean(dummy.coef(GLMbi)[[i]])
    }
    bifact<-sum(bitemp)
     }
  if (length(dummy.coef(GLMbi))==2)
     bifact<-0
  bisumcoeff<-dummy.coef(GLMbi)[[1]] + dummy.coef(GLMbi)[[2]] + bifact
  biindex<- exp(bisumcoeff)/(1+exp(bisumcoeff))
  
  #Lognormal GLM
  formfact<-names(DataFile)[2]
  wts <- wt.vec[as.numeric(rownames(nonOdata))]
  if (length(names(DataFile))>2)
     {
     for (j in 3:length(names(DataFile)))
        {
        formfact<-paste(cbind(formfact,names(DataFile)[j]),collapse="+")
    }
    logfactors<-formfact
      }
   if (length(names(DataFile))==2)
       logfactors<-formfact
  logform<-as.formula(paste(paste("log(",(names(DataFile)[1]),")","~",collapse=NULL),logfactors))
  GLMlog<-glm(logform,data=nonOdata,weights=wts,family=gaussian,maxit=100)
  print(paste("Lognormal AIC:",GLMlog$aic))
  print(paste("Lognormal Deviance:",GLMlog$deviance))
  #plot(GLMlog)
  biascorr <- GLMlog$deviance/GLMlog$df.residual/2     
  
  logtemp<-0
    if (length(dummy.coef(GLMlog))>2)
     {
     for (i in 3:length(dummy.coef(GLMlog)))
        {
    logtemp[i-1]<-mean(dummy.coef(GLMlog)[[i]])
    }
    logfact<-sum(logtemp)
     }
  if (length(dummy.coef(GLMlog))==2)
     logfact<-0
  logindex<-exp(dummy.coef(GLMlog)[[1]] + dummy.coef(GLMlog)[[2]] + logfact+biascorr)
  biindex<-biindex[names(logindex)]
  deltaindex<-cbind(biindex*logindex)
  DeltaIndex<-c(1:length(levels(DataFile[,2])))*0
  dim(DeltaIndex)<-c(length(DeltaIndex),1)
  numrows<-levels(DataFile[,2])
  names(DeltaIndex)<-matrix(numrows,1)
  DeltaIndex[1:length(deltaindex)]<-deltaindex[,1]
  ord<-order(names(DeltaIndex))
  deltaindex<-cbind(DeltaIndex[ord])
  deltalogindex<-cbind(as.numeric(deltaindex))

  #Gamma GLM
  #Replace zeros with NA in CPUE for log transformation
  #DataFile[,1]<-ifelse(DataFile[,1]>0,DataFile[,1],NA)
  gamfactors<-formfact
  gamform<-as.formula(paste(paste(names(DataFile)[1],"~",collapse=NULL),gamfactors))
  GLMgam<-glm(gamform,data=nonOdata,family=Gamma(link=log),maxit=100)
  print(paste("Gamma AIC:",GLMgam$aic))
  print(paste("Gamma Deviance:",GLMgam$deviance))
  #plot(GLMlog)
  #biascorr <- GLMgam$deviance/GLMgam$df.residual/2     
  
  gamtemp<-0
    if (length(dummy.coef(GLMgam))>2)
     {
     for (i in 3:length(dummy.coef(GLMgam)))
        {
    gamtemp[i-1]<-mean(dummy.coef(GLMgam)[[i]])
    }
    gamfact<-sum(gamtemp)
     }
  if (length(dummy.coef(GLMgam))==2)
     gamfact<-0
  gamindex<-exp(dummy.coef(GLMgam)[[1]] + dummy.coef(GLMgam)[[2]] + gamfact)
  biindex<-biindex[names(gamindex)]
  deltagamindex<-cbind(biindex*gamindex)
  DeltaGamIndex<-c(1:length(levels(DataFile[,2])))*0
  dim(DeltaGamIndex)<-c(length(DeltaGamIndex),1)
  numrows<-levels(DataFile[,2])
  names(DeltaGamIndex)<-matrix(numrows,1)
  DeltaGamIndex[1:length(deltagamindex)]<-deltagamindex[,1]
  ord<-order(names(DeltaGamIndex))
  deltagamindex<-cbind(DeltaGamIndex[ord])
  deltagamindex<-cbind(as.numeric(deltagamindex))

  #Write output to desktop
  write(paste("Binomial AIC:",GLMbi$aic),outfile,append=TRUE)
  write(paste("Lognormal AIC:", GLMlog$aic),outfile,append=TRUE)
  write(paste("Gamma AIC:",GLMgam$aic),outfile,append=TRUE)
  write(paste("Binomial Deviance:",GLMbi$deviance),outfile,append=TRUE)
  write(paste("Lognormal Deviance:",GLMlog$deviance),outfile,append=TRUE)
  write(paste("Gamma Deviance:",GLMgam$deviance),outfile,append=TRUE)
  write("NEXT MODEL...",outfile,append=TRUE)
}
#deltaglmselect(cab.cpue.NorCAL,"C:\\GLMoutput.csv")

deltaglmselect.EJ<-function(DataFile, outfile)
{

  lognormal.op<-deltaglm(DataFile, dist="lognormal")
  gamma.op<-deltaglm(DataFile, dist="gamma")
  #Write output to desktop
  write(paste("MODEL FORMULA:",unlist(strsplit(lognormal.op$bi,":"))[2],sep=""),outfile,append=TRUE)
  write(paste("Binomial AIC:",gamma.op$aic[1]),outfile,append=TRUE)
  write(paste("Lognormal AIC:", lognormal.op$aic[2]),outfile,append=TRUE)
  write(paste("Gamma AIC:",gamma.op$aic[2]),outfile,append=TRUE)
  write("NEXT MODEL...",outfile,append=TRUE)
}

####
#Index_type: Name given to output
mod_sel_CPUE<-function(DataFile, Index_type)
{
 #DataFile should be ordered as follows
  # Column 1: CPUE
  # Column 2: Year (always Factor 1)
  # Remaining columns: Additional factors
  #Create factors
  for (i in 2:ncol(DataFile)) 
    {
         DataFile[[i]] <- as.factor(DataFile[[i]])
     }
  #Create non-zero data set
  nonOdata <- DataFile[DataFile[,1]>0,]
  
  #Create weigth vector
  wt.vec = rep(1,nrow(DataFile))
  
  #Sort factor levels
  for (i in 2:ncol(DataFile)) 
    {
        DataFile[[i]] <- factor(DataFile[[i]], levels=(names(sort(table(nonOdata[[i]]),decreasing=T))))
    } 
  nonOdata <- DataFile[DataFile[,1]> 0,]
  GLM.step<-list()
  
  #Create binary data set
  Bidat<-DataFile
  Bidat[, 1] <- as.numeric(DataFile[, 1] > 0)
  #Binomial GLM formulas   
  bifactors<-paste(names(Bidat)[2:length(Bidat)],collapse="+")
  biform<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),bifactors))
  #Binomial Glm
  GLMbi <- glm(biform,data=Bidat,family="binomial",maxit=100)
  biform.min<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),names(Bidat)[2])) 
 # print("***************************************************************************************")
 # print("BINOMIAL Model Selection")
 # print("***************************************************************************************")
 # print("")
  GLMbi.step <-  stepAIC_delta(GLMbi,"BINOMIAL", scope= list(upper = biform, lower = biform.min), scale = 0, direction = c("both"), trace = 1, keep = NULL, steps = 1000, use.start = FALSE, k = 2) 
  GLM.step[[1]]<-GLMbi.step

  #Lognormal GLM
  formfact<-names(DataFile)[2]
  wts <- wt.vec[as.numeric(rownames(nonOdata))]
  if (length(names(DataFile))>2)
     {
     for (j in 3:length(names(DataFile)))
        {
        formfact<-paste(cbind(formfact,names(DataFile)[j]),collapse="+")
    }
    logfactors<-formfact
      }
   if (length(names(DataFile))==2)
       logfactors<-formfact
  logform<-as.formula(paste(paste("log(",(names(DataFile)[1]),")","~",collapse=NULL),logfactors))
  GLMlog<-glm(logform,data=nonOdata,weights=wts, family=gaussian,maxit=100)
  logform.min<-as.formula(paste(paste("log(",(names(DataFile)[1]),")","~",collapse=NULL),names(nonOdata)[2])) 
#  print("")
#  print("***************************************************************************************")
#  print("LOGNORMAL Model Selection")
#  print("***************************************************************************************")
#  print("")
  GLMlog.step <-  stepAIC_delta(GLMlog, "LOGNORMAL", scope= list(upper = logform, lower = logform.min), scale = 0, direction = c("both"), trace = 1, keep = NULL, steps = 1000, use.start = FALSE, k = 2)  
  GLM.step[[2]]<-GLMlog.step
 
   #Gamma GLM
  #Replace zeros with NA in CPUE for log transformation
  #DataFile[,1]<-ifelse(DataFile[,1]>0,DataFile[,1],NA)
  gamfactors<-formfact
  gamform<-as.formula(paste(paste(names(DataFile)[1],"~",collapse=NULL),gamfactors))
  GLMgam<-glm(gamform,data=nonOdata,weights=wts,family=Gamma(link=log),maxit=100)
  gamform.min<-as.formula(paste(paste(names(DataFile)[1],"~",collapse=NULL),names(nonOdata)[2])) 
#  print("")
#  print("***************************************************************************************")
#  print("GAMMA Model Selection")
#  print("***************************************************************************************")
  GLMgam.step <-  stepAIC_delta(GLMgam,"GAMMA", scope= list(upper = gamform, lower = gamform.min), scale = 0, direction = c("both"), trace = 1, keep = NULL, steps = 1000, use.start = FALSE, k = 2)  
  GLM.step[[3]]<-GLMgam.step

  bi_tabs<-(length(names(GLM.step[[1]]))-1)
  log_tabs<-(length(names(GLM.step[[2]]))-1)
  gam_tabs<-(length(names(GLM.step[[3]]))-1)

  GLM.bi<-unname(GLM.step[[1]])
  GLM.log<-unname(GLM.step[[2]])
  GLM.gam<-unname(GLM.step[[3]])

 write(Index_type,file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""))
 write(paste("DATE/TIME (PST): ",as.character(Sys.time()), sep=""),file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""),append=TRUE)
 write("",file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""),append=TRUE)
 write(GLM.bi[[1]],file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""),append=TRUE) 
    for (i in seq(2,bi_tabs, by=2))
    {
    write(GLM.bi[[i]],file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""),append=TRUE) 
    write.table(cbind(GLM.bi[[i+1]],paste(":",rownames(GLM.bi[[i+1]]),sep="")),file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""), sep=",", na="",row.names=FALSE,append=TRUE) 
    }

 write("",file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""),append=TRUE)
 
 write(GLM.log[[1]],file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""),append=TRUE) 
    for (j in seq(2,log_tabs,by=2))
    {
    write(GLM.log[[j]],file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""),append=TRUE) 
    write.table(cbind(GLM.log[[j+1]],paste(":",rownames(GLM.bi[[j+1]]),sep="")),file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""), sep=",", na=" ",row.names=FALSE,append=TRUE) 
    }

 write("",file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""),append=TRUE)
 
 write(GLM.gam[[1]],file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""),append=TRUE) 
    for (k in seq(2,gam_tabs, by=2)){
    write(GLM.gam[[k]],file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""),append=TRUE) 
    write.table(cbind(GLM.gam[[k+1]],paste(":",rownames(GLM.bi[[k+1]]),sep="")),file=paste("C:\\Dissertation\\CH_2_CPUE_Indices\\CPUE_output\\",Index_type,".csv", sep=""), sep=",",na=" ", row.names=FALSE,append=TRUE) 
    }
  return(GLM.step)
}

###############################DELTA LOGNORMAL##################################################################
 deltalog.step<-function(DataFile,print.q="Y")
{
 #DataFile should be ordered as follows
  # Column 1: CPUE
  # Column 2: Year (always Factor 1)
  # Remaining columns: Additional factors
  #Create factors
  nonOdata<-DataFile[DataFile[,1]>0,] #do this to get correct levels for non-zero data 
    ch.fac<-0
    nozero.fac<-0
  for (i in 2:ncol(DataFile)) 
    {
         DataFile[[i]] <- as.factor(DataFile[[i]])
         nonOdata[[i]]<- as.factor(nonOdata[[i]])
         ch.fac[i]<-nlevels(DataFile[,i])
         nozero.fac[i]<-nlevels(nonOdata[,i])
     }
  #Create non-zero data set
  nonOdata <- DataFile[DataFile[,1]>0,]
  
  #Check for only 1 factor level
  bad.i<-0
  bad.i0<-0
  for(jj in 2:length(DataFile))
  {
  if(length(levels((DataFile)[[jj]]))==1)
  {bad.i[jj]<-jj}
  if(length(levels((nonOdata)[[jj]]))==1)
  {bad.i0[jj]<-jj}
  }
  if(sum(bad.i)>0)
  {bad.i<-bad.i[-1]
  DataFile[[-bad.i]]}  
  if(sum(bad.i)>0)
  {bad.i<-bad.i[-1]
  nonOdata[[-bad.i]]
  }  
  
  fac.lev<-0
  #for (p in 2:length(DataFile))
  #{
  #ch.fac[p]<-nlevels(DataFile[,p])
  #nozero.fac[p]<-nlevels(nonOdata[,p])
  #}
  ch.fac<-ch.fac[-1]
  nozero.fac<-nozero.fac[-1]
  fac.lev<-c(ch.fac,nozero.fac)
  T.lev<-fac.lev>1
  T.lev[T.lev=="TRUE"]<-1

  if (sum(T.lev)==length(T.lev) & (length(nonOdata[,1])/max(nozero.fac))>1)
  {

  #Create weigth vector
  wt.vec = rep(1,nrow(DataFile))
  
  #Sort factor levels
  for (i in 2:ncol(DataFile)) 
    {
        DataFile[[i]] <- factor(DataFile[[i]], levels=(names(sort(table(nonOdata[[i]]),decreasing=T))))
    } 
  
  nonOdata <- DataFile[DataFile[,1]> 0,]
   
  ######Create binary data set#####
  Bidat<-DataFile
  Bidat[, 1] <- as.numeric(DataFile[, 1] > 0)
  bifactors<-paste(names(Bidat)[2:length(Bidat)],collapse="+")
  biform<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),bifactors))
  #Binomial Glm
  GLMbi <- glm(biform,data=Bidat,family="binomial",maxit=100)
  biform.min<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),names(Bidat)[2])) 
  GLMbi.step <- stepAIC(GLMbi, scope= list(upper = biform, lower = biform.min), scale = 0, direction = c("both"), trace = FALSE, keep = NULL, steps = 1000, use.start = FALSE, k = 2) 
  if(print.q=="Y")
  {print(GLMbi.step$formula)}
  #Calculate mean effects  
  bitemp<-0
  if (length(dummy.coef(GLMbi.step))>2)
     {
     for (i in 3:length(dummy.coef(GLMbi.step)))
        {
        bitemp[i-1]<-mean(dummy.coef(GLMbi.step)[[i]])
        }
    bifact<-sum(bitemp)
     }
  if (length(dummy.coef(GLMbi.step))==2)
     bifact<-0
  bisumcoeff<-dummy.coef(GLMbi.step)[[1]] + dummy.coef(GLMbi.step)[[2]] + bifact
  biindex<- exp(bisumcoeff)/(1+exp(bisumcoeff))
  
  #Lognormal GLM
  formfact<-names(DataFile)[2]
  wts <- wt.vec[as.numeric(rownames(nonOdata))]
  if (length(names(DataFile))>2)
  {
        for (j in 3:length(names(DataFile)))
        {
        formfact<-paste(cbind(formfact,names(DataFile)[j]),collapse="+")
        }
    logfactors<-formfact
  }
   if (length(names(DataFile))==2)
       {logfactors<-formfact}
    logform<-as.formula(paste(paste("log(",(names(DataFile)[1]),")","~",collapse=NULL),logfactors))
  GLMlog<-glm(logform,data=nonOdata,weights=wts, family=gaussian,maxit=100)
  logform.min<-as.formula(paste(paste("log(",(names(DataFile)[1]),")","~",collapse=NULL),names(nonOdata)[2])) 
  GLMlog.step <- stepAIC(GLMlog, scope= list(upper = logform, lower = logform.min), scale = 0, direction = c("both"), trace = FALSE, keep = NULL, steps = 1000, use.start = FALSE, k = 2)  
  if(print.q=="Y")
  {print(GLMlog.step$formula)}
  biascorr <- GLMlog.step$deviance/GLMlog.step$df.residual/2     
  logtemp<-0
    if (length(dummy.coef(GLMlog.step))>2)
        {
        for (i in 3:length(dummy.coef(GLMlog.step)))
        {
    logtemp[i-1]<-mean(dummy.coef(GLMlog.step)[[i]])
    }
    logfact<-sum(logtemp)
    }
  if (length(dummy.coef(GLMlog.step))==2)
     logfact<-0
  logindex<-exp(dummy.coef(GLMlog.step)[[1]] + dummy.coef(GLMlog.step)[[2]] + logfact+biascorr)
  biindex<-biindex[names(logindex)]
  deltaindex<-cbind(biindex*logindex)
  DeltaIndex<-c(1:length(levels(DataFile[,2])))*0
  dim(DeltaIndex)<-c(length(DeltaIndex),1)
  numrows<-levels(DataFile[,2])
  names(DeltaIndex)<-matrix(numrows,1)
  DeltaIndex[1:length(deltaindex)]<-deltaindex[,1]
  ord<-order(names(DeltaIndex))
  deltaindex<-cbind(DeltaIndex[ord])
  deltalogindex<-cbind(as.numeric(deltaindex))
  return(deltaindex)
  }
  else
  deltaindex<-NA
  }

#deltalog.step(DataFile)


##########################################DELTA GAMMA##################################################################

deltagam.step<-function(DataFile,print.q="Y")
{
 #DataFile should be ordered as follows
  # Column 1: CPUE
  # Column 2: Year (always Factor 1)
  # Remaining columns: Additional factors
  #Create factors
  nonOdata <- DataFile[DataFile[,1]>0,]
  ch.fac<-0
  nozero.fac<-0
   for (i in 2:ncol(DataFile)) 
        {
         DataFile[[i]] <- as.factor(DataFile[[i]])
         nonOdata[[i]] <- as.factor(nonOdata[[i]])
         ch.fac[p]<-nlevels(DataFile[,p])
         nozero.fac[p]<-nlevels(nonOdata[,p])
        }
  #Create non-zero data set
  nonOdata <- DataFile[DataFile[,1]>0,]
  
  #Check for only 1 factor level
  bad.i<-0
  bad.i0<-0
  for(jj in 2:length(DataFile))
  {
  if(length(levels((DataFile)[[jj]]))==1)
  {bad.i[jj]<-jj}
  if(length(levels((nonOdata)[[jj]]))==1)
  {bad.i0[jj]<-jj}
  }
  if(sum(bad.i)>0)
  {bad.i<-bad.i[-1]
  DataFile[[-bad.i]]}  
  if(sum(bad.i)>0)
  {bad.i<-bad.i[-1]
  nonOdata[[-bad.i]]}  
  
  fac.lev<-0
  ch.fac<-ch.fac[-1]
  nozero.fac<-nozero.fac[-1]
  fac.lev<-c(ch.fac,nozero.fac)
  T.lev<-fac.lev>1
  T.lev[T.lev=="TRUE"]<-1

  if (sum(T.lev)==length(T.lev) & (length(nonOdata[,1])/max(nozero.fac))>1)
  {

  #Create weigth vector
  wt.vec = rep(1,nrow(DataFile))
  
  #Sort factor levels
  for (i in 2:ncol(DataFile)) 
    {
        DataFile[[i]] <- factor(DataFile[[i]], levels=(names(sort(table(nonOdata[[i]]),decreasing=T))))
    } 
  
  nonOdata <- DataFile[DataFile[,1]> 0,]
   
  ######Create binary data set#####
  Bidat<-DataFile
  Bidat[, 1] <- as.numeric(DataFile[, 1] > 0)
  bifactors<-paste(names(Bidat)[2:length(Bidat)],collapse="+")
  biform<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),bifactors))
  #Binomial Glm
  GLMbi <- glm(biform,data=Bidat,family="binomial",maxit=100)
  biform.min<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),names(Bidat)[2])) 
  GLMbi.step <- stepAIC(GLMbi, scope= list(upper = biform, lower = biform.min), scale = 0, direction = c("both"), trace = FALSE, keep = NULL, steps = 1000, use.start = FALSE, k = 2) 
  if(print.q=="Y")
  {print(GLMbi.step$formula)}
 
  #Calculate mean effects  
  bitemp<-0
  if (length(dummy.coef(GLMbi.step))>2)
        {
        for (i in 3:length(dummy.coef(GLMbi.step)))
        {
    bitemp[i-1]<-mean(dummy.coef(GLMbi.step)[[i]])
        }
        bifact<-sum(bitemp)
        }
  if (length(dummy.coef(GLMbi.step))==2)
     bifact<-0
  
  bisumcoeff<-dummy.coef(GLMbi.step)[[1]] + dummy.coef(GLMbi.step)[[2]] + bifact
  biindex<- exp(bisumcoeff)/(1+exp(bisumcoeff))
  
  #Gamma GLM
  #Replace zeros with NA in CPUE for log transformation
  #DataFile[,1]<-ifelse(DataFile[,1]>0,DataFile[,1],NA)
  formfact<-names(DataFile)[2]
  wts <- wt.vec[as.numeric(rownames(nonOdata))]  
  if (length(names(DataFile))>2)
     {
     for (j in 3:length(names(DataFile)))
        {
        formfact<-paste(cbind(formfact,names(DataFile)[j]),collapse="+")
        }
        gamfactors<-formfact
     }
   if (length(names(DataFile))==2)
        {gamfactors<-formfact}
  gamform<-as.formula(paste(paste(names(DataFile)[1],"~",collapse=NULL),gamfactors))
  GLMgam<-glm(gamform,data=nonOdata,weights=wts,family=Gamma(link=log),maxit=100)
  gamform.min<-as.formula(paste(paste("log(",(names(DataFile)[1]),")","~",collapse=NULL),names(nonOdata)[2])) 
  GLMgam.step <- stepAIC(GLMgam, scope= list(upper = gamform, lower = gamform.min), scale = 0, direction = c("both"), trace = 1, keep = NULL, steps = 1000, use.start = FALSE, k = 2)  
  if(print.q=="Y")
  {print(GLMgam.step$formula)}
  
  gamtemp<-0
    if (length(dummy.coef(GLMgam.step))>2)
        {
        for (i in 3:length(dummy.coef(GLMgam.step)))
        {
    gamtemp[i-1]<-mean(dummy.coef(GLMgam.step)[[i]])
        }
        gamfact<-sum(gamtemp)
        }
  if (length(dummy.coef(GLMgam.step))==2)
     gamfact<-0
  gamindex<-exp(dummy.coef(GLMgam.step)[[1]] + dummy.coef(GLMgam.step)[[2]] + gamfact)
  biindex<-biindex[names(gamindex)]
  deltagamindex<-cbind(biindex*gamindex)
  DeltaGamIndex<-c(1:length(levels(DataFile[,2])))*0
  dim(DeltaGamIndex)<-c(length(DeltaGamIndex),1)
  numrows<-levels(DataFile[,2])
  names(DeltaGamIndex)<-matrix(numrows,1)
  DeltaGamIndex[1:length(deltagamindex)]<-deltagamindex[,1]
  ord<-order(names(DeltaGamIndex))
  deltagamindex<-cbind(DeltaGamIndex[ord])
  deltagamindex<-cbind(as.numeric(deltagamindex))
}
  else
  deltaindex<-NA
}

#deltagam.cpue(DataFile)

########################
#################
 deltalog.interactions<-function(DataFile)
{
 #DataFile should be ordered as follows
  # Column 1: CPUE
  # Column 2: Year (always Factor 1)
  # Remaining columns: Additional factors
  #Create factors
  for (i in 2:ncol(DataFile)) 
    {
         DataFile[[i]] <- as.factor(DataFile[[i]])
     }
  #Create non-zero data set
  nonOdata <- DataFile[DataFile[,1]>0,]
  
  #Create weigth vector
  wt.vec = rep(1,nrow(DataFile))
  
  #Sort factor levels
  for (i in 2:ncol(DataFile)) 
    {
        DataFile[[i]] <- factor(DataFile[[i]], levels=(names(sort(table(nonOdata[[i]]),decreasing=T))))
    } 
  nonOdata <- DataFile[DataFile[,1]> 0,]
  #Create binary data set
  Bidat<-DataFile
  Bidat[, 1] <- as.numeric(DataFile[,1] > 0)
  #Binomial GLM formulas
  bifactors<-paste(names(Bidat)[2:length(Bidat)],collapse="+")
  bifactors<-paste(bifactors,paste("+",names(Bidat)[2],":",names(Bidat)[length(Bidat)],collapse=NULL))
  biform<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),bifactors))
  #Binomial Glm
  GLMbi <- glm(biform,data=Bidat,family="binomial",maxit=100)
  print(summary(GLMbi))
  print(paste("Binomial AIC:",GLMbi$aic))
  
  #Lognormal GLM
  formfact<-names(DataFile)[2]
  wts <- wt.vec[as.numeric(rownames(nonOdata))]
  if (length(names(DataFile))>2)
     {
     for (j in 3:length(names(DataFile)))
        {
        formfact<-paste(cbind(formfact,names(DataFile)[j]),collapse="+")
    }
    logfactors<-formfact
      }
   if (length(names(DataFile))==2)
       logfactors<-formfact
  logfactors<-paste(logfactors,paste("+",names(DataFile)[2],":",names(DataFile)[length(DataFile)],collapse=NULL))
  logform<-as.formula(paste(paste("log(",(names(DataFile)[1]),")","~",collapse=NULL),logfactors))
  GLMlog<-glm(logform,data=nonOdata,weights=wts, family=gaussian,maxit=100)
  print(summary(GLMlog))
  print(paste("Lognormal AIC:",GLMlog$aic))
  }
#
#deltalog.interactions(cab.cpue.NorCAL)


#**************************************************Bootstrapped Delta Lognormal Code************************************************
deltaboot.step<-function(DataFile,B,years,model,print.q="Y")
{
FileSize<-dim(DataFile)
index<-FileSize[1]
BootIndex<-matrix(nrow=years,ncol=B)
colnames(BootIndex)<-c(1:B)
rownames(BootIndex)<-levels(as.factor(DataFile[,2]))
Freqs<-table(DataFile[,2])
indexyears<-order(DataFile[,2])
cumyrcounts<-cumsum(Freqs)
if(model>2)
{model<-model/10}
#To resample the DataFile
for (i in 1:B)
{
  print(i)
  Bootrows<-sample(indexyears[1:cumyrcounts[1]],Freqs[1],replace=T)
  for (j in 2:years)
    {
      booti<-sample(indexyears[(cumyrcounts[j-1]+1):cumyrcounts[j]],Freqs[j],replace=T)
      Bootrows<-c(Bootrows,booti)
    }
  BootData<-Rows(DataFile,Bootrows)
  if (model<2)
  BtIndex<-deltalog.step(BootData,print.q)
  else BtIndex<-deltagam.step(BootData,print.q)
  tempindex<-as.data.frame(BtIndex)
  for (jj in 1:length(tempindex[,1]))
  {
   boot.ind<-rownames(tempindex)[jj]==rownames(BootIndex)
   #tempindex.ind<-rownames(BootIndex)==rownames(tempindex)[jj]
   BootIndex[boot.ind,i]<-tempindex[jj,1]
  }
  #BootIndex[,i]<-tempindex[,1]
}
BootSE<-sd(t(BootIndex),na.rm = T)
cbind(BootSE)
}

#mtrace(deltaboot.step)
#***********************************************************************************************************************************

#**********************************************************Full Analysis************************************************************
#model 0  = all CPUE, gives boot as deltalog
#model 1  = CPUElog & Geoxbar
#model 2  = CPUEgam & Geoxbar
#model 10 = CPUElog
#model 20 = CPUEgam
CPUEanalysis.step<-function(DataFile,B=100,model=0,print.q="Y")
{
   if(model==0 | model==1 | model ==10)
   {CPUElog<-deltalog.step(DataFile,print.q)}
    if(model==0 | model==2 | model ==20)
   {CPUEgam<-deltagam.step(DataFile,print.q)}
   
   if(is.na(CPUElog)==FALSE)
   {
        if(model==0 | model==1 | model ==10)
            {colnames(CPUElog)<-"lognormal"}
        if(model==0 | model==2 | model ==20)
            {colnames(CPUEgam)<-"gamma"}
        if(model==0 | model==1 | model ==2)
            {Geoxbar<-GeoAvg(DataFile)}
        BootStdev<-deltaboot.step(DataFile,B,length(CPUElog),model,print.q)
        if(model==0 | model==1 | model ==10)
            {CV<-BootStdev/CPUElog}
        if(model==2 | model==20 )
            {CV<-BootStdev/CPUEgam}
        colnames(CV)<-"CV"
   #Year<-as.numeric(levels(as.factor(DataFile[,2])))
        if(model==0)
        {CPUE<-cbind(Geoxbar,CPUElog,CPUEgam,BootStdev,CV)}
        if(model==1)
        {CPUE<-cbind(Geoxbar,CPUElog,BootStdev,CV)}
        if(model==2)
        {CPUE<-cbind(Geoxbar,CPUEgam,BootStdev,CV)}
        if(model==10)
        {CPUE<-cbind(CPUElog,BootStdev,CV)}
        if(model==20)
        {CPUE<-cbind(CPUEgam,BootStdev,CV)}
    return(CPUE)
   }
   else
   {CPUE<-NA}
}




















 deltalog.step.bestmod<-function(DataFile,print.q="Y")
{
 #DataFile should be ordered as follows
  # Column 1: CPUE
  # Column 2: Year (always Factor 1)
  # Remaining columns: Additional factors
  #Create factors
  nonOdata<-DataFile[DataFile[,1]>0,] #do this to get correct levels for non-zero data 
    ch.fac<-0
    nozero.fac<-0
  for (i in 2:ncol(DataFile)) 
    {
         DataFile[[i]] <- as.factor(DataFile[[i]])
         nonOdata[[i]]<- as.factor(nonOdata[[i]])
         ch.fac[i]<-nlevels(DataFile[,i])
         nozero.fac[i]<-nlevels(nonOdata[,i])
     }
  #Create non-zero data set
  nonOdata <- DataFile[DataFile[,1]>0,]
  
  #Check for only 1 factor level
  bad.i<-0
  bad.i0<-0
  for(jj in 2:length(DataFile))
  {
  if(length(levels((DataFile)[[jj]]))==1)
  {bad.i[jj]<-jj}
  if(length(levels((nonOdata)[[jj]]))==1)
  {bad.i0[jj]<-jj}
  }
  if(sum(bad.i)>0)
  {bad.i<-bad.i[-1]
  DataFile[[-bad.i]]}  
  if(sum(bad.i)>0)
  {bad.i<-bad.i[-1]
  nonOdata[[-bad.i]]
  }  
  
  fac.lev<-0
  #for (p in 2:length(DataFile))
  #{
  #ch.fac[p]<-nlevels(DataFile[,p])
  #nozero.fac[p]<-nlevels(nonOdata[,p])
  #}
  ch.fac<-ch.fac[-1]
  nozero.fac<-nozero.fac[-1]
  fac.lev<-c(ch.fac,nozero.fac)
  T.lev<-fac.lev>1
  T.lev[T.lev=="TRUE"]<-1

  if (sum(T.lev)==length(T.lev) & (length(nonOdata[,1])/max(nozero.fac))>1)
  {

  #Create weigth vector
  wt.vec = rep(1,nrow(DataFile))
  
  #Sort factor levels
  for (i in 2:ncol(DataFile)) 
    {
        DataFile[[i]] <- factor(DataFile[[i]], levels=(names(sort(table(nonOdata[[i]]),decreasing=T))))
    } 
  
  nonOdata <- DataFile[DataFile[,1]> 0,]
   
  ######Create binary data set#####
  Bidat<-DataFile
  Bidat[, 1] <- as.numeric(DataFile[, 1] > 0)
  bifactors<-paste(names(Bidat)[2:length(Bidat)],collapse="+")
  biform<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),bifactors))
  #Binomial Glm
  GLMbi <- glm(biform,data=Bidat,family="binomial",maxit=100)
  biform.min<-as.formula(paste(paste(names(Bidat)[1],"~",collapse=NULL),names(Bidat)[2])) 
  GLMbi.step <- stepAIC(GLMbi, scope= list(upper = biform, lower = biform.min), scale = 0, direction = c("both"), trace = FALSE, keep = NULL, steps = 1000, use.start = FALSE, k = 2) 
  if(print.q=="Y")
  {print(GLMbi.step$formula)}
  #Lognormal GLM
  formfact<-names(DataFile)[2]
  wts <- wt.vec[as.numeric(rownames(nonOdata))]
  if (length(names(DataFile))>2)
  {
        for (j in 3:length(names(DataFile)))
        {
        formfact<-paste(cbind(formfact,names(DataFile)[j]),collapse="+")
        }
    logfactors<-formfact
  }
   if (length(names(DataFile))==2)
       {logfactors<-formfact}
    logform<-as.formula(paste(paste("log(",(names(DataFile)[1]),")","~",collapse=NULL),logfactors))
  GLMlog<-glm(logform,data=nonOdata,weights=wts, family=gaussian,maxit=100)
  logform.min<-as.formula(paste(paste("log(",(names(DataFile)[1]),")","~",collapse=NULL),names(nonOdata)[2])) 
  GLMlog.step <- stepAIC(GLMlog, scope= list(upper = logform, lower = logform.min), scale = 0, direction = c("both"), trace = FALSE, keep = NULL, steps = 1000, use.start = FALSE, k = 2)  
  if(print.q=="Y")
  {print(GLMlog.step$formula)}
 #Choose overall model for both and re-run
 biform.best<-as.character(GLMbi.step$formula)
 bifac.best<-strsplit(biform.best[3]," ")[[1]]
 biform.length<-length(bifac.best)
 logform.best<-as.character(GLMlog.step$formula)
 logfac.best<-strsplit(logform.best[3]," ")[[1]]
 logform.length<-length(logfac.best)
 if(biform.length>logform.length)
 {
  logform.new<-as.formula(paste(logform.best[2],biform.best[1],biform.best[3]))
  newlogfac.i<-odd(c(1:biform.length))
  nonOdata.new<-cbind(nonOdata[1],subset(nonOdata,select=bifac.best[newlogfac.i]))
  GLMlog.step<-glm(logform.new,data=nonOdata.new,weights=wts, family=gaussian,maxit=100)
  print("")
  print("UPDATED LOGNORMAL MODEL:")
  print(logform.new)
 }
 else
 {
  biform.new<-as.formula(paste(biform.best[2],logform.best[1],logform.best[3]))
  newbifac.i<-odd(c(1:logform.length))
  Bidat.new<-cbind(Bidat[1],subset(Bidat,select=logfac.best[newbifac.i]))
  GLMbi.step <- glm(biform.new,data=Bidat.new,family="binomial",maxit=100)
  print("")
  print("UPDATED BINOMIAL MODEL:")
  print(biform.new)
  }
 
 #Calculate mean effects  
  bitemp<-0
  if (length(dummy.coef(GLMbi.step))>2)
     {
     for (i in 3:length(dummy.coef(GLMbi.step)))
        {
        bitemp[i-1]<-mean(dummy.coef(GLMbi.step)[[i]])
        }
    bifact<-sum(bitemp)
     }
  if (length(dummy.coef(GLMbi.step))==2)
     bifact<-0
  bisumcoeff<-dummy.coef(GLMbi.step)[[1]] + dummy.coef(GLMbi.step)[[2]] + bifact
  biindex<- exp(bisumcoeff)/(1+exp(bisumcoeff))
  
    biascorr <- GLMlog.step$deviance/GLMlog.step$df.residual/2     
  logtemp<-0
    if (length(dummy.coef(GLMlog.step))>2)
        {
        for (i in 3:length(dummy.coef(GLMlog.step)))
        {
    logtemp[i-1]<-mean(dummy.coef(GLMlog.step)[[i]])
    }
    logfact<-sum(logtemp)
    }
  if (length(dummy.coef(GLMlog.step))==2)
     logfact<-0
  logindex<-exp(dummy.coef(GLMlog.step)[[1]] + dummy.coef(GLMlog.step)[[2]] + logfact+biascorr)
  biindex<-biindex[names(logindex)]
  deltaindex<-cbind(biindex*logindex)
  DeltaIndex<-c(1:length(levels(DataFile[,2])))*0
  dim(DeltaIndex)<-c(length(DeltaIndex),1)
  numrows<-levels(DataFile[,2])
  names(DeltaIndex)<-matrix(numrows,1)
  DeltaIndex[1:length(deltaindex)]<-deltaindex[,1]
  ord<-order(names(DeltaIndex))
  deltaindex<-cbind(DeltaIndex[ord])
  deltalogindex<-cbind(as.numeric(deltaindex))
  return(deltaindex)
  }
  else
  deltaindex<-NA
  }

#**************************************************Bootstrapped Delta Lognormal Code************************************************
deltaboot.step<-function(DataFile,B,years,model,print.q="Y")
{
FileSize<-dim(DataFile)
index<-FileSize[1]
BootIndex<-matrix(nrow=years,ncol=B)
colnames(BootIndex)<-c(1:B)
rownames(BootIndex)<-levels(as.factor(DataFile[,2]))
Freqs<-table(DataFile[,2])
indexyears<-order(DataFile[,2])
cumyrcounts<-cumsum(Freqs)
if(model>2)
{model<-model/10}
#To resample the DataFile
for (i in 1:B)
{
  print(i)
  Bootrows<-sample(indexyears[1:cumyrcounts[1]],Freqs[1],replace=T)
  for (j in 2:years)
    {
      booti<-sample(indexyears[(cumyrcounts[j-1]+1):cumyrcounts[j]],Freqs[j],replace=T)
      Bootrows<-c(Bootrows,booti)
    }
  BootData<-Rows(DataFile,Bootrows)
  if (model<2)
  BtIndex<-deltalog.step.bestmod(BootData,print.q)
  else BtIndex<-deltagam.step(BootData,print.q)
  tempindex<-as.data.frame(BtIndex)
  for (jj in 1:length(tempindex[,1]))
  {
   boot.ind<-rownames(tempindex)[jj]==rownames(BootIndex)
   #tempindex.ind<-rownames(BootIndex)==rownames(tempindex)[jj]
   BootIndex[boot.ind,i]<-tempindex[jj,1]
  }
  #BootIndex[,i]<-tempindex[,1]
}
BootSE<-sd(t(BootIndex),na.rm = T)
cbind(BootSE)
}


#**********************************************************Full Analysis************************************************************
#model 0  = all CPUE, gives boot as deltalog
#model 1  = CPUElog & Geoxbar
#model 2  = CPUEgam & Geoxbar
#model 10 = CPUElog
#model 20 = CPUEgam
CPUEanalysis.step.bestmod<-function(DataFile,B=100,model=0,print.q="Y")
{
   if(model==0 | model==1 | model ==10)
   {CPUElog<-deltalog.step.bestmod(DataFile,print.q)}
    if(model==0 | model==2 | model ==20)
   {CPUEgam<-deltagam.step(DataFile,print.q)}
   
   if(is.na(CPUElog)==FALSE)
   {
        if(model==0 | model==1 | model ==10)
            {colnames(CPUElog)<-"lognormal"}
        if(model==0 | model==2 | model ==20)
            {colnames(CPUEgam)<-"gamma"}
        if(model==0 | model==1 | model ==2)
            {Geoxbar<-GeoAvg(DataFile)}
        BootStdev<-deltaboot.step(DataFile,B,length(CPUElog),model,print.q)
        if(model==0 | model==1 | model ==10)
            {CV<-BootStdev/CPUElog}
        if(model==2 | model==20 )
            {CV<-BootStdev/CPUEgam}
        colnames(CV)<-"CV"
   #Year<-as.numeric(levels(as.factor(DataFile[,2])))
        if(model==0)
        {CPUE<-cbind(Geoxbar,CPUElog,CPUEgam,BootStdev,CV)}
        if(model==1)
        {CPUE<-cbind(Geoxbar,CPUElog,BootStdev,CV)}
        if(model==2)
        {CPUE<-cbind(Geoxbar,CPUEgam,BootStdev,CV)}
        if(model==10)
        {CPUE<-cbind(CPUElog,BootStdev,CV)}
        if(model==20)
        {CPUE<-cbind(CPUEgam,BootStdev,CV)}
    return(CPUE)
   }
   else
   {CPUE<-NA}
}

# Version 1.7
# Revised 05/10/2004; programmed in R version 1.8.1 for Windows
# This function was inspired by Erik Williams' function, "glmdelta.get"

# OUTLINE
# SECTION 1: Error checks, format data, set defaults, define models, initial calcs
# SECTION 2: Data filter that stabilizes jackknife routine (set minpos=0 to disable)
# SECTION 3: Calculate delta-GLM index
# SECTION 4: Jackknife routine
# SECTION 5: Extract effects/coefficients for explanatory variables 2+ (if present);
#            calculate AIC scores; format results for screen output

# Changes/Additions:
#    1. Year effects are back-transformed LS Means (Searle et al., 1980).
#    2. Summary output returns *untransformed* coefficients for continuous covariates.
#    3. Choice of distributions for positive data: lognormal, gamma, or inverse gaussian
#    4. (optional) Reports AIC for the binomial and 'positive' GLMs;
#    5. In order to stabilize the jackknife routine, the data filter removes any factor
#       level with <2 positive observation; to override this setting use 'minpos'
#    6. Each jackknife iteration is initialized with coefficients from initial fit;
#       (jack.noise > 0 adds uniform 'noise' to starting values before each iteration)
#    7. 'write' argument saves summary output to current directory as text file
#    8. Optional weighting of GLM fitted to positive values
#       (requires pre-defined weight vector)
#    9. On-screen output is a list that includes:
#         a. name of distribution that is assumed for positive data
#         b. model formulas (R notation)
#         c. data frame with:
#            - delta-GLM index
#            - optional jackknife mean, SE, and CV
#         d. back-transformed effects for any additional factors in model,
#            and fitted coefficients for any additional continuous covariates
#         e. value of 'minpos' argument (threshold) for the current run
#         f. names of factor levels that were deleted by the 'minpos' filter
#         g. AIC scores for binomial and 'positive' GLMs,
#            and the MLE of the dispersion parameter for the positive GLM.

### SECTION 1 ###
#----------------
deltaglm<-function (data.set, dist="gamma", J=FALSE, write=FALSE,
          types=c("C","F",rep("F",ncol(data.set)-2)), minpos=2,
          lnorm.init=FALSE, weight.vector=rep(1,nrow(data.set)),
          jack.noise=1, ig.scale=1,plot.diags=0,plotID=" ")
{
    rownames(data.set)<-c(1:nrow(data.set)) #Ensures rows are consecutive numbers
    options(contrasts = c("contr.treatment", "contr.poly"))

    # check if 'types' argument is of correct length and form
    if (length(types) != ncol(data.set))
    {
        stop("'types' argument must define the response and all explanatory variables.")
    }

    # lnorm.init only necessary for fitting gamma and inverse gaussian distributions
    if (lnorm.init==TRUE && dist=="lognormal")
    {
        stop("Setting lnorm.init=TRUE is only valid for dist='gamma' or 'inverse.gaussian'")
    }

    # check if length of 'weight.vector' equals the number of observations
    if (length(weight.vector) != nrow(data.set))
    {
        stop("Length of 'weight.vector' does not match number of records in data.")
    }

    # use 'types' argument to define class of each variable
    for (i in 1:ncol(data.set))
    {
      if(types[i]=="C")
      {
        data.set[[i]] <- as.numeric(data.set[[i]])
      }
      if(types[i]=="F")
      {
        data.set[[i]] <- as.factor(data.set[[i]])
      }
      if(types[[i]]!="C" & types[[i]]!="F")
      {
        stop("Invalid variable type. Must be 'C' (continuous) or 'F' (factor).")
      }
    }

    #  ensure that response variable is of class 'numeric'
    if (types[[1]] != "C")
    {
        stop("Response must be of type 'C' (continuous).")
    }

    # ensure that first explanatory variable is of class 'factor'
    if (types[[2]] != "F")
    {
        stop("First explanatory variable must be of type 'factor.'")
    }

    # if jackknife routine is enabled, set minpos=2 to make it possible
    # to calculate variance (can't calculate for minpos <= 1)
    if (J==TRUE)
    {
       if(minpos<2)
       {
          minpos <- 2
          print("minpos argument set equal to 2 in order to stabilize jackknife routine.")
       }
       else minpos <- minpos
    }

    # define the distribution for positive observations (Gamma=default),
    # describe for summary output, and assign correct name to output
    if(dist == 'lognormal')
    {
        fam <- gaussian(link="identity")
        fam.out <- c("Lognormal distribution assumed for positive observations.")
        on.exit({
           assign("deltalognormal.results", results, pos = 1)
           assign("deltalognormal.summary", glmdelta.summary, pos = 1)
        })
    }
    if(dist == 'gamma')
    {
        fam <- Gamma(link="log")
        fam.out <- c("Gamma distribution assumed for positive observations.")
        on.exit({
           assign("deltagamma.results", results, pos = 1)
           assign("deltagamma.summary", glmdelta.summary, pos = 1)
        })
    }
    if(dist == 'inverse.gaussian')
    {
        fam <- inverse.gaussian(link="log")
        fam.out <- c("Inverse gaussian distribution assumed for positive observations.")
        on.exit({
           assign("deltainvgau.results", results, pos = 1)
           assign("deltainvgau.summary", glmdelta.summary, pos = 1)
        })
    }

    # this section automatically defines the model formulas from the data;
    # ("main-effects" only, see 'update' command in R documentation for
    #  testing interactions, etc.)
    if(dist == 'lognormal')
    {
       formula1 <- as.formula(paste(paste("log(", names(data.set)[1], ")", "~",
                           sep = ""), paste(names(data.set)[-1], sep = "",
                           collapse = "+")))
    }

    if(dist == 'gamma' || dist == 'inverse.gaussian')
    {
       formula1 <- as.formula(paste(paste(names(data.set)[1], "~", sep = ""),
                           paste(names(data.set)[-1], sep = "", collapse = "+")))
    }

    formula2 <- as.formula(paste(paste(names(data.set)[1], "~", sep = ""),
                        paste(names(data.set)[-1], sep = "", collapse = "+")))

    # describe model formulas for summary outpus
    bin.form <- c(paste("Formula for binomial GLM:", formula2[2], formula2[1], formula2[3]))
    pos.form <- c(paste("Formula for", fam$family, "GLM:", formula1[2], formula1[1], formula1[3]))

# define function to extract 'least squares means' from fitted glm objects
get.effects <- function(glm.obj, target.col)
{
  if(target.col==1) stop('Response variable can not be target of get.effects function')
  glm.data <- glm.obj$model
  dum.coef <- dummy.coef(glm.obj)
  glm.fam <- glm.obj$family$family
  col.num <- ifelse(glm.fam=="binomial", ncol(glm.data), ncol(glm.data)-1)
  var.class <- NULL
  for (i in 1:col.num)
  {
    var.class[i] <- class(glm.data[[i]])
  }
  if(var.class[1]!="numeric") stop('Response variable must be of class numeric')

  # define Estimated Marginal Means (Searle et al., 1980)
  emm.values <- rep(NA,col.num)
  if(col.num>2)
  {
    dum.index <- c(1:col.num)           # define index vector of correct length
    dum.index <- dum.index[-target.col] # exclude target column
    dum.index <- dum.index[-1]          # exclude response column
    for (i in dum.index)                # loop over remaining variables
    {
      if(var.class[i]=="factor") emm.values[i] <- mean(dum.coef[[i]])
      if(var.class[i]=="numeric") emm.values[i] <- dum.coef[[i]]*mean(glm.data[[i]])
      if(var.class[i]!="numeric" & var.class[i]!="factor")
      {
        stop('Variable class not recognized in EMM calculation')
      }
    }
  }

  if(glm.fam == "binomial")
  {
    if(class(glm.data[[target.col]])=="factor")
    {
      x <- exp(dum.coef[[1]] + dum.coef[[target.col]] + sum(emm.values, na.rm=T))
      bin.eff <- x/(1+x)
    }
    if(class(glm.data[[target.col]])=="numeric")
    {
      bin.eff <- dum.coef[[target.col]]
    }
    return(bin.eff)
  }

  if(glm.fam == "Gamma" || glm.fam == "inverse.gaussian")
  {
    if(class(glm.data[[target.col]])=="factor")
    {
      pos.eff <- exp(dum.coef[[1]] + dum.coef[[target.col]] + sum(emm.values, na.rm=T))
    }
    if(class(glm.data[[target.col]])=="numeric")
    {
      pos.eff <- dum.coef[[target.col]]
    }
    return(pos.eff)
  }

  if(glm.fam == "gaussian")
  {
    if(class(glm.data[[target.col]])=="factor")
    {
      pos.eff <- exp(dum.coef[[1]] + dum.coef[[target.col]] +
                 sum(emm.values, na.rm=T) + 0.5*summary(glm.obj)$dispersion)
    }
    if(class(glm.data[[target.col]])=="numeric")
    {
      pos.eff <- dum.coef[[target.col]]
    }
    return(pos.eff)
  }
}

# extract positive records

    posdat <- data.set[data.set[, 1] > 0, ]

# generate vector of weights for fitting gamma or lognormal GLM
# need to extract only the weights corresponding to positive observations
    posweights <- weight.vector[as.numeric(rownames(posdat))]

### SECTION 2 ###
#----------------
# 'backup' original data (prior to filtering data)
    data.set.orig <- data.set
    allpos <- posdat

# only want to filter by qualitative variables, so first identify them
  classes <- NULL
  for (i in 1:ncol(data.set)) classes[i] <- class(data.set[[i]])
  factors <- names(data.set)[classes=="factor"]

# First, create temp data set that only includes the factors
posdat <- cbind.data.frame(posdat[1],posdat[,factors])

# next, record which levels have fewer positives than 'minpos' specification
factor.freq.list <- as.list(rep(NA,ncol(posdat)-1))
factor.drop.list <- as.list(rep(NA,ncol(posdat)-1))
for (i in 2:ncol(posdat))
{
    factor.freq.list[[i-1]] <- table(posdat[[i]])
    if(length(factor.freq.list[[i-1]][factor.freq.list[[i-1]]<minpos])>0)
    {
        factor.drop.list[[i-1]] <- names(factor.freq.list[[i-1]][factor.freq.list[[i-1]]<minpos])
    }
    else
    {
        factor.drop.list[[i-1]] <- NA
    }
}

for(i in 1:length(factor.drop.list))
{
    attributes(factor.drop.list)$names[i] <- names(data.set[i+1])
}

# 'save' list containing names of levels that fall below 'minpos' threshold.
deleted.levels <- factor.drop.list

# record value of 'minpos' for summary output
minpos.val <- c(paste("Data filter threshold set at", minpos, "positive observations."))

# BEGIN 'WHILE' LOOP (data filter)
all.freq <- minpos-1
while (min(all.freq) < minpos)
{
    # update 'posdat' with each pass through the 'while' loop
    posdat <- data.set[data.set[, 1] > 0, ]

    # create temp data set that only includes the factors
    posdat <- cbind.data.frame(posdat[1],posdat[,factors])

    # create vector of frequencies (all.freq) for all levels of all factors
    # this vector determines when the 'while' loop will stop
    all.freq <- table(posdat[[2]])
    if (ncol(posdat)>2)
    {
       for (i in 3:ncol(posdat))
       {
          all.freq <- append(all.freq,table(posdat[[i]]))
       }
    }

    # create list containing names of levels that fall below 'minpos' threshold
    for (i in 2:ncol(posdat))
    {
        factor.freq.list[[i-1]] <- table(posdat[[i]])
        factor.drop.list[[i-1]] <- names(factor.freq.list[[i-1]][factor.freq.list[[i-1]]<minpos])
        for(i in 1:length(factor.drop.list))
        {
            attributes(factor.drop.list)$names[i] <- names(data.set[i+1])
        }
    }

    # remove 'offending' factor levels from the data set
    # i = index for number of components in list
    # j = index for number of elements in each component
    for(i in 1:length(factor.drop.list))
    {
        if(length(factor.drop.list[[i]])>0)
        {
            for (j in 1:length(factor.drop.list[[i]]))
            {
                data.set <- data.set[data.set[names(factor.drop.list)[i]]!=
                                              factor.drop.list[[i]][j],]

            }
        }
    }

    # extract weights relevant to 'filtered' data set
    weight.vector <- weight.vector[as.numeric(rownames(data.set))]

    # redefine factor levels to represent levels remaining in filtered data set
    for (i in 1:ncol(data.set))
    {
        if(class(data.set[[i]])=="factor") data.set[[i]] <- factor(data.set[[i]])
    }

    # renumber rownames of data.set to allow indexing of weight vector by posdat rownames
    rownames(data.set) <- 1:nrow(data.set)

}
# END 'WHILE' LOOP

# redefine data frame of positive records & weight vector (post-filter)
    posdat <- data.set[data.set[, 1] > 0, ]
    posweights <- weight.vector[as.numeric(rownames(posdat))]
    names(posweights) <- rownames(posdat)

# display the total number of records and pos. records that were deleted
    print(paste(nrow(data.set.orig)-nrow(data.set),
        "(total) records were removed by filter."))
    print(paste(nrow(allpos)-nrow(posdat),
        "positive records removed by filter."))

### SECTION 3 ###
#----------------
# calculate delta-GLM index

    # GLM fit to positive data (either Gamma or Lognormal)
    # save vector of coefficients (pos.coefs) to speed up the jackknife iterations
    if(dist == 'lognormal')
    {
        pos.fit <- glm(formula1, weights = posweights, family = fam,
                       data = posdat, maxit = 100)
        pos.coefs <- as.numeric(coef(pos.fit))
    }

    if(dist == 'gamma')
    {
        if(lnorm.init == TRUE)
        {
            # create formula for fitting lognormal 'GLM'
            lnorm.formula <- as.formula(paste(paste("log(", formula1[[2]], ")", "~",
                                                    sep = ""),
                                              paste(names(data.set)[-1], sep = "",
                                                    collapse = "+")
                                             )
                                       )
            # initial values for fitting Gamma GLM (antilog of coef's from lnorm fit)
            lnorm.coefs <- as.numeric(exp(coef(glm(lnorm.formula, data = posdat,
                                                   family = gaussian, maxit = 100,
                                                   weights = posweights)
                                              )
                                         )
                                     )
            # fit Gamma GLM with new starting values ('lnorm.coefs')
            pos.fit <- glm(formula1, weights = posweights, family = fam,
                           data = posdat, maxit = 100, start = lnorm.coefs)
            pos.coefs <- as.numeric(coef(pos.fit))
        }
        if(lnorm.init == FALSE)
        {
            pos.fit <- glm(formula1, weights = posweights, family = fam,
                           data = posdat, maxit = 100)
            pos.coefs <- as.numeric(coef(pos.fit))
        }

    }
if(plot.diags==1) 
  {
    png(file=paste0(getwd(),"/","GLMdiagnostics ",dist,"_",plotID,".png"),width=700,height=600)
    par(mfrow=c(2,2))
    plot(pos.fit)
    dev.off()
  }
#if(plot.diags==1) {plot(pos.fit)}
if(dist == 'inverse.gaussian')
    {
        # Inverse Gaussian GLMs are unstable with certain data sets, so I
        # use the fitted regression coefficients from either a gamma or
        # lognormal model as starting values in the I.G. fit.
        # The default is 'lnorm.init'=FALSE, which uses coefs from the gamma model;
        # set 'lnorm.init=TRUE' to use anti-logged coef's from the lognormal model.

        # define the formula for the lognormal model
        lnorm.formula <- as.formula(paste(paste("log(", formula1[[2]], ")", "~",
                                                sep = ""),
                                          paste(names(data.set)[-1], sep = "",
                                                collapse = "+")
                                         )
                                   )
        # take the antilog of the coef's for the lognormal model (these are close
        # enough for starting values)
        lnorm.coefs <- as.numeric(exp(coef(glm(lnorm.formula, data = posdat,
                                               family = gaussian, maxit = 100,
                                               weights = posweights)
                                          )
                                     )
                                 )
	gamma.glm <- glm(formula1, weights = posweights, family = Gamma(link='log'),
	                 data = posdat, maxit = 100, start=lnorm.coefs)
	y.obs <- gamma.glm$model[[1]]
	if(lnorm.init==FALSE)
	{
	    print("Initializing Inv. Gaussian GLM with coefficients from gamma GLM.")
	    invgau.par <- c(ig.scale, coef(gamma.glm))
	}
	if(lnorm.init==TRUE)
	{
	    print("Initializing Inv. Gaussian GLM with coefficients from gaussian GLM for log y.")
	    invgau.par <- c(ig.scale, lnorm.coefs)
	}
	X <- model.matrix(gamma.glm)

	# define negative log-likelihood for inverse gaussian distribution
        get.invgau.nll <- function(invgau.par, y.obs)
        {
            y.obs <- gamma.glm$model[[1]]
            mu <- as.numeric(exp(X %*% invgau.par[2:length(invgau.par)]))
            invgau.nll <- -sum(
                                log(
                                    sqrt(
                                         invgau.par[1]/(2*pi*y.obs^3)
                                        )*
                                    exp(
                                        -(invgau.par[1]/(2*y.obs))*((y.obs-mu)/mu)^2
                                       )
                                   )
                               )
            return(invgau.nll)
        }

        invgau.fit <- optim(invgau.par, get.invgau.nll,
                            method = "L-BFGS-B",
                            lower = c(0.000001, rep(-Inf, length(invgau.par)-1)),
                            upper = rep(Inf, length(invgau.par)),
                            control = list(maxit = 100000,
                                           factr = 1e7,
                                           trace = 1
                                          )
                           )

        if(invgau.fit$convergence == 1) print("Maximum number of iterations reached.")
        if(invgau.fit$convergence != 0) print("Check convergence of inverse gaussian fit.")
        names(invgau.fit)[1] <- "parameters"
        names(invgau.fit[[1]]) <- c("scale", names(coef(gamma.glm)))
        names(invgau.fit)[2] <- "negative.log.likelihood"
        AIC.invgau <- 2*invgau.fit[[2]]+2*length(invgau.fit[[1]])

        pos.fit <- glm(formula1, weights = posweights, family = fam,
                       data = posdat, maxit = 100,
                       start = invgau.fit[[1]][2:length(invgau.fit[[1]])])
        pos.coefs <- as.numeric(coef(pos.fit))
    }

    # get back-transformed year effects (with bias correction for lognormal)
    pred1 <- get.effects(pos.fit, 2)

    # Binomial GLM, logit link
    # recode the response variable as a binary variable
    bindat <- data.set
    bindat[, 1] <- as.numeric(data.set[, 1] > 0)

    # fit the binomial GLM using the recoded data set
    bin.fit <- glm(formula2, family = "binomial", data = bindat, maxit = 100)
    bin.coefs <- as.numeric(coef(bin.fit))

    # get back-transformed year effects (LS means)
    pred2 <- get.effects(bin.fit, 2)

    # This next part makes the year effects from each GLM match up correctly.
    # First, identify years that have at least one positive observation
    pred1.names <- names(pred1)

    # exclude probabilities for years that don't have any positive observations
    # (can't say that no positive observations means no fish)
    pred2 <- pred2[pred1.names]

    ### final index of abundance ###
    index <- pred1 * pred2

### SECTION 4 ###
#----------------
    # initialize objects for jackknife routine
    jackknife <- NA
    out.j <- rep(NA, length(index))
    out.j1 <- rep(NA, length(index))
    out.j2 <- rep(NA, length(index))
    # enable the next line for detailed output of jackknife iterations
    # obs.effect <- NA

    # jackknife routine
    if (J==TRUE)
    {
        jack <- nrow(data.set)
        # enable the next 2 lines for detailed output of jackknife iterations
        # obs.effect <- matrix(rep(NA, jack * 2), ncol = 2)
        # dimnames(obs.effect) <- list(c(1:jack), c("Observation", "SSQ"))
        for (j in 1:jack)
        {
            print(paste("Starting jacknife #", j, "out of", jack))
            jdat <- data.set[-j, ]
            jposdat <- jdat[jdat[, 1] > 0, ]
            jposdat.names <- rownames(jposdat)
            jweights <- posweights[jposdat.names]
            # start each jackknife iteration with fitted coef's from full model.
            # If iteration j removes a positive value, add some noise via 'jitter()'
            # to ensure that variability is not underestimated
            if (data.set[j,1] > 0)
            {
                jpos.fit <- glm(formula1, weights = jweights, family = fam,
                                data = jposdat, maxit = 100,
                                start = jitter(pos.coefs, factor=jack.noise)
                               )
            }
            if (data.set[j,1] == 0)
            {
                jpos.fit <- pos.fit
            }
            jpred1 <- get.effects(jpos.fit, 2)
            out.j1 <- rbind(out.j1, jpred1)

            jbindat <- jdat
            jbindat[, 1] <- as.numeric(jdat[, 1] > 0)
            jbin.fit <- glm(formula2, family = "binomial",
                            data = jbindat, maxit = 100,
                            start = jitter(bin.coefs, factor=jack.noise)
                           )
            jpred2 <- get.effects(jbin.fit, 2)
            if(any(names(jpred1) != names(jpred2)))
            {
                stop("Jackknife routine was unstable. Try increasing the value of 'minpos'.")
            }
            out.j2 <- rbind(out.j2, jpred2)
            out.j <- rbind(out.j, jpred1 * jpred2)
            # enable for detailed output of jackknife iterations
            # obs.effect[j, ] <- c(j, sum((index - jpred1 * jpred2)^2))
        }
     out.j <- out.j[-1, ]
     out.j1 <- out.j1[-1, ]
     out.j2 <- out.j2[-1, ]
     jack.mean <- apply(out.j, 2, mean)
     jack.se <- apply(out.j, 2, FUN = function(x) {
                      sqrt(((jack - 1)/jack) * sum((x - mean(x))^2))
                      })
     jack.cv <- jack.se/index
     jackknife <- cbind(jack.mean, jack.se, jack.cv)
   }

    if(dist == 'lognormal' || dist == 'gamma')
    {
        results <- list(positive.glm = pos.fit, binomial.glm = bin.fit,
                        positive.index = pred1, binomial.index = pred2)
                        # enable the next two lines for detailed output of jackknife iterations
                        # jposindex = out.j1, jbinindex = out.j2, jack.index = out.j,
                        # jack.obs.effect = obs.effect)
    }

    if(dist == 'inverse.gaussian')
    {
        results <- list(invgau.ML.fit = invgau.fit, positive.glm = pos.fit,
                        binomial.glm = bin.fit, positive.index = pred1,
                        binomial.index = pred2)
                        # enable the next two lines for detailed output of
                        #     jackknife iterations
                        # jposindex = out.j1, jbinindex = out.j2, jack.index = out.j,
                        # jack.obs.effect = obs.effect)
    }

### SECTION 5 ###
#----------------
# create data frame with filtered index and jackknife results
    index.df <- as.data.frame(cbind(index, jackknife))

# extract effects for additional explanatory variables, if present
# Create 'list' objects that will hold effects for both GLMs
  if (ncol(data.set)>2)
  {
      pos.eff.list <- as.list(rep(NA, ncol(data.set)-2))
      bin.eff.list <- as.list(rep(NA, ncol(data.set)-2))
      pos.eff.names <- as.list(rep(NA, ncol(data.set)-2))
      index.eff.list <- as.list(rep(NA, ncol(data.set)-2))
      for (i in 1:(ncol(data.set)-2))
      {
          pos.eff.list[[i]] <- get.effects(pos.fit, (i+2))
          bin.eff.list[[i]] <- get.effects(bin.fit, (i+2))
          pos.eff.names[[i]] <- names(pos.eff.list[[i]])
          bin.eff.list[[i]] <- bin.eff.list[[i]][pos.eff.names[[i]]]

          if(class(data.set[[i+2]])=="factor")
          {
              index.eff.list[[i]] <- cbind(pos.eff.list[[i]] * bin.eff.list[[i]])
          }

          if(class(data.set[[i+2]])=="numeric")
          {
              index.eff.list[[i]] <- rbind(pos.eff.list[[i]], bin.eff.list[[i]])
              rownames(index.eff.list[[i]]) <- c(pos.fit$family$family,bin.fit$family$family)
          }
      }

      # assign correct variable names to each part of list object
      for(i in 1:length(index.eff.list))
      {
          attributes(index.eff.list)$names[i] <- names(data.set[i+2])
      }
  }

  # create summary output
  if (ncol(data.set)>2)
  {
    glmdelta.summary <- list(error.distribution = fam.out,
                             binomial.formula = bin.form,
                             positive.formula = pos.form,
                             deltaGLM.index = index.df,
                             effects = index.eff.list,
                             data.filter = minpos.val,
                             levels.deleted.by.filter = deleted.levels)
  }
  else
  {
    glmdelta.summary <- list(error.distribution = fam.out,
                             binomial.GLM.formula = bin.form,
                             positive.GLM.formula = pos.form,
                             deltaGLM.index = index.df,
                             data.filter = minpos.val,
                             levels.deleted.by.filter = deleted.levels)
  }

  # since dispersion is fixed at 1 for binomial GLM,
  # use the 'canned' AIC() function in R
  AIC.binomial <- AIC(bin.fit)

  # since glm() in R uses moment estimators for the dispersion
  # parameter in gaussian, gamma, and inverse gaussian GLMs,
  # I needed to get the MLE of the dispersion parameter using optim()
  # For the lognormal model, I take regression coefs from the SS fit, and
  # calculate sigma.mle as sigma.unbiased*[(N-K)/N]^0.5

  coefs <- as.numeric(coef(pos.fit))
  X <- model.matrix(pos.fit)

  if (pos.fit$family$family == "gaussian")
  {
      y.obs <- exp(pos.fit$model[[1]])
      N <- length(y.obs)
      # number of regression coefficients, including the intercept term
      K <- length(coefs)
      sigma.mle <- sqrt(summary(pos.fit)$dispersion*((N-K)/N))

      lnorm.nll <- -sum(dlnorm(y.obs,
                               fitted(pos.fit),
                               sdlog=sigma.mle,
                               log=TRUE
                              )
                       )
      # use K+1 parameters for AIC, to account for dispersion parameter
      AIC.lognormal <- 2*lnorm.nll + 2*(K+1)
      AIC.results <- rbind(AIC.binomial, AIC.lognormal, sigma.mle)
  }

  if (pos.fit$family$family == "Gamma")
  {
      library(MASS)
      y.obs <- pos.fit$model[[1]]
      shape.mle <- gamma.shape(pos.fit)[[1]]
      gamma.par <- c(shape.mle, coefs)
      fitted <- as.numeric(exp(X %*% gamma.par[2:length(gamma.par)]))
      gamma.nll <- -sum(gamma.par[1]*(-y.obs/fitted-log(fitted))+
                        gamma.par[1]*log(y.obs)+
                        gamma.par[1]*log(gamma.par[1])-
                        log(y.obs)-lgamma(gamma.par[1])
                       )

      #AIC.gamma <- 2*gamma.nll + 2*length(gamma.par)
      AIC.gamma <- AIC(pos.fit)
      AIC.results <- rbind(AIC.binomial, AIC.gamma, shape.mle)
  }

  if (pos.fit$family$family == "inverse.gaussian")
  {
      AIC.inv.gauss <- AIC.invgau
      scale.mle <- as.numeric(invgau.fit[[1]][1])
      AIC.results <- rbind(AIC.binomial, AIC.inv.gauss, scale.mle)
  }

  if (ncol(data.set)>2)
  {
    glmdelta.summary <- list(error.distribution = fam.out,
                             binomial.formula = bin.form,
                             positive.formula = pos.form,
                             deltaGLM.index = index.df,
                             effects = index.eff.list,
                             data.filter = minpos.val,
                             levels.deleted.by.filter = deleted.levels,
                             aic = AIC.results)
  }
  else
  {
    glmdelta.summary <- list(error.distribution = fam.out,
                             binomial.GLM.formula = bin.form,
                             positive.GLM.formula = pos.form,
                             deltaGLM.index = index.df,
                             data.filter = minpos.val,
                             levels.deleted.by.filter = deleted.levels,
                             aic = AIC.results)
  }

  if (write==TRUE)
  {
      options("warn"=-1)
      write(fam.out, file="deltaGLM_output.txt")
      write(bin.form, file="deltaGLM_output.txt", append=T)
      write(pos.form, file="deltaGLM_output.txt", append=T)
      write(c("\n"), file="deltaGLM_output.txt", append=T)
      write.table(index.df, file="deltaGLM_output.txt",
                  quote=F, sep="\t", append=T)
      if (ncol(data.set)>2)
      {
         for (i in 1:length(index.eff.list))
         {
            write(c("\n"), file="deltaGLM_output.txt", append=T)
            write.table(index.eff.list[[i]], file="deltaGLM_output.txt",
                        col.names=names(index.eff.list)[i],
                        quote=F, sep="\t", append=T)
         }
      }

      write(c("\n"), file="deltaGLM_output.txt", append=T)
      write.table(as.data.frame(AIC.results), quote=F, sep="\t",
                  file="deltaGLM_output.txt", append=T)
      options("warn"=0)
  }

  return(glmdelta.summary)
}

