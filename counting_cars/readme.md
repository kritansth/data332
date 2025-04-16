# Counting Cars Project

### An analysis of vehicle speed data collected at 30th Street, Rock Island, IL. 

---

##  Project Overview

### Data Collection:
**When & Where**: Three sessions by Aashish (April 4, 2025 1:05–1:48 PM), Kritan (April 6, 2025 5:36–6:29 PM), and Abhib (April 6, 2025 9:19–10:03 PM) on 30th Street.

**What**: For each passing vehicle we recorded Initial Speed, Final Speed, computed Difference (Initial – Final), and captured Body Style (Sedan, Truck, SUV).

### Data Storage & Access:
All raw Excel sheets live in a public GitHub repository. At app startup we download cars_count.xlsx via its raw‑file URL into a temporary file, then read each sheet with readxl. This ensures the deployed Shiny app always pulls the latest data.

## We built an interactive Shiny application that allows you to:

- **View histograms** and **summary statistics** (mean, median, min, max) for initial speed, final speed, or speed difference, by dataset.  
- **Compare** summary statistics across three collection sessions (Aashish, Kritan, Abhib) and the combined dataset.  
- **Analyze exceedance** of the 30 mph limit by vehicle type (Sedan, Truck, SUV) with counts, proportions, and density plots.  
- **Examine slowdown behavior**, i.e. the proportion of vehicles whose final speed is lower than their initial speed, by type.

---

##  Project Files

- `cars_count.xlsx`: The raw dataset containing timestamped records of cars detected along with their speeds and the car type.
- `counting_cars.R`: The main R script used for loading, cleaning, analyzing, and visualizing the data.

##  Requirements

Make sure the following R packages are installed before running the script:

```r
install.packages(c("readxl", "dplyr", "ggplot2", "shiny", "DT", "httr"))
```

## How to Use
1. Clone this repository or download the files.
2. Open counting_cars.R in RStudio.
3. Ensure cars_count.xlsx is in the same working directory.
4. Run the script to perform:
   - ANOVA Testing
   - Data cleaning
   - Summary statistics
   - Visualization of traffic trends
  
## Loading Data

```r
data_url <- "https://raw.githubusercontent.com/amatya02/abhib_data332/e81ab10c1ef51322c1586d76e71c1f45487ae226/counting_cars/cars_count.xlsx"

# download to a temp file

tmp <- tempfile(fileext = ".xlsx")
GET(data_url, write_disk(tmp, overwrite = TRUE))

aashish <- read_excel(tmp, sheet = "Aashish")
abhib   <- read_excel(tmp, sheet = "Abhib")
kritan  <- read_excel(tmp, sheet = "Kritan")

```
## Statistical Summary

```r
# creating function to compute summary statistics for a given data frame and sheet name
compute_stats <- function(data, sheet_name) {
  # Calculate summary statistics for Initial_Speed
  initial_mean <- mean(data$Initial_Speed, na.rm = TRUE)
  initial_median <- median(data$Initial_Speed, na.rm = TRUE)
  initial_min <- min(data$Initial_Speed, na.rm = TRUE)
  initial_max <- max(data$Initial_Speed, na.rm = TRUE)
  
  # Calculate summary statistics for Final_Speed
  final_mean <- mean(data$Final_Speed, na.rm = TRUE)
  final_median <- median(data$Final_Speed, na.rm = TRUE)
  final_min <- min(data$Final_Speed, na.rm = TRUE)
  final_max <- max(data$Final_Speed, na.rm = TRUE)
  
  # Calculate summary statistics for Difference
  difference_mean <- mean(data$Difference, na.rm = TRUE)
  difference_median <- median(data$Difference, na.rm = TRUE)
  difference_min <- min(data$Difference, na.rm = TRUE)
  difference_max <- max(data$Difference, na.rm = TRUE)
  
  # Print the results
  cat("Summary statistics for", sheet_name, "sheet:\n")
  cat("Initial_Speed - Mean:", initial_mean, 
      "Median:", initial_median, 
      "Min:", initial_min, 
      "Max:", initial_max, "\n")
  cat("Final_Speed   - Mean:", final_mean, 
      "Median:", final_median, 
      "Min:", final_min, 
      "Max:", final_max, "\n")
  cat("Difference    - Mean:", difference_mean, 
      "Median:", difference_median, 
      "Min:", difference_min, 
      "Max:", difference_max, "\n")
  cat("------------------------------------------------------------\n")
}

compute_stats(abhib, "Abhib") # summary of aashish's data collection performed on Sunday 04/06/2025 from 9:19 pm to 10:03 pm.
compute_stats(kritan, "Kritan") # summary of kritan's data collection performed on Sunday 04/06/2025 from 5:36 pm to 6:29 pm.
compute_stats(aashish, "Aashish") # summary of aashish's data collection performed on Friday 04/04/2025 from 1:05 pm to 1:48 pm.
```
### ANOVA Testing:

