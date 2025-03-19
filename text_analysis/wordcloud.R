# Load necessary libraries
library(dplyr)
library(tidytext)
library(ggplot2)
library(wordcloud)
library(RColorBrewer)

# Clean R Environment
rm(list=ls())

# Set up working directory and load & read the csv file
setwd("~/Documents/r_projects/text_analysis")

# Load cleaned data
df_wordcloud <- read.csv("cleaned_consumer_complaints.csv", stringsAsFactors = FALSE)

# Ensure the dataset contains a "word" column
if(!"word" %in% colnames(df_wordcloud)) {
  stop("Error: Column 'word' not found. Ensure tokenization is done correctly in cleaned_data.R.")
}

# Generate Word Cloud
set.seed(1234)

# Display word cloud in RStudio
wordcloud(words = df_wordcloud$word, min.freq = 50, max.words = 200, colors = brewer.pal(8, "Dark2"))

# Save the word cloud as an image
png("images/wordcloud.png", width = 800, height = 600, res = 150)  # Higher resolution
wordcloud(words = df_wordcloud$word, min.freq = 50, max.words = 200, 
          colors = brewer.pal(8, "Dark2"), scale = c(3, 0.5), random.order = FALSE)
dev.off()

# Print completion message
print("Word cloud generated and saved as 'images/wordcloud.png'.")
