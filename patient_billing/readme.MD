# Patient Billing Analysis

## Overview
This project analyzes patient visit and billing data using R, focusing on key insights such as visit trends, payment patterns, and reasons for visits based on location. The analysis uses data from three files: `Billing.xlsx`, `Patient.xlsx`, and `Visit.xlsx`.

## Features
- **Reason for Visit by Month**: Visualizing trends in patient visits over time.
- **Walk-in vs Scheduled Visits**: Understanding how visit types correlate with different reasons.
- **Visit Distribution by Location (Zip Code, City, State)**: Identifying regional patterns in patient visits.
- **Invoice Amounts by Visit Reason**: Analyzing total invoices and payment status.
- **Insightful Findings**: Extracting meaningful trends from the data.

## Data Processing
1. **Merging Datasets**: Combining patient, visit, and billing data for a complete view.
2. **Date Formatting**: Converting dates for accurate time-based analysis.
3. **Data Aggregation**: Summarizing counts, invoice totals, and average billing amounts.

## Visualizations
### 1. Reason for Visit by Month
![Reason for Visit by Month](images/reason_by_month.png)

### 2. Walk-in vs Scheduled Visits by Reason
![Walk-in vs Scheduled Visits](images/walkin_vs_scheduled.png)

### 3. Reason for Visit by Zip Code
![Reason for Visit by Zip Code](images/reason_by_zip.png)

### 4. Total Invoice Amount by Reason (Paid vs Unpaid)
![Total Invoice Amount](images/invoice_by_reason.png)

### 5. Average Invoice Amount by Reason
![Average Invoice Amount](images/avg_invoice_by_reason.png)

## Key Insight
Walk-in visits tend to have a higher total invoice amount compared to scheduled visits, possibly indicating that walk-in patients require more urgent or extensive care. Some reasons for visits also show significantly higher invoice amounts, suggesting a potential need for specialized treatment.

## Setup & Usage
1. Install required packages:
   ```r
   install.packages(c("ggplot2", "dplyr", "readxl", "tidyverse"))
   ```
2. Clone the repository and set your working directory:
   ```sh
   git clone https://github.com/yourusername/patient_billing.git
   cd patient_billing
   ```
3. Run the R script:
   ```r