What is ANOVA Testing?

ANOVA stands for Analysis of Variance, and it’s a statistical technique used to determine whether the means of two or more groups are significantly different from each other.

```r
# Combine the data into one data frame with a new 'Group' column
combined_data <- bind_rows(
  aashish %>% mutate(Group = "Aashish"),
  abhib   %>% mutate(Group = "Abhib"),
  kritan  %>% mutate(Group = "Kritan")
)

# View the combined data structure
head(combined_data)

# One-way ANOVA for Initial_Speed
anova_initial <- aov(Initial_Speed ~ Group, data = combined_data)
summary(anova_initial)

# One-way ANOVA for Final_Speed
anova_final <- aov(Final_Speed ~ Group, data = combined_data)
summary(anova_final)

# One-way ANOVA for Difference
anova_diff <- aov(Difference ~ Group, data = combined_data)
summary(anova_diff)

```

In our ANOVA context, 0.05 is the chosen significance level. 

It represents a 5% risk of falsely declaring a difference “statistically significant” when in truth there is none (i.e. a 5% Type I error rate).

After computing the ANOVA’s p‑value, we compare it to 0.05:

p ≤ 0.05 → reject the null (conclude at least one group mean differs).
p > 0.05 → fail to reject the null (no evidence of difference across groups).

We ran one‑way ANOVAs on Initial Speed, Final Speed, and Difference with Group (Aashish/Kritan/Abhib) as the factor to see if time‑of‑day or date influenced speeds. In every case the p‑value exceeded 0.05, indicating no significant differences across the three sessions—so it was statistically valid to merge all observations into a single dataset for downstream analyses.

<img width="500" alt="Screenshot 2025-04-16 at 4 22 03 PM" src="https://github.com/user-attachments/assets/53455b76-912b-49f8-9e39-07c2f812c1ec" />

---

## Using single combined data set for further analysis and shiny app.

```r
# drop Group for combined analysis
df_combined <- combined_data %>% select(-Group)

```

## Building and Running the Shiny App

