#!/bin/R 

# based on: https://github.com/marinegenomicslab/Epi-Age-Est/blob/main/Scripts/BAYES_GLM.r

#Set up workspace
getwd() #Display the current working directory
workingDir = "/Users/emmastrand/MyProjects/Epigenetic_aging/"
# working directory will be based on RHEL directories

#Changing when scientific numbers are written
options("scipen"=100, "digits"=4)
options(warn = 1)

#Loading libraries
library(tidyverse)
library(emmeans)
library(rstanarm)
library(coda)
library(tidymodels)
library(caret)

#Defining Function
variable_importance <- function(fit, interval, variable_names){
  #A function to look at the posterior intervals and summarize if there is any variation as a result of the given variables
  posterior_interval(fit, interval) %>%
    as_tibble(rownames = 'parameter') %>%
    rename(lwr = 2, upr = 3) %>%
    filter(str_detect(parameter, str_c(variable_names, collapse = '|'))) %>%
    mutate(variable_testing = str_extract_all(parameter, str_c(variable_names, collapse = '|')),
           variable_testing = map_chr(variable_testing, str_c, collapse = ':')) %>%
    group_by(variable_testing) %>%
    summarise(important_var = if_else(all(lwr < 0 & upr > 0), 'no', 'yes'))
}

###### IMPORTING DATA ###### 
#Import data -- result is a dataframe named 'df'
### no. of rows = 21,994,932 (from testing phase)
### no. of columns = 11
## RHEL= /data/prj/Fisheries/epiage/haddock/df_all.RData
## desktop = 
#load(file = "data/WGBS/df_all_20231220.RData")
load(file = "/data/prj/Fisheries/epiage/haddock/df_all_20231220.RData")
head(df)
meta <- df %>% dplyr::select(sample, AgeRounded, `Ind Sex`, `Length Cm`) %>% distinct()
###### 

###### DATA PRUNING ###### 

### goal = smaller set of sites to input to GLM to reduce computing time
df_spread <- df %>% dplyr::select(sample, AgeRounded, Loc, percent.meth) %>% spread(Loc, percent.meth)
### 1. removing sites with low variance (74,557)
nzv.cpg.list <- nearZeroVar(df_spread, freqCut = 85/15, uniqueCut = 50, allowParallel = TRUE) 
df_spread_filteredDescr <- df_spread[, -nzv.cpg.list]
### 2. removing sites that are highly correlated with each other (466,392) therefore 28,522 sites left
filteredDescr_matrix <- df_spread_filteredDescr %>% dplyr::select(-sample, -AgeRounded) 
highlyCorDescr <- findCorrelation(filteredDescr_matrix, cutoff = 0.8)  
df_spread_filteredDescr_cor <- df_spread_filteredDescr[,-highlyCorDescr]
### creating list from the df above 
df_spread_filteredDescr_cor_list <- df_spread_filteredDescr_cor %>% gather("Loc", "percent.meth", 1:28522) %>%
  dplyr::select(Loc) %>% distinct()
### filtering df to those Loc from above 
df <- df_spread_filteredDescr_cor_list %>% left_join(., df, by = "Loc")

##############################


# USED DURING TESTING; TAKE OUT FOR REAL THING
### no. of rows post-filtering = 12,495,690
#df <- df %>% dplyr::group_by(Loc) %>% filter(n()>2) %>% ungroup() ## remove line after testing phase

# Creating a list of all the unique positions
positions_list <- unique(df$Loc) 

## USED DURING TESTING; TAKE OUT FOR REAL THING - only takes top 6
#positions_list<-head(positions_list)

###### ###### ###### ###### 



###### RUNNING GENERAL LINEAR MODEL ###### 

# Preparing objects for data collection
GLM <- list()
GLM$Stats <- data.frame(matrix(nrow=length(positions_list), ncol=2), row.names=positions_list)
colnames(GLM$Stats) <- c("Max_Rhat", "Min_ESS")

