# Load necessary libraries
library(dplyr)
library(tidytext)
library(tidyr)
library(ggplot2)

# Set up working directory and load & read the csv file
rm(list=ls())
setwd("~/Documents/r_projects/text_analysis")

# Load Cleaned Data
df_bing <- read.csv("cleaned_consumer_complaints.csv", stringsAsFactors = FALSE)

# Sentiment Analysis using bing 
sentiment_bing <- df_bing %>% 
  inner_join(get_sentiments("bing")) %>% 
  count(word, sentiment, sort = TRUE)

# Sentiment score calculation
sentiment_bing_score <- df_bing %>% 
  inner_join(get_sentiments("bing")) %>%
  mutate(index = row_number() %/% 80) %>%
  count(index, sentiment) %>%
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) %>% 
  mutate(sentiment_score = positive - negative)
# Using pivot_wider to reshape data: We convert "positive" and "negative" counts into separate columns
# This allows us to calculate a sentiment score by subtracting negative from positive.

# Visualization: Sentiment Score over Complaints
ggplot(sentiment_bing_score, aes(index, sentiment_score)) +
  geom_col(fill = "steelblue", show.legend = FALSE) +
  labs(title = "Consumer Complaint Sentiment Analysis",
       x = "Index (Grouped Complaints)",
       y = "Sentiment Score") +
  theme_minimal()
 
print("Sentiment analysis completed. Charts generated.")
ggsave("images/bing_sentiment.png", width = 8, height = 5)
print("Bing sentiment analysis completed. Image saved in '~/Documents/r_projects/text_analysis/images/bing_sentiment.png'.")
