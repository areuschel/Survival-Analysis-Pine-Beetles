library(dplyr)
# install.packages("dplyr")
library(survival)
library(MASS)
library(ggplot2)
#install.packages("cluster")
library(cluster)
# update.packages(ask = FALSE, dependencies = TRUE)




god <- read.csv("filepath")
# #trimming for columns's I want to explore
beetle <- god %>%
  select(CellID, Year, MPB, Latitude, Longitude, ColdTolerance, BP1, BP2, BP1red, BP2red, BP1man, BP2man)

#renaming col's
new_column_names <- c("Group", "Monitoring_Period", "Delta", "Site_Lat", "Site_Long", "Cold_Tolerance", "BP1_Infected_Prev","BP2_Infected_Prev", "BP1_NoTreatment_Prev", "BP2_NoTreatment_Prev", "BP1_Treatment_Prev", "BP2_Treatment_Prev")


beetle <- setNames(beetle, new_column_names)


beetle_tte <- beetle %>%
  select(Group, Monitoring_Period, Delta, Site_Lat, Site_Long, Cold_Tolerance, BP1_Infected_Prev, BP1_Treatment_Prev, BP2_Infected_Prev, BP2_Treatment_Prev)

#deleting incomplete groups
beetle_tte <- beetle_tte %>%
  group_by(Group) %>%
  filter(all(c(2006:2018) %in% Monitoring_Period)) %>%
  ungroup()

#making deltas after first 1 to 0
beetle_tte <- beetle_tte %>%
  group_by(Group) %>%
  mutate(Delta = ifelse(row_number() > which.max(Delta == 1), 0, Delta)) %>%
  ungroup()

#adding Time col
beetle_tte$Time <- beetle_tte$Monitoring_Period

observation_count <- table(beetle_tte$Monitoring_Period)
print(observation_count)


###K-Means###
locations <- beetle_tte[, c("Site_Lat", "Site_Long")]
set.seed(2023)
k <- 4
result <- kmeans(locations, centers = k, nstart = 10)


ggplot(beetle_tte, aes(x = Site_Long, y = Site_Lat, color = factor(result$cluster))) +
  geom_point() +
  labs(title = "Clusters of Sites")

cluster_counts <- table(result$cluster)
cluster_counts

#assign sites to each group
beetle_tte$Site <- result$cluster

###MODELS###

# Full model
library(survival)
surv_mod <- Surv(beetle_tte$Time, beetle_tte$Delta)

# Risk indicator function
# Y = 1 (subject at ith site in kth monitoring period at risk) or 0 (not at risk)

beetle2 <- beetle_tte[order(beetle_tte$Site, beetle_tte$Monitoring_Period), ]

beetle2 <- beetle2 %>%
  group_by(Group) %>%
  mutate(
    Y_ki = ifelse(row_number() <= which.max(Delta == 1), 1, 0)
  ) %>%
  ungroup()


# Checking indicator function
risk_event_table <- beetle2 %>%
  group_by(Monitoring_Period) %>%
  summarize(
    TotalY = sum(Y_ki),
    TotalEvents = sum(Delta)
  )
risk_event_table

# Check
# 
# events_2007 <- beetle2 %>%
#   filter(Monitoring_Period == 2007, Delta ==1) %>%
#   select(Group, Delta, Monitoring_Period, Y_ki)
# events_2007
# 
# #look at 884, 1145, 1271 and check that 2006 they had events- all look correct!!
# #look at 913, 2809, 18893 and check that 2007 they are not considered at risk- all look correct!!
# 
# group_884_obs <- beetle2 %>%
#   filter(Group == 884) %>%
#   select(Group, Delta, Monitoring_Period, Y_ki)
# group_884_obs
# 
group_18893_obs <- beetle2 %>%
  filter(Group == 18893) %>%
  select(Group, Delta, Monitoring_Period, Y_ki)
group_18893_obs
# 
# # Rest of 2007 events to check: 874*, 908*,1165*, 1169*, 1515,1650,1918,2144,2929,18489
# # * = checked and good!

link_df <- data.frame(
  SurvObj = surv_mod,
  Y_ki = beetle2$Y_ki,
  covariate1 = beetle2$BP1_Infected_Prev,
  covariate2 = beetle2$BP1_Treatment_Prev,
  covariate3 = beetle2$BP2_Infected_Prev,
  covariate4 = beetle2$BP2_Treatment_Prev, 
  site = as.factor(beetle2$Site),
  Time = beetle2$Time,
  event = as.numeric(beetle2$Delta)
)

#baseline mod
link_base <- glm(event ~ Time, family = binomial(link = 'cloglog'), data = link_df)
summary(link_base)

