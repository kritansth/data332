# Car Counting and Speed Analysis Project

## 📊 Project Overview

This project analyzes vehicle traffic data collected via a road-side speed detector. The primary goal is to process, visualize, and derive meaningful insights from vehicle count and speed data.

Our objectives include:
- Counting the number of vehicles passing through a certain location
- Analyzing traffic patterns by time of day
- Identifying peak traffic hours
- Visualizing the distribution of vehicle speeds

## 📁 Project Files

- `cars_count.xlsx`: The raw dataset containing timestamped records of cars detected along with their speeds.
- `counting_cars.R`: The main R script used for loading, cleaning, analyzing, and visualizing the data.

## ⚙️ Requirements

Make sure the following R packages are installed before running the script:

```r
install.packages(c("readxl", "dplyr", "ggplot2", "lubridate"))
```

## ▶️ How to Use

	1. Clone this repository or download the files.
	2. Open counting_cars.R in RStudio.
	3. Ensure cars_count.xlsx is in the same working directory.
	4. Run the script to perform:
        •	Data cleaning
        •	Summary statistics
        •	Visualization of traffic trends


        