# for loop for every loci 
for(i in 1:length(df$Loc)){
  
  #subset the dataframe gene by gene
  df_filtered <- subset(df, Loc == positions_list[i])
  
  #Bayesian model
  bayes_model <- stan_glmer(matrix(c(meth, unmeth), ncol=2) ~ AgeRounded + (1 | `Ind Sex`), 
                    data = df_filtered, 
                    family = binomial(link = "logit"), 
                    cores = 4, iter=4000)
  
  #Gathering convergence stats
  GLM$Stats[i, ] <- c(max(summary(bayes_model)[, "Rhat"]), min(summary(bayes_model)[, "n_eff"]))
  
  #Significant posteriors
  tmp_post <- posterior_interval(bayes_model, prob = 0.95)
  VARS <- rownames(tmp_post)[abs(tmp_post[,2])>abs(tmp_post[,2]-tmp_post[,1])]
  
  #Find significant factors
  sig <- joint_tests(bayes_model)
  sig_fact <- cbind(rep(as.character(df$Loc[i]),nrow(sig)), sig)
  
  #Getting posterior ranges
  test1 <- data.frame(emmeans(bayes_model, ~ AgeRounded, type = "response"))
  
  test1 <- test1[!(is.na(test1$prob)),]
  
  test1 <- cbind(rep(as.character(df$Loc[i]),nrow(test1)), test1)
  
  #Jason test
  jtest1 <- variable_importance(bayes_model, 0.95, c('AgeRounded'))
  jtest2 <- as.data.frame(jtest1[jtest1$important_var=="yes",1])
  if(nrow(jtest2)>0){jtest2 <- cbind(rep(as.character(df$Loc[i]),nrow(jtest2)), jtest2)}
  
  #Writing outputs
  write.table(GLM$Stats[i, ], "/data/prj/Fisheries/epiage/haddock/GLM/GLM_Stats.txt", col.names=F, row.names=T, quote=F, append=T)
  write.table(t(as.vector(c(as.character(df$Loc[i]), VARS))), "/data/prj/Fisheries/epiage/haddock/GLM/GLM_Sig_post.txt", col.names=F, row.names=F, quote=F, append=T)
  write.table(sig_fact, "/data/prj/Fisheries/epiage/haddock/GLM/GLM_Sig_jt.txt", col.names=F, row.names=F, quote=F, append=T)
  write.table(jtest2, "/data/prj/Fisheries/epiage/haddock/GLM/GLM_Sig_js.txt", col.names=F, row.names=F, quote=F, append=T)
  
  #Writing factor intervals
  write.table(test1, "/data/prj/Fisheries/epiage/haddock/GLM/GLM_emmeans_1factor.txt", col.names=F, row.names=F, quote=F, append=T)
}

###### ###### ###### ###### 

# column headers for GLM_Stats.txt
# Max_Rhat Min_ESS(n_eff)
# row names = Loc
## Rhat should be above 1.01 and n_eff should be below 2000

# column headers for GLM_Sig_post.txt
# Loc VARS

# column headers for GLM_Sig_jt 
# Loc nrow(sig)) model term df1 df2 F.ratio Chisq p.value


# column headers for GLM_sig_js 
# Loc Significant factor

# column headers for GLM_emmeans_1factor.txt


###### ###### ###### ###### 

# Filtering df to those positions that are significant to age 

GLM_output <- read.delim2(file="/data/prj/Fisheries/epiage/haddock/GLM/GLM_Sig_jt.txt", header=F, sep=" ")
GLM_convergence <- read.delim2(file="/data/prj/Fisheries/epiage/haddock/GLM/GLM_Stats.txt", header=F, sep=" ")

colnames(GLM_output) <- c("scaffold", "start", "term", "df1", "df2", "F.ratio", "Chisq", "p.value")
colnames(GLM_convergence) <- c("scaffold", "start", "Max_Rhat", "n_eff")

GLM_output <- GLM_output %>% unite(Loc, c("scaffold", "start"), sep=" ", remove=F)
GLM_convergence <- GLM_convergence %>% unite(Loc, c("scaffold", "start"), sep=" ", remove=F)

GLM_output_significant <- GLM_output %>% filter(p.value < 0.050)
GLM_convergence_significant <- GLM_convergence %>% filter(Max_Rhat > 1.010 & n_eff < 2000)
filtered_list <- inner_join(GLM_output_significant, GLM_convergence_significant, by = c("Loc", "scaffold", "start")) %>% dplyr::select(Loc) %>% distinct()

df_significant <- df %>% right_join(., filtered_list, by = c("Loc"))

#Save as R data file / read in R data file for future running
save(df_significant, file = "/data/prj/Fisheries/epiage/haddock/df_significant.RData")

### 20231226 notes: nrow(filtered_list) = 308; nrow(df_significant) = 5852