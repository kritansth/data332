Visualizing Student Data using R Studio

Overview

This project performs exploratory data analysis and visualization on student majors, registration, and payments using RStudio. The process involves merging datasets, generating visual insights, and summarizing key financial matters.

Datasets

Course.xlsx: Contains information on majors offered, their unique IDs, start and end dates, and associated costs.

Registration.xlsx: Includes student registration details, total cost, balance due, and payment plan status.

Student.xlsx: Holds student demographic and contact information.

Libraries Used

dplyr: Data manipulation

ggplot2: Data visualization

readxl: Reading Excel files

tidyr: Data tidying

scales: Formatting axis labels

lubridate: Handling date-time data

Key Features

Data Merging & Preparation

Merges registration, student, and course data using left joins by Student ID and Instance ID.

Converts birth dates into a usable format and calculates student ages.

Filters out missing age values to ensure data integrity.

Visualizations

Enrollment Trend Over Time: Line graph showing student registration trends over the years.

Gender Distribution Across Majors: Stacked bar chart visualizing the proportion of genders in each major.

Students per Major: Bar chart depicting the number of students enrolled in each major.

Payment Plan Breakdown: Bar chart illustrating the proportion of students using different payment plans.

Total Cost vs. Balance Due: Scatter plot showing financial trends across different majors.

Average Age by Major: Bar chart displaying the average age of students enrolled in each major.

How to Run

Installation

Ensure you have R and the required libraries installed using:

install.packages(c("dplyr", "ggplot2", "readxl", "tidyr", "scales", "lubridate"))

Execution Steps

Place the Course.xlsx, Registration.xlsx, and Student.xlsx files in your working directory.

Run the script in RStudio.

View the generated plots in the RStudio plot pane.

Results

Visualizations provide insights into enrollment trends, financial balances, and student demographics.

Graphs and summaries will be printed in the console and displayed in the plot viewer.

Author

This project was developed to provide clear and insightful student enrollment and financial analysis. The visualizations offer a simple yet effective way to interpret key trends and patterns.


