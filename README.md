# Survival-Analysis-Pine-Beetles
Bark vs. Bite

<h2>Description</h2>

The main concept explored in this project is the connection between Cox Proportional Hazards regression (semi-parametric method) and generalized linear model (glm) methods through a link function. Enjoy!

I based my models off of a paper written by Feng-Chang Lin and Jun Zhu. Below is the link to read the publication introducing two models that I attempt to use with new data. I also introduce a 3rd model in addition to the two mentioned in (Feng-Chang, Zhu (2012)).

"Continuous-Time Proportional Hazards Regression for Ecological Monitoring Data" (2012) by Feng-Chang Lin and Jun Zhu.
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3849820/ 

I enjoy studying various environmental science topics which motivated the ecological focus of this project. Both the original paper and my own analysis highlight the importance and power of using data to make well-informed decisions for the benefit of certain environments and the people who live among it. See "Project walk-through" below to read about my findings!

The full Rmarkdown code is documented in this repository, but the summary below is recommended for an overview.

<h2>Languages and Utilities Used</h2>

- <b>RStudio</b> 
- <b>KMSurv</b>
- <b>ggplot2</b>

<h2>Project walk-through:</h2>

![2012 Data](/Photos/311-Presentation.jpg?raw=true "LinZhu")

### Models, (Lin & Zhu, 2012)

The purpose of this paper is to utilize time to event data techniques not commonly found in environmental research in order to study the relationship between the colonization of red pines by two different beetles. This research attempts to answer if the colonization of red pines by turpentine beetles, that aren’t inherently damaging to trees, predispose a tree to colonization of another beetle, Ips ssp., that are known to kill red pines.

The following 3 models all represent Cox Proportional Hazards regression; their differences are described in the individual slides!


![Mod1](/Photos/311-Mod1.jpg?raw=true "Mod")
![Mod2 data](/Photos/311-Mod2.jpg?raw=true "Mod")
![Mod3 data](/Photos/311-Mod3.jpg?raw=true "Mod")





### Original Analysis, A. Reuschel (2023)


![Employee data](/Photos/311-NewData.jpg?raw=true "New")

Finding a new dataset to apply the methods of Lin & Zhu's paper to was very challenging. The requirements of both site and monitoring period variation made the selection process very tenuous. Despite this challenge, I was able to find a new dataset with nearly identical goals and measurements to the original bark beetle dataset. The data follow measurements of mountain pine beetle infestations in the Cypress Hills located in the Saskatchewan region of Canada after an outbreak of these beetles in 2006.

About the data:
- collected 2006-2018

- n = 238,121 observations

- event of interest = "MPB" (Mountain Pine Beetle)

![Employee data](/Photos/311-NewData2.jpg?raw=true "KM")


### Data Manipulation


🎯 My first goal was to create distinct sites to account for spatial dependence in my models. 
Although the dataset didn’t provide separate sites like the bark beetle dataset, the latitude and longitude coordinates corresponding to the centroid of the tree cells were given. I performed a k-means clustering on my data to assign sites to each cell group. 

![Employee data](/Plots/311-Kmeans.jpg?raw=true "KM")

🎯 Next, I created an indicator function to represent whether the tree cell was "at risk" during the kth monitoring period.

![Employee data](/Plots/311-Indicator.jpg?raw=true "IND")

### Research Question

🔬 Are the control methods employed on areas of pine beetle infested trees effective in preventing the spread of the pine beetles to a 1 or 2 degree radius?



### My Models

Model 1:

- time heterogeneous covariates for 6 terms

- interaction terms between time:(infestedPrevYr:treatedPrevYr)

- categorical variable for site

- (NEW!) covariate-site interactions, not in original models from (Lin & Zhu, 2012)

🔎 AIC = 12965 🔎


![Employee data](/Photos/311-Mod11.jpg?raw=true "MOD11")

Model 2:

- time-homogeneous regression coefficients

- this model does not consider time dependencies for any covariates or covariate interactions

🔎 AIC = 12964 🔎

![Employee data](/Photos/311-Mod12.jpg?raw=true "MOD12")

Model 3:

- keeps the time independent covariates for both infested and treatment variables

- also considers the time dependent interaction between the infested and treatment variables

🔎 AIC = 12963.9 🔎

![Employee data](/Photos/311-Mod13.jpg?raw=true "MOD13")


### Outliers

📉 Due to the poor performance of all three models, I continued to explore the outliers in the model to determine what characteristics of these observations were prohibiting my assumptions from being met. I created a few tables in R to see if I could identify any patterns within the outliers. 

📌 I found that all observations shown to be outliers through the deviance residuals experienced the event. I then looked at my variables of interest, namely the infested and treatment variables from previous monitoring periods. This revealed that for all observations but one, there were no recorded infested or treated cells in the year prior to the cell experiencing the event. 

📌 This likely means that the beetles spread faster than usual or that they were incorrectly missed in observation from the previous year. Due to these findings and the focus of my analysis, I decided to remove 407 observations from my dataset.

📌 My primary goal was to determine if treatment methods are effective in preventing the spread of mountain pine beetles and since none of these observations received treatment prior to experiencing the event, they were not crucial to my model.

![Employee data](/Plots/311-Outliers.jpg?raw=true "OUTLIERS")


### Results

The snapshot below shows the AIC criterion improvement throughout all of my models.
Each model was fitted with and without outliers for comparison.

![Employee data](/Plots/311-Results.jpg?raw=true "Employee Data title")

🔹 Output Interpretation, Site 2
- Site 2 is most impactful variable on the log hazards ratio, this time estimating the hazard for a cell group at this site to be 4.2 times higher than a cell group in site 1

- This explains why site:covariate interaction terms are also significant for site 2

🔸 Output Interpretation, Final Model
- The next highest impact on hazard in this final model is the number of infested cells in a 1-cell radius from the previous year ("covariate1"). This estimate reveals that for each unit increase in the covariate, the log hazards ratio increases by a factor of 3.03.

- This provides strong evidence for spatial dependencies


![Employee data](/Plots/311-Results-O.jpg?raw=true "Employee Data title")

### Conclusion

Recall: Are the control methods employed on areas of pine beetle infested trees effective in preventing the spread of the pine beetles to a 1 or 2 degree radius?

Evidence AGAINST treatment efficacy:

🔎 The strongest piece of evidence that WOULD affirm effectiveness of treatment methods lies in covariates 2 and 4 which each represent the number of treated cells in a previous year to a 1 and 2-degree radius respectively.
- While covariate 2 provided a negative estimate in my final model, the p-value was not significant.

- Covariate 4 on the other hand was found to be significant, but it has a positive coefficient of 1.18 indicating an increase in hazard. While this may be due to the strong pull of the infested variables, these covariates do not provide sufficient evidence to show that they directly lower the risk of infestation for a cell in the current monitoring period.

Evidence FOR treatment efficacy:

- The interaction terms between the infested and treated covariates, both time dependent and time independent, show a combined effect on the log hazards ratio that is negative.

- In the final model, the interaction “covariate1:covariate2” yielded an estimate of -0.56 and the interaction “covariate3:covariate4” yielded an estimate of -0.35. These estimates suggest that the treatment methods for both 1-cell and 2-cell radii are cutting down on the impact of the previous year’s infested cell count.

- Between the two, the interaction with a 1-cell radius has a lower estimate, reinforcing the spatial dependency component of this model.

![Employee data](/Photos/311-Conclusion.jpg?raw=true "Employee Data title")

### References

![Employee data](/Photos/311-Reference.jpg?raw=true "Employee Data title")