#full mod
link_full <- glm(event ~ offset(Y_ki) +
                   Time +
                   covariate1:Time + 
                   covariate2:Time + 
                   covariate3:Time + 
                   covariate4:Time + 
                   (covariate1:Time):(covariate2:Time) + 
                   (covariate3:Time):(covariate4:Time) + 
                   site +
                   covariate1:site + 
                   covariate2:site + 
                   covariate3:site + 
                   covariate4:site
                 ,
                 family = binomial(link = 'cloglog'), data = link_df)

summary(link_full)


#using AIC
library(MASS)
aic_full <- stepAIC(link_full, direction = "backward")
#same result
full_final <- glm(event ~ Time + site + 
                    Time:covariate1 + Time:covariate2 + Time:covariate3 + Time:covariate4 + 
                    (covariate1:Time):(covariate2:Time) + 
                    (covariate3:Time):(covariate4:Time) +  
                    covariate1:site + covariate2:site + covariate3:site + covariate4:site + 
                    offset(Y_ki),
                  family = binomial(link = 'cloglog'),
                  data = link_df)
summary(full_final)


#goodness of fit

anova(link_base, full_final, test ="Chisq")
#test shows that model significantly improves 
link_base$aic
full_final$aic
link_base$aic - full_final$aic
#lowered aic by 3549.653

#deviance residuals
dev_residuals1 <- residuals(full_final, type = 'deviance')

plot(link_df$Time, dev_residuals1,
     type = 'b', pch = 10, 
     xlab = "Time", ylab = "Deviance Residuals",
     main = "Deviance Residuals for GLM Model 1")

#checking for outliers because of deviance plot
plot(link_df$Time, dev_residuals1,
     type = 'b',
     xlab = 'time', ylab = 'dev residuals',
     main = "Mod1: Residuals with Outliers")

points(link_df$Time[outliers1], dev_residuals1[outliers1], pch = 18, col = 'red')

outliers1 <- which(dev_residuals1 > 3 | dev_residuals1 < -3)
outlier_sites1 <- link_df$site[outliers1]
print(outlier_sites1)
#get a table
site_counts <- table(link_df$site[outliers1])
site_counts

#full mod, no outliers
link_df_no_outliers <- link_df[-outliers1, ]


link_outliers <- glm(event ~ offset(Y_ki) +
                       Time +
                       covariate1:Time + 
                       covariate2:Time + 
                       covariate3:Time + 
                       covariate4:Time + 
                       (covariate1:Time):(covariate2:Time) + 
                       (covariate3:Time):(covariate4:Time) + 
                       site +
                       covariate1:site + 
                       covariate2:site + 
                       covariate3:site + 
                       covariate4:site
                     ,
                     family = binomial(link = 'cloglog'), data = link_df_no_outliers)

summary(link_outliers)

aic_outliers <- stepAIC(link_outliers, direction = "backward")
#
full_final_no_outliers <- glm(event ~ Time + site + 
                                Time:covariate1 + Time:covariate3 + Time:covariate4 + 
                                (covariate1:Time):(covariate2:Time) + 
                                (covariate3:Time):(covariate4:Time) +  
                                covariate1:site + covariate2:site + covariate3:site + covariate4:site + 
                                offset(Y_ki),
                              family = binomial(link = "cloglog"), data = link_df_no_outliers)
summary(full_final_no_outliers)


#comparing AIC's
#base model
link_base$aic
#full model
link_full$aic
#final with outliers
full_final$aic
#final without outliers
full_final_no_outliers$aic

#likelihood ratio
#model without treatment covariates
lrt_red1 <- glm(event ~ Time + site + 
                  Time:covariate1 + Time:covariate3 + 
                  covariate1:site + covariate3:site +
                  offset(Y_ki),
                family = binomial(link = 'cloglog'),
                data = link_df)
#model with treatment covariates
lrt_full1 <- glm(event ~ Time + site + 
                   Time:covariate1 + Time:covariate2 + Time:covariate3 + Time:covariate4 + 
                   (covariate1:Time):(covariate2:Time) + 
                   (covariate3:Time):(covariate4:Time) +  
                   covariate1:site + covariate2:site + covariate3:site + covariate4:site + 
                   offset(Y_ki),
                 family = binomial(link = 'cloglog'),
                 data = link_df)
#chisq test
lrt1 <- anova(lrt_red1, lrt_full1, test = "Chisq")
lrt1



# reduced mod1

link_df <- data.frame(
  SurvObj = surv_mod,
  Y_ki = beetle2$Y_ki,
  covariate1 = beetle2$BP1_Infected_Prev,
  covariate2 = beetle2$BP1_Treatment_Prev,
  covariate3 = beetle2$BP2_Infected_Prev,
  covariate4 = beetle2$BP2_Treatment_Prev, 
  site = as.factor(beetle2$Site),
  Time = beetle2$Time,
  event = beetle2$Delta
)


