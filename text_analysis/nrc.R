# Load necessary libraries
library(dplyr)
library(tidytext)
library(tidyr)
library(ggplot2)

# Clean R Environment
rm(list=ls())

# Set up working directory
setwd("~/Documents/r_projects/text_analysis")

# Load cleaned data
df_nrc <- read.csv("cleaned_consumer_complaints.csv", stringsAsFactors = FALSE)

# Sentiment Analysis using NRC
# The NRC lexicon provides a broader range of sentiment categories (joy, anger, fear, etc.)
sentiment_nrc <- df_nrc %>% 
  inner_join(get_sentiments("nrc")) %>% 
  count(sentiment, sort = TRUE)

# Visualization: NRC Sentiment Distribution
ggplot(sentiment_nrc, aes(x = reorder(sentiment, n), y = n, fill = sentiment)) + 
  geom_col(show.legend = FALSE) + 
  coord_flip() + 
  scale_fill_manual(values = c(
    "anger" = "darkred",       
    "fear" = "purple",        
    "joy" = "orange",         
    "sadness" = "navy",       
    "surprise" = "gold",      
    "trust" = "forestgreen",  
    "disgust" = "gray",       
    "anticipation" = "skyblue"
  )) + 
  labs(title = "NRC Sentiment Analysis", x = "Sentiment", y = "Count") +
  theme_minimal() +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())

# Save the plot as an image for documentation
ggsave("images/nrc_sentiment.png", width = 8, height = 5)

# Print completion message
print("Sentiment analysis completed. Charts generated.")
