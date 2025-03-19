# Consumer Complaints Sentiment Text Analysis

## Author
- Kritan Shrestha

## Introduction 📌
This project analyzes consumer complaints through text analysis techniques, including word cloud visualization and sentiment analysis using Bing and NRC lexicons. The goal is to uncover common themes, sentiment trends, and emotional tones in consumer complaints to derive actionable insights.

---

## Data Dictionary
The dataset consists of consumer complaints from various industries.  
### Columns Used:
1. **Consumer.complaint.narrative** – The raw text of consumer complaints.

---

## Data Cleaning
The raw data underwent the following preprocessing steps to ensure consistency and relevance:  
1. **Removed missing values** –Removed rows with missing or empty complaint narratives.  
```r
df_clean <- df %>% 
  filter(!is.na(Consumer.complaint.narrative) & Consumer.complaint.narrative != "")
```
2. **Text Standardization** – Removed punctuation, numbers and trimmed extra whitespace. 
```r
df_clean$Consumer.complaint.narrative <- df_clean$Consumer.complaint.narrative %>% 
  str_replace_all("[[:punct:]]", "") %>%  
  str_replace_all("[[:digit:]]", "") %>%  
  str_squish()
```
3. **Removed stopwords** – Eliminated common English stopwords (e.g., "the", "and").
```r
df_clean <- df_clean %>% 
  mutate(Consumer.complaint.narrative = removeWords(Consumer.complaint.narrative, stop_words$word))
```
4. **Tokenization** – Split complaints into individual words for analysis.
```r
df_tokens <- df_clean %>% 
  unnest_tokens(word, Consumer.complaint.narrative)
```

5. **Filtered unwanted placeholders: Removed placeholder terms like "XXXX".)**.
```r
df_tokens <- df_tokens %>% 
  filter(!str_detect(word, "^x+$"))
```

## Data Analysis
### 1. ***Word Cloud***

<div align="center">
<img src="images/wordcloud.png" width="500">
</div>

#### **Why This Chart?**
The word cloud highlights the most frequent terms in consumer complaints. Larger words indicate higher frequency, providing a quick visual summary of common issues (e.g., "credit", "account", "payment").
```r
wordcloud(words = df_wordcloud$word, min.freq = 50, max.words = 200, 
          colors = brewer.pal(8, "Dark2"), scale = c(3, 0.5))
```