link_red1 <- glm(event ~ Time + 
                   offset(Y_ki) + 
                   covariate1 + 
                   covariate2 + 
                   covariate3 + 
                   covariate4 + 
                   covariate1:covariate2 + 
                   covariate3:covariate4 + 
                   site +
                   covariate1:site + 
                   covariate2:site + 
                   covariate3:site + 
                   covariate4:site
                 ,
                 family = binomial(link = 'cloglog'), data = link_df)
summary(link_red1)

#using AIC backward
aic_red1 <- stepAIC(link_red1, direction = "backward")

link_red1final <- glm(event ~ Time + offset(Y_ki) + covariate1 + covariate2 + covariate3 + 
                        covariate4 + covariate1:covariate2 + covariate3:covariate4 + 
                        site + covariate1:site + covariate2:site + covariate3:site + 
                        covariate4:site,
                      family = "binomial"(link= 'cloglog'), data = link_df)
summary(link_red1final)

#deviance residuals
dev_residuals2 <- residuals(link_red1final, type = 'deviance')

plot(link_df$Time, dev_residuals2,
     type = 'b', pch = 10, 
     xlab = "Time", ylab = "Deviance Residuals",
     main = "Deviance Residuals for GLM Model 2")

#red mod1, no outliers
link_df_no_outliers2 <- link_df[-outliers2, ]


link_outliers2 <- glm(event ~ offset(Y_ki) +
                        Time +
                        covariate1 + 
                        covariate2 + 
                        covariate3 + 
                        covariate4 + 
                        covariate1:covariate2 + 
                        covariate3:covariate4 + 
                        site +
                        covariate1:site + 
                        covariate2:site + 
                        covariate3:site + 
                        covariate4:site
                      ,
                      family = binomial(link = 'cloglog'), data = link_df_no_outliers2)

summary(link_outliers2)

link_red1final_no_outliers <- glm(event ~ Time + covariate1 + covariate2 + covariate3 + covariate4 + 
                                    site + covariate1:covariate2 + covariate3:covariate4 + covariate1:site + 
                                    covariate3:site + covariate4:site + offset(Y_ki),
                                  family = "binomial"(link = "cloglog"), data = link_df_no_outliers2)
summary(link_red1final_no_outliers)

# AIC check
#base
link_base$aic
#full final
full_final$aic
#full no outliers
full_final_no_outliers$aic
#red mod1 final
link_red1final$aic
#red mod1 final no outliers
link_red1final_no_outliers$aic

# reduced mod2

summary(link_red1final)
summary(full_final)

#time dependent covariates affect odds less (smaller estimates, so make homogeneous)
#include time interaction for interaction between treatment and infected covariates

link_hybrid <- glm(event ~ Time + offset(Y_ki) + 
                     covariate1 + covariate2 + covariate3 + covariate4 + 
                     (covariate1:Time):(covariate2:Time) + 
                     (covariate3:Time):(covariate4:Time) +
                     site + 
                     covariate1:site + covariate2:site + covariate3:site + covariate4:site,
                   family = "binomial"(link= 'cloglog'), data = link_df)
summary(link_hybrid)

#deviance residuals
#these also same
dev_residuals4 <- residuals(link_hybrid, type = 'deviance')

plot(link_df$Time, dev_residuals4,
     type = 'b', pch = 10, 
     xlab = "Time", ylab = "Deviance Residuals",
     main = "Deviance Residuals for GLM Model Hybrid")

#red mod2, no outliers
link_df_no_outliers2 <- link_df[-outliers2, ]


link_hybrid2 <- glm(event ~ Time + offset(Y_ki) + 
                      covariate1 + covariate2 + covariate3 + covariate4 + 
                      (covariate1:Time):(covariate2:Time) + 
                      (covariate3:Time):(covariate4:Time) +
                      site + 
                      covariate1:site + covariate2:site + covariate3:site + covariate4:site
                    ,
                    family = binomial(link = 'cloglog'), data = link_df_no_outliers2)

summary(link_hybrid2)

hybrid_final_no_outliers <- glm(event ~ Time + 
                                  covariate1 + covariate2 + covariate3 + covariate4 + 
                                  site + 
                                  covariate1:site + covariate3:site + covariate4:site + 
                                  Time:covariate1:covariate2 + Time:covariate3:covariate4 + 
                                  offset(Y_ki),
                                family = "binomial"(link="cloglog"), data = link_df_no_outliers2)

#I'm doing model without outliers for this visual
#final model gave best AIC