```r
# define fixed speed limit
speed_limit <- 30

# create shiny app
ui <- fluidPage(
  titlePanel("Counting Cars Project"),
  tags$h4("Collected at 30th Street"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dataset",  "Select Dataset:",
                  choices = c("Aashish", "Abhib", "Kritan", "Combined")),
      selectInput("variable", "Select Variable:",
                  choices = c("Initial_Speed", "Final_Speed", "Difference")),
      tags$p(strong("Speed limit is 30 mph"))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Individual Analysis",
                 h4(textOutput("dataCollectionInfo")),
                 plotOutput("histPlot"),
                 tableOutput("summaryTable")
        ),
        tabPanel("Comparison",
                 h4("Summary Statistics for Selected Variable by Dataset"),
                 tableOutput("comparisonTable")
        ),
        tabPanel("Exceedance",
                 h4("Counts of Vehicles Exceeding 30 mph by Type"),
                 plotOutput("barInitial"),
                 plotOutput("barFinal"),
                 h4("Proportion Exceeding vs. Not by Type"),
                 plotOutput("propInitial"),
                 plotOutput("propFinal"),
                 h4("Speed Distributions with 30 mph Limit"),
                 plotOutput("distInitial"),
                 plotOutput("distFinal")
        ),
        tabPanel("Slowdown",
                 h4("Vehicles Slowing Down After Radar by Type"),
                 tableOutput("slowdownTable"),
                 plotOutput("slowdownBar")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  selectedData <- reactive({
    switch(input$dataset,
           "Aashish" = aashish,
           "Abhib"   = abhib,
           "Kritan"  = kritan,
           "Combined"= df_combined)
  })
  
  output$dataCollectionInfo <- renderText({
    switch(input$dataset,
           "Aashish"  = "Data collected on 04/04/2025 from 1:05 pm to 1:48 pm.",
           "Kritan"   = "Data collected on 04/06/2025 from 5:36 pm to 6:29 pm.",
           "Abhib"    = "Data collected on 04/06/2025 from 9:19 pm to 10:03 pm.",
           "Combined" = "Combined dataset of all sessions.")
  })
  
  # Individual Analysis
  output$histPlot <- renderPlot({
    df <- selectedData(); var <- input$variable
    m   <- mean(df[[var]], na.rm = TRUE)
    med <- median(df[[var]], na.rm = TRUE)
    ggplot(df, aes_string(x = var)) +
      geom_histogram(fill = "lightblue", color = "black", bins = 30) +
      geom_vline(xintercept = m,   linetype = "dashed", color = "red") +
      geom_vline(xintercept = med, linetype = "dotted", color = "darkgreen") +
      labs(title = paste(var, "in", input$dataset), x = var, y = "Count") +
      theme_minimal()
  })
  output$summaryTable <- renderTable({
    df <- selectedData(); var <- input$variable
    data.frame(
      Statistic = c("Mean", "Median", "Min", "Max"),
      Value = c(mean(df[[var]], na.rm = TRUE),
                median(df[[var]], na.rm = TRUE),
                min(df[[var]], na.rm = TRUE),
                max(df[[var]], na.rm = TRUE))
    )
  })
  
  # Comparison tab
  output$comparisonTable <- renderTable({
    var <- input$variable
    bind_rows(
      data.frame(Dataset = "Aashish", Mean = mean(aashish[[var]], na.rm = TRUE), Median = median(aashish[[var]], na.rm = TRUE)),
      data.frame(Dataset = "Abhib",   Mean = mean(abhib[[var]],   na.rm = TRUE), Median = median(abhib[[var]],   na.rm = TRUE)),
      data.frame(Dataset = "Kritan",  Mean = mean(kritan[[var]],  na.rm = TRUE), Median = median(kritan[[var]],  na.rm = TRUE)),
      data.frame(Dataset = "Combined",Mean = mean(df_combined[[var]],na.rm = TRUE), Median = median(df_combined[[var]],na.rm = TRUE))
    )
  })
  
  # Exceedance tab
  exceed_df <- df_combined %>%
    mutate(
      ExceedInitial = Initial_Speed > speed_limit,
      ExceedFinal   = Final_Speed   > speed_limit
    )
  output$barInitial <- renderPlot({
    exceed_df %>% filter(ExceedInitial) %>% count(Body_Style) %>%
      ggplot(aes(Body_Style, n, fill = Body_Style)) + geom_col() +
      labs(title = "Initial Speed Exceedances", x = "Type", y = "Count") + theme_minimal()
  })
  output$barFinal <- renderPlot({
    exceed_df %>% filter(ExceedFinal) %>% count(Body_Style) %>%
      ggplot(aes(Body_Style, n, fill = Body_Style)) + geom_col() +
      labs(title = "Final Speed Exceedances", x = "Type", y = "Count") + theme_minimal()
  })
  output$propInitial <- renderPlot({
    exceed_df %>% count(Body_Style, ExceedInitial) %>% group_by(Body_Style) %>%
      mutate(prop = n / sum(n)) %>%
      ggplot(aes(Body_Style, prop, fill = ExceedInitial)) + geom_col() +
      scale_fill_manual(values = c("TRUE" = "#d9534f","FALSE" = "#5bc0de"),
                        labels = c("Not Exceed","Exceed")) +
      labs(title = "Initial: Proportion Exceeding", x = "Type", y = "Proportion") + theme_minimal()
  })
  output$propFinal <- renderPlot({
    exceed_df %>% count(Body_Style, ExceedFinal) %>% group_by(Body_Style) %>%
      mutate(prop = n / sum(n)) %>%
      ggplot(aes(Body_Style, prop, fill = ExceedFinal)) + geom_col() +
      scale_fill_manual(values = c("TRUE" = "#d9534f","FALSE" = "#5bc0de"),
                        labels = c("Not Exceed","Exceed")) +
      labs(title = "Final: Proportion Exceeding", x = "Type", y = "Proportion") + theme_minimal()
  })
  
  output$distInitial <- renderPlot({
    ggplot(exceed_df, aes(Initial_Speed, color = Body_Style, fill = Body_Style)) +
      geom_density(alpha = 0.3) + geom_vline(xintercept = speed_limit, linetype = "dashed", color = "red") +
      labs(title = "Initial Speed Distribution", x = "Speed (mph)", y = "Density") + theme_minimal()
  })
  output$distFinal <- renderPlot({
    ggplot(exceed_df, aes(Final_Speed, color = Body_Style, fill = Body_Style)) +
      geom_density(alpha = 0.3) + geom_vline(xintercept = speed_limit, linetype = "dashed", color = "red") +
      labs(title = "Final Speed Distribution", x = "Speed (mph)", y = "Density") + theme_minimal()
  })
  
  # Slowdown analysis tab
  slowdown_df <- df_combined %>%
    mutate(SlowDown = Final_Speed < Initial_Speed) %>%
    group_by(Body_Style) %>%
    summarise(
      Count_Slowdown  = sum(SlowDown, na.rm = TRUE),
      Total_Vehicles  = n(),
      Proportion_Slow = Count_Slowdown / Total_Vehicles
    )
  output$slowdownTable <- renderTable(slowdown_df)
  output$slowdownBar   <- renderPlot({
    ggplot(slowdown_df, aes(x = Body_Style, y = Proportion_Slow, fill = Body_Style)) +
      geom_col() +
      labs(title = "Proportion of Vehicles Slowing Down", x = "Type", y = "Proportion") +
      scale_y_continuous(labels = scales::percent) + theme_minimal()
  })
}

# Run the app
shinyApp(ui, server)
```

