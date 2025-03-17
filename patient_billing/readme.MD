# Patient Billing Analysis

## Project Overview
This project analyzes patient visit data, billing information, and reasons for visits using R. The analysis includes merging multiple datasets, cleaning the data, and generating insightful visualizations to understand trends in patient visits, invoice amounts, and payment statuses.

## Datasets Used
- **Billing.xlsx**: Contains invoice details, including amount and payment status.
- **Patient.xlsx**: Includes patient demographics and location information.
- **Visit.xlsx**: Records visit details such as reason for visit and walk-in status.

## Features
- **Data Cleaning & Transformation**: Date formatting, extracting month/year, and merging datasets.
- **Visualizations**:
  - Reasons for visits by month.
  - Walk-in vs. scheduled visits breakdown.
  - Reasons for visits by city/state.
  - Invoice amounts by reason and payment status.
  - Average invoice amounts by reason.
- **Insights**: Walk-in visits tend to have higher invoice amounts, potentially indicating more urgent or extensive care.

## Setup Instructions
1. Install necessary R packages if not already installed:
   ```r
   install.packages(c("ggplot2", "dplyr", "tidyverse", "readxl", "tidyr"))
   ```
2. Load the required libraries in your R script:
   ```r
   library(ggplot2)
   library(dplyr)
   library(tidyverse)
   library(readxl)
   library(tidyr)
   ```
3. Set up your working directory:
   ```r
   setwd('~/Documents/r_projects/patient_billing')
   ```
4. Load the datasets:
   ```r
   billing <- read_excel("Billing.xlsx")
   patient <- read_excel("Patient.xlsx")
   visit <- read_excel("Visit.xlsx")
   ```
5. Run the analysis script to generate visualizations.

## Visualizations
### 1. Reason for Visit by Month
![Reason for Visit by Month](https://github.com/kritansth/data332/blob/c883f5edb8c8edde09092435f57fc360f128fc27/patient_billing/graphs/month.png)

### 2. Walk-in vs Scheduled Visits by Reason
![Walk-in vs Scheduled](https://github.com/kritansth/data332/blob/c883f5edb8c8edde09092435f57fc360f128fc27/patient_billing/graphs/walkin.png)

### 3. Reason for Visit by City/State
![Reason by City](https://github.com/kritansth/data332/blob/c883f5edb8c8edde09092435f57fc360f128fc27/patient_billing/graphs/city.png)

### 4. Total Invoice Amount by Reason (Stacked by Payment Status)
![Invoice Amount](https://github.com/kritansth/data332/blob/c883f5edb8c8edde09092435f57fc360f128fc27/patient_billing/graphs/total_inv_reason_for_visit.png)

### 5. Average Invoice Amount by Reason
![Avg Invoice](https://github.com/kritansth/data332/blob/c883f5edb8c8edde09092435f57fc360f128fc27/patient_billing/graphs/avg_inv.png)

## Key Insights
- **Walk-in visits** have **higher invoice amounts** than scheduled visits, likely due to more urgent or extensive treatments.
- Some visit reasons generate **significantly higher invoices**, indicating the need for specialized care.
- Certain cities/states experience a **higher concentration of specific visit reasons**, which can inform resource allocation.