#deviance residuals
dev_residuals3 <- residuals(hybrid_final_no_outliers, type = 'deviance')

plot(link_df_no_outliers$Time, dev_residuals3,
     type = 'b', pch = 10, 
     xlab = "Time", ylab = "Deviance Residuals",
     main = "Deviance Residuals for GLM Model 3")

outliers5 <- which(dev_residuals3 > 3 | dev_residuals3 < -3)
outlier_sites5 <- link_df$site[outliers5]
print(outlier_sites5)
#get a table
site_counts5 <- table(link_df$site[outliers5])
site_counts5

hybrid_final2_no_outliers <- glm(event ~ Time + 
                                   covariate1 + covariate2 + covariate3 + covariate4 + 
                                   site + 
                                   covariate1:site + covariate3:site + 
                                   Time:covariate1:covariate2 + Time:covariate3:covariate4 + 
                                   offset(Y_ki),
                                 family = binomial(link = 'cloglog'), data = link_df_no_outliers2
)
summary(hybrid_final2_no_outliers)

# AIC check

#base model, no predictors
link_base$aic
#full model, before removing outliers
full_final$aic
#full model, after removing outliers
full_final_no_outliers$aic
#model 2, before removing outliers
link_red1final$aic
#model 2, after removing outliers
link_red1final_no_outliers$aic
#hybrid model, before removing outliers
link_hybrid$aic
#hybrid model, after removing outliers
hybrid_final3_no_outliers$aic

###OUTLIERS###

library(dplyr)
outlier_investigation <- beetle2[outliers1, ]
head(outlier_investigation)
infections_prev1 <- table(outlier_investigation$BP1_Infected_Prev)
infections_prev1
infections_prev2 <- table(outlier_investigation$BP2_Infected_Prev)
infections_prev2
events_outliers <- table(outlier_investigation$Delta)
events_outliers
#they all have events, but no previous infections to 1 or 2 degree radius
#this indicates a "random"ish appearance of beetles
#My research question is more interested in treatment methods, and these outliers didn't even receive treatment bc there were no recorded infections

outlier_investigation2 <- beetle2[outliers5, ]
head(outlier_investigation2)
at_risk <- table(outlier_investigation2$Y_ki)
at_risk
#these except for 3 all observed the event already

dev_residuals6 <- residuals(hybrid_final3_no_outliers, type = 'deviance')

plot(link_df_no_outliers3$Time, dev_residuals6,
     type = 'b', pch = 10, 
     xlab = "Time", ylab = "Deviance Residuals",
     main = "Deviance Residuals for Best Model")

outliersfinal <- which(dev_residuals6 > 3 | dev_residuals6 < -3)
outlier_sites6 <- link_df$site[outliersfinal]
print(outlier_sites6)
#get a table
site_counts5 <- table(link_df$site[outliersfinal])
site_counts5

dev_residuals7 <- residuals(hybrid_final3_no_outliers, type = 'deviance')

plot(link_df_no_outliers3$Time, dev_residuals7,
     type = 'b', pch = 10, 
     xlab = "Time", ylab = "Deviance Residuals",
     main = "Deviance Residuals for Best Model")

outliersfinal2 <- which(dev_residuals7 > 3 | dev_residuals7 < -3)
outlier_sites7 <- link_df$site[outliersfinal2]
print(outlier_sites7)
#get a table
site_counts6 <- table(link_df$site[outliersfinal2])
site_counts6
#only 25 outliers in this deviance plot

#checking for outliers because of deviance plot
plot(link_df_no_outliers3$Time, dev_residuals7,
     type = 'b',
     xlab = 'time', ylab = 'dev residuals',
     main = "Mod3: Residuals with Outliers")

points(link_df_no_outliers3$Time[outliersfinal2], dev_residuals7[outliersfinal2], pch = 18, col = 'red')

#final model without treatment covariates
lrt_red1 <- glm(event ~ Time + 
                  covariate1 + covariate3 + 
                  site + 
                  covariate1:site + covariate3:site + 
                  offset(Y_ki),
                family = 'binomial'(link= 'cloglog'), data = link_df_no_outliers3)
# final model with treatment covariates
lrt_full1 <- glm(event ~ Time + 
                   covariate1 + covariate2 + covariate3 + covariate4 + 
                   site + 
                   covariate1:site + covariate2:site + covariate3:site + 
                   Time:covariate1:covariate2 + Time:covariate3:covariate4 + 
                   offset(Y_ki),
                 family = 'binomial'(link= 'cloglog'), data = link_df_no_outliers3)
#LRT
lrt1 <- anova(lrt_red1, lrt_full1, test = "Chisq")
lrt1

