# Patient Billing

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyverse)
library(readxl)
library(tidyr)

# Resetting R Environment

rm(list = ls())

# Set working directory
setwd('~/Documents/r_projects/patient_billing')

# Load the datasets
billing <- read_excel("Billing.xlsx")
patient <- read_excel("Patient.xlsx")
visit <- read_excel("Visit.xlsx")

# Merge datasets with relational keys
visit_patient <- merge(visit, patient, by = "PatientID", all.x = TRUE)
full_data <- merge(visit_patient, billing, by = "VisitID", all.x = TRUE )

# Convert VisitDate and InvoiceDate to Date format
full_data$VisitDate <- as.Date(full_data$VisitDate)
full_data$InvoiceDate <- as.Date(full_data$InvoiceDate)

# Extract Month and Year
full_data$Month <- format(full_data$VisitDate, "%B")
full_data$Year <- format(full_data$VisitDate, "%Y")

# Sort Months Properly
full_data$Month <- factor(full_data$Month, levels = month.name)

# Reason for Visit by Month
ggplot(full_data, aes(x = Month, fill = Reason)) +
  geom_bar(position = "stack") +
  theme_minimal() + 
  labs(title = "Reason for Visit by Month",
       x = "Month", y = "Number of Visits") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Reason for Visit based on Walk-in or Not
ggplot(full_data, aes(x = factor(WalkIn), fill = Reason)) + 
  geom_bar(position = "stack") +
  theme_minimal() +
  labs(title = "Reason for Visit Based on Walk-in or Not", x = "Walk-in (1 = Yes, 0 = No)", y = "Count")

# Reason for Visit by City/State
ggplot(full_data, aes(x = City, fill = Reason)) +
  geom_bar(position = "stack") +
  theme_minimal() +
  labs(title = "Reason for Visit by City",
       x = "City", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Total Invoice Amount Based on Reason for Visit (Stacked Bar Chart with Payment Status)
ggplot(full_data, aes(x = Reason, y = InvoiceAmt, fill = factor(InvoicePaid))) + 
  geom_bar(stat = "identity", position = "stack") +
  theme_minimal() +
  labs(title = "Total Invoice Amount Based on Reason for Visit", x = "Reason for Visit", y = "Total Invoice Amount", fill = "Paid (1 = Yes, 0 = No)") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Additional Insight: Average Invoice Amount by Reason
ggplot(full_data %>% group_by(Reason) %>% summarise(AvgInvoice = mean(InvoiceAmt, na.rm = TRUE)), 
       aes(x = Reason, y = AvgInvoice)) + 
  geom_col(fill = "steelblue") +
  theme_minimal() +
  labs(title = "Average Invoice Amount by Reason for Visit", x = "Reason for Visit", y = "Average Invoice Amount") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Analysis Insight: Walk-in visits tend to have a higher total invoice amount compared to scheduled visits, which may 
# indicate that walk-in patients require more urgent or extensive care. Additionally, some reasons for visits have 
# significantly higher invoice amounts, suggesting a potential need for specialized treatment or services.
