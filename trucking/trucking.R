library(ggplot2)
library(dplyr)
library(tidyverse)
library(readxl)
library(tidyr)

# Resetting RStudio Environment
rm(list=ls())

# Set working directory
setwd('~/Documents/r_projects/trucking')

# Load Excel file (adjust skip if necessary)
# df_truck <- read_excel('NP_EX_1-2.xlsx', 
#                        sheet = 2, skip = 3, .name_repair = "universal")

df_truck_0001 <- read_excel('truck data 0001.xlsx', 
                       sheet = 2, skip = 3, .name_repair = "universal")

df_truck_0369 <- read_excel('truck data 0369.xlsx', 
                       sheet = 2, skip = 3, .name_repair = "universal")

df_truck_1226 <- read_excel('truck data 1226.xlsx', 
                       sheet = 2, skip = 3, .name_repair = "universal")

df_truck_1442 <- read_excel('truck data 1442.xlsx', 
                       sheet = 2, skip = 3, .name_repair = "universal")

df_truck_1478 <- read_excel('truck data 1478.xlsx', 
                       sheet = 2, skip = 3, .name_repair = "universal")

df_truck_1539 <- read_excel('truck data 1539.xlsx', 
                       sheet = 2, skip = 3, .name_repair = "universal")

df_truck_1769 <- read_excel('truck data 1769.xlsx', 
                       sheet = 2, skip = 3, .name_repair = "universal")

df_pay <- read_excel('Driver Pay Sheet.xlsx', .name_repair = "universal")

df <- rbind(df_truck_0001, df_truck_0369, df_truck_1226, df_truck_1442, 
            df_truck_1478, df_truck_1539, df_truck_1769)

df_starting_Pivot <- df %>%
  group_by(Truck.ID) %>%
  summarize(count = n())

df <- left_join(df, df_pay, by = c('Truck.ID'))


# Selecting relevant columns
df_expense <- df %>%
  select(Gallons, Price.per.Gallon, Tolls, Misc, Odometer.Beginning, Odometer.Ending)

# Calculate Fuel Cost
df_expense <- df_expense %>%
  mutate(Fuel_Cost = Gallons * Price.per.Gallon)

# Compute Total Fuel Expenses
total_fuel_expense <- sum(df_expense$Fuel_Cost, na.rm = TRUE)

# Compute Other Expenses (Tolls + Misc)
other_expenses <- sum(df_expense$Tolls + df_expense$Misc, na.rm = TRUE)

# Compute Total Expenses (Fuel Cost + Other Expenses)
total_expense <- total_fuel_expense + other_expenses

# Compute Total Gallons Consumed
total_gallons_consumed <- sum(df_expense$Gallons, na.rm = TRUE)

# Compute Total Miles Driven
total_miles_driven <- sum(df_expense$Odometer.Ending - df_expense$Odometer.Beginning, na.rm = TRUE)

# Compute Miles per Gallon (MPG)
miles_per_gallon <- ifelse(total_gallons_consumed > 0, total_miles_driven / total_gallons_consumed, NA)

# Compute Total Cost per Mile
total_cost_per_mile <- ifelse(total_miles_driven > 0, total_expense / total_miles_driven, NA)

# Getting difference in days within a column
date1 <- min(df$Date, na.rm = TRUE)
date2 <- max(df$Date, na.rm = TRUE)
number_days_on_road <- as.numeric(difftime(date2, date1, units = "days"))

# Compute total driving hours
num_hrs_driving <- sum( df$Hours, na.rm = TRUE)

# Print all results
print(paste("Number of days on the road:", number_days_on_road))
print(paste("Total hours driving:", num_hrs_driving))
print(paste("Total Fuel Expense:", total_fuel_expense))
print(paste("Other Expenses:", other_expenses))
print(paste("Total Expense:", total_expense))
print(paste("Total Gallons Consumed:", total_gallons_consumed))
print(paste("Total Miles Driven:", total_miles_driven))
print(paste("Miles per Gallon (MPG):", miles_per_gallon))
print(paste("Total Cost per Mile:", total_cost_per_mile))

#split
df[c('warehouse', 'starting_city_state')] <- 
  str_split_fixed(df$Starting.Location, ',', 2)

#string extract
df$starting_city_state <- gsub(',', "", df$starting_city_state)

# do another string split to show them what the problem is. 
df[c('col1', 'col2')] <- str_split_fixed(df$starting_city_state, ' ', 2)

#do this in console nchar(df$city_state)[1]

df[c('col1', 'col2', 'col3')] <- 
  str_split_fixed(df$col2, ' ', 3)

#drop col1-col3 it is too much - could write a for loop to clean up

#start by just completing the group_by with count, then add complexity
#by using na.rm = TRUE you can remove missing values
df_starting_Pivot <- df %>%
  group_by(starting_city_state) %>%
  summarize(count = n(),
            mean_size_hours = mean(Hours, na.rm = TRUE),
            sd_hours = sd(Hours, na.rm = TRUE),
            total_hours = sum(Hours, na.rm = TRUE),
            total_gallons = sum(Gallons, na.rm = TRUE)
            )

ggplot(df_starting_Pivot, aes(x= starting_city_state, y = count)) + 
  geom_col() + 
  theme(axis.text = element_text(angle = 45, vjust = .5, hjust = 1))

