# Load necessary libraries
library(readxl)
library(dplyr)
library(ggplot2)

# Load data
student <- read_excel("~/Documents/r_projects/student/Student.xlsx")
registration <- read_excel("~/Documents/r_projects/student/Registration.xlsx")
course <- read_excel("~/Documents/r_projects/student/Course.xlsx")


# Merge datasets
merged_data <- registration %>%
  left_join(student, by = "Student ID") %>%
  left_join(course, by = "Instance ID")

# Convert Birth Date to Year
merged_data$`Birth Year` <- as.numeric(format(as.Date(merged_data$`Birth Date`), "%Y"))

# Plot 1: Number of students per major
ggplot(merged_data, aes(x = `Title`)) +
  geom_bar(fill = "steelblue") +
  labs(title = "Number of Students per Major", x = "Major", y = "Count") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Plot 2: Distribution of birth years
ggplot(merged_data, aes(x = `Birth Year`)) +
  geom_histogram(binwidth = 2, fill = "darkgreen", color = "black") +
  labs(title = "Distribution of Birth Years", x = "Year", y = "Count")

# Aggregate cost per major, segmented by payment plan
cost_summary <- merged_data %>%
  group_by(`Title`, `Payment Plan`) %>%
  summarise(Total_Cost = sum(`Total Cost`, na.rm = TRUE))

# Plot 3: Total cost per major, segmented by payment plan
ggplot(cost_summary, aes(x = `Title`, y = Total_Cost, fill = `Payment Plan`)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Total Cost per Major (Segmented by Payment Plan)", x = "Major", y = "Total Cost") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Aggregate balance due per major, segmented by payment plan
balance_summary <- merged_data %>%
  group_by(`Title`, `Payment Plan`) %>%
  summarise(Total_Balance_Due = sum(`Balance Due`, na.rm = TRUE))

# Plot 4: Total balance due per major, segmented by payment plan
ggplot(balance_summary, aes(x = `Title`, y = Total_Balance_Due, fill = `Payment Plan`)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Total Balance Due per Major (Segmented by Payment Plan)", x = "Major", y = "Balance Due") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
