# Load necessary libraries
library(readxl)
library(dplyr)
library(ggplot2)
library(lubridate)
library(scales)

# Load the Excel files
student_df <- read_excel("~/Documents/r_projects/student/Student.xlsx")
registration_df <- read_excel("~/Documents/r_projects/student/Registration.xlsx")
course_df <- read_excel("~/Documents/r_projects/student/Course.xlsx")

# Convert birth date to birth year and calculate age
student_df$`Birth Date` <- as.Date(student_df$`Birth Date`)
student_df$Birth_Year <- as.numeric(format(student_df$`Birth Date`, "%Y"))
current_year <- year(Sys.Date())
student_df$Age <- current_year - student_df$Birth_Year  

# Merge data using left joins
merged_df <- registration_df %>%
  left_join(course_df, by = "Instance ID") %>%
  left_join(student_df, by = "Student ID")

# Remove NA values from Age column
merged_df <- merged_df %>% filter(!is.na(Age))

# Enrollment Trend Over Time

if ("Registration Date" %in% colnames(merged_df)) {
  merged_df$`Registration Date` <- as.Date(merged_df$`Registration Date`)
  
  enrollment_trend <- merged_df %>%
    mutate(Year = year(`Registration Date`)) %>%
    group_by(Year) %>%
    summarise(Total_Students = n())
  
  ggplot(enrollment_trend, aes(x = Year, y = Total_Students)) +
    geom_line(color = "darkgreen", size = 1.5) +
    geom_point(color = "maroon", size = 3) +
    labs(title = "Enrollment Trend Over the Years", x = "Year", y = "Number of Students") +
    theme_minimal()
} else {
  print("Error: 'Registration Date' column not found in dataset. Check column names!")
}


# Gender Breakdown by Major

if ("Gender" %in% colnames(merged_df)) {
  ggplot(merged_df, aes(x = Title, fill = Gender)) +
    geom_bar(position = "fill") +
    labs(title = "Gender Distribution Across Majors", x = "Major", y = "Proportion") +
    scale_fill_manual(values = c("skyblue", "maroon")) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
} else {
  print("Error: 'Gender' column not found in dataset. Check column names!")
}


# Student Count by Payment Plan

if ("Payment Plan" %in% colnames(merged_df)) {
  payment_summary <- merged_df %>%
    group_by(`Payment Plan`) %>%
    summarise(Number_of_Students = n())
  
  ggplot(payment_summary, aes(x = `Payment Plan`, y = Number_of_Students, fill = `Payment Plan`)) +
    geom_bar(stat = "identity") +
    labs(title = "Student Count by Payment Plan", x = "Payment Plan", y = "Number of Students") +
    theme_minimal() +
    theme(legend.position = "none") +
    scale_fill_manual(values = c("skyblue", "darkgreen", "maroon"))
} else {
  print("Error: 'Payment Plan' column not found in dataset. Check column names!")
}


# Total Cost vs Balance Due (Scatter Plot)

if (all(c("Total Cost", "Balance Due") %in% colnames(merged_df))) {
  ggplot(merged_df, aes(x = `Total Cost`, y = `Balance Due`, color = Title)) +
    geom_point(alpha = 0.7, size = 3) +
    theme_minimal() +
    labs(title = "Total Cost vs Balance Due (Colored by Major)", 
         x = "Total Cost", y = "Balance Due") +
    theme(legend.position = "bottom")
} else {
  print("Error: 'Total Cost' or 'Balance Due' column not found in dataset.")
}


# Students per Major (Bar Chart)

major_counts <- merged_df %>%
  group_by(Title) %>%
  summarise(Number_of_Students = n())

ggplot(major_counts, aes(x = reorder(Title, -Number_of_Students), y = Number_of_Students)) +
  geom_bar(stat = "identity", fill = 'darkgreen') +
  labs(title = "Number of Students per Major", x = "Major", y = "Count") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
