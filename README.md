# Survival-Analysis-Pine-Beetles
Bark vs. Bite

<h2>Description</h2>

Hello! I am really proud of this project.

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

![Employee data](/311-Mod11.jpg?raw=true "MOD11")

![Employee data](/311-Mod12.jpg?raw=true "MOD12")

![Employee data](/311-Mod13.jpg?raw=true "MOD13")

Outliers

![Employee data](/repository/assets/employee.png?raw=true "OUTLIERS")

![Employee data](/repository/assets/employee.png?raw=true "Employee Data title")

Results

![Employee data](/repository/assets/employee.png?raw=true "Employee Data title")

![Employee data](/repository/assets/employee.png?raw=true "Employee Data title")

References

![Employee data](/repository/assets/employee.png?raw=true "Employee Data title")





