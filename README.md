# Survival-Analysis-Pine-Beetles
Bark vs. Bite

<h2>Description</h2>

Hello there! I am really proud of this project...and the witty title. Enjoy!

I was tasked with finding a published article that challenges traditional survival analysis methods and then applying these methods to a new dataset... along with my own original analysis! For this project, I chose "Continuous-Time Proportional Hazards Regression for Ecological Monitoring Data" (2012) by Feng-Chang Lin and Jun Zhu. The reason I chose this paper is because it is a truly innovative use of survival methods in an ecological setting. Want to read more?
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3849820/ 

One of my personal interests is environmental sustainability. I believe one of the best ways we can start to understand, protect, and fight for environmental rights is through data science. Both the original paper and my own analysis in this project highlight the importance and power of using data to make well-informed decisions for the benefit of certain environments and the people who live among it. See "Project walk-through" below to read about my findings!

The full Rmarkdown code is documented in this repository, but the summary below is recommended for an overview.

<h2>Languages and Utilities Used</h2>

- <b>RStudio</b> 
- <b>KMSurv</b>
- <b>ggplot2</b>

<h2>Project walk-through:</h2>

![2012 Data](/311-Presentation.jpg?raw=true "LinZhu")

### Models, (Lin & Zhu, 2012)

The purpose of this paper is to utilize time to event data techniques not commonly found in environmental research in order to study the relationship between the colonization of red pines by two different beetles. This research attempts to answer if the colonization of red pines by turpentine beetles, that aren’t inherently damaging to trees, predispose a tree to colonization of another beetle, Ips ssp., that are known to kill red pines.

The following 3 models all represent Cox Proportional Hazards regression; their differences are described in the individual slides!


![Mod1](/311-Mod1.jpg?raw=true "Mod")
![Mod2 data](/311-Mod2.jpg?raw=true "Mod")
![Mod3 data](/311-Mod3.jpg?raw=true "Mod")





### Original Analysis, A. Reuschel (2023)


![Employee data](/311-NewData.jpg?raw=true "New")

Finding a new dataset to apply the methods of Lin & Zhu's paper to was very challenging. The requirements of both site and monitoring period variation made the selection process very tenuous. Despite this challenge, I was able to find a new dataset with nearly identical goals and measurements to the original bark beetle dataset. The data follow measurements of mountain pine beetle infestations in the Cypress Hills located in the Saskatchewan region of Canada after an outbreak of these beetles in 2006.

About the data:
- collected 2006-2018

- n = 238,121 observations

- event of interest = "MPB" (Mountain Pine Beetle)

- variables of interest = cell identifiers, MPB (0 or 1), latitude, longitude, 1-cell radius MPBprevYr (0 or 1), 2-cell radius MPBprevYr (0 or 1), 1-cell radius TrtPrevYr (0 or 1), 2-cell radius TrtPrevYr (0 or 1)

### Data Manipulation


🎯 My first goal was to create distinct sites to account for spatial dependence in my models. 
Although the dataset didn’t provide separate sites like the bark beetle dataset, the latitude and longitude coordinates corresponding to the centroid of the tree cells were given. I performed a k-means clustering on my data to assign sites to each cell group. 

![Employee data](/311-Kmeans.jpg?raw=true "KM")

🎯 Next, I created an indicator function to represent whether the tree cell was "at risk" during the kth monitoring period.

![Employee data](/311-Indicator.jpg?raw=true "IND")

### Research Question

🔬 Are the control methods employed on areas of pine beetle infested trees effective in preventing the spread of the pine beetles to a 1 or 2 degree radius?



### My Models

Model 1:

- time heterogeneous covariates for 6 terms

- interaction terms between time:(infestedPrevYr:treatedPrevYr)

- categorical variable for site

- (NEW!) covariate-site interactions, not in original models from (Lin & Zhu, 2012)

🔎 AIC = 12965 🔎


![Employee data](/311-Mod11.jpg?raw=true "MOD11")

Model 2:

- time-homogeneous regression coefficients

- this model does not consider time dependencies for any covariates or covariate interactions

🔎 AIC = = 12964 🔎

![Employee data](/311-Mod12.jpg?raw=true "MOD12")

Model 3:

- keeps the time independent covariates for both infested and treatment variables

- also considers the time dependent interaction between the infested and treatment variables

🔎 AIC = 12963.9 🔎

![Employee data](/311-Mod13.jpg?raw=true "MOD13")


### Outliers

📉 Due to the poor performance of all three models, I continued to explore the outliers in the model to determine what characteristics of these observations were prohibiting my assumptions from being met. I created a few tables in R to see if I could identify any patterns within the outliers. 

📌 I found that all observations shown to be outliers through the deviance residuals experienced the event. I then looked at my variables of interest, namely the infested and treatment variables from previous monitoring periods. This revealed that for all observations but one, there were no recorded infested or treated cells in the year prior to the cell experiencing the event. 

This likely means that the beetles spread faster than usual or that they were incorrectly missed in observation from the previous year. Due to these findings and the focus of my analysis, I decided to remove 407 observations from my dataset.

My primary goal was to determine if treatment methods are effective in preventing the spread of mountain pine beetles and since none of these observations received treatment prior to experiencing the event, they were not crucial to my model.

![Employee data](/311-Outliers.jpg?raw=true "OUTLIERS")


### Results

The snapshot below shows the AIC criterion improvement throughout all of my models.
Each model was fitted with and without outliers for comparison.

![Employee data](/311-Results.jpg?raw=true "Employee Data title")


site 2 most influential
interactions with site 2

![Employee data](/311-Results-O.jpg?raw=true "Employee Data title")

### Conclusion

![Employee data](/311-Conclusion.jpg?raw=true "Employee Data title")

### References

![Employee data](/311-Reference.jpg?raw=true "Employee Data title")