## Click the link below to visit our interactive Shiny App

https://amatya02.shinyapps.io/counting_cars/

## Key Analysis

**Individual Analysis**

- Histogram of your chosen variable (Initial_Speed, Final_Speed or Difference), with vertical lines for the mean (red dashed) and median (green dotted).

- Summary table showing mean, median, min and max for that variable in the selected dataset.

- Collection metadata (date/time) displayed above, so you always know which session you’re looking at.

**Comparison**

- Summary table that lines up the mean and median of the selected variable across all four datasets (Aashish, Abhib, Kritan, Combined), making it easy to spot any shifts in central tendency.

**Exceedance of 30 mph**

- Bar charts of raw counts by vehicle type (Sedan, Truck, SUV) showing how many exceeded 30 mph on initial pass and on final pass.

- Stacked‑bar proportions illustrating, for each type, the share that did and did not exceed the limit.

- Density plots of the full speed distributions (initial and final) with a red dashed line at 30 mph—so you can see how tightly each type clusters around the limit.

**Slowdown Behavior**

- Table summarizing, by vehicle type, how many cars slowed down (Final_Speed < Initial_Speed), total vehicles, and the resulting proportion.

- Bar chart of those proportions (with percent axis) to compare “do SUVs actually brake more than Sedans or Trucks?”

