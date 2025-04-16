# load the necessary libraries
library(readxl)
library(dplyr)
library(shiny)
library(DT)
library(ggplot2)
library(httr)

data_url <- "https://raw.githubusercontent.com/amatya02/abhib_data332/e81ab10c1ef51322c1586d76e71c1f45487ae226/counting_cars/cars_count.xlsx"

# download to a temp file

tmp <- tempfile(fileext = ".xlsx")
GET(data_url, write_disk(tmp, overwrite = TRUE))

aashish <- read_excel(tmp, sheet = "Aashish")
abhib   <- read_excel(tmp, sheet = "Abhib")
kritan  <- read_excel(tmp, sheet = "Kritan")

# statistical summaries

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

# performing ANOVA one-way ANOVA to compare the means of the speed variables (Initial_Speed, Final_Speed, and Difference). 
# If the ANOVA tests show non-significant results (p-value > 0.05), it suggests that 
# the date/time might not have a strong effect on the car speeds, supporting the idea of combining the data.

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

# drop Group for combined analysis
df_combined <- combined_data %>% select(-Group)

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
