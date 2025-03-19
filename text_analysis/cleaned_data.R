# Load necessary libraries
library(dplyr)
library(tidytext)
library(stringr)
library(tm)

# Clean R Environment
rm(list=ls())

# Set up working directory and load & read the csv file
setwd("~/Documents/r_projects/text_analysis")
df <- read.csv("consumer_complaints.csv", stringsAsFactors = FALSE)

# Data Cleaning: Selecting and filtering text column to remove empty complaints
df_clean <- df %>% 
  filter(!is.na(Consumer.complaint.narrative) & Consumer.complaint.narrative != "") %>% 
  select(Consumer.complaint.narrative)

# Text pre-processing: Remove punctuation, numbers, and extra spaces for standardization
df_clean$Consumer.complaint.narrative <- df_clean$Consumer.complaint.narrative %>% 
  str_replace_all("[[:punct:]]", "") %>%  
  str_replace_all("[[:digit:]]", "") %>%  
  str_squish()

# Remove stopwords - Stopwords (e.g., "the", "and") do not add much value to sentiment analysis
df_clean <- df_clean %>% 
  mutate(Consumer.complaint.narrative = removeWords(Consumer.complaint.narrative, stop_words$word))

# Tokenization: Convert text into individual words for further analysis
df_tokens <- df_clean %>% 
  unnest_tokens(word, Consumer.complaint.narrative)

# Remove unwanted words (e.g., placeholders like "XXXX") for better insights
df_tokens <- df_tokens %>% 
  filter(!str_detect(word, "^x+$"))

# Save cleaned data to a dedicated folder
write.csv(df_tokens, "cleaned_consumer_complaints.csv", row.names = FALSE)

# Print completion message
print("Data cleaning completed. Cleaned data saved as 'cleaned_consumer_complaints.csv'.")
