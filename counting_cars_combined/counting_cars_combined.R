# load the necessary libraries
library(readxl)
library(dplyr)
library(shiny)
library(DT)
library(ggplot2)
library(httr)

# Set working directory
setwd('~/Documents/r_projects/counting_cars_combined/combined_data')

# Load original Excel data from three group members
aashish <- read_excel("cars_count.xlsx", sheet = "Aashish")
abhib   <- read_excel("cars_count.xlsx", sheet = "Abhib")
kritan  <- read_excel("cars_count.xlsx", sheet = "Kritan")

# Load additional class data (two files only)
csv_data <- read.csv("Counting_Cars.csv")
excel_data <- read_excel("speed_counting_cars.xlsx", sheet = "Sheet1")

# Clean and standardize the CSV dataset
csv_data_clean <- csv_data %>%
  rename(
    Initial_Speed = Initial_Read,
    Final_Speed = Final_Read,
    Difference = Difference_In_Readings,
    Body_Style = Type_of_Car
  ) %>%
  select(Initial_Speed, Final_Speed, Difference, Body_Style) %>%
  mutate(
    Body_Style = recode(as.character(Body_Style),
                        "1" = "Emergency",
                        "2" = "Hatchback",
                        "3" = "Sedan",
                        "4" = "SUV",
                        "5" = "Van",
                        "6" = "Minivan",
                        "7" = "Motorcycle",
                        "8" = "Coupe",
                        "9" = "Truck",
                        "10" = "Pickup Truck"
    ),
    # Combine categories
    Body_Style = case_when(
      Body_Style %in% c("Hatchback", "Sedan", "Coupe") ~ "Sedan",
      Body_Style %in% c("SUV", "Van", "Minivan") ~ "SUV",
      Body_Style %in% c("Truck", "Pickup Truck") ~ "Truck",
      TRUE ~ Body_Style
    )
  )


# Clean and standardize the Excel dataset
excel_data_clean <- excel_data %>%
  rename(
    Initial_Speed = init_speed,
    Final_Speed = final_speed,
    Difference = speed_change,
    Body_Style = vehicle_type
  ) %>%
  select(Initial_Speed, Final_Speed, Difference, Body_Style)

# Combine all five datasets
combined_data <- bind_rows(
  aashish %>% mutate(Source = "Aashish"),
  abhib %>% mutate(Source = "Abhib"),
  kritan %>% mutate(Source = "Kritan"),
  csv_data_clean %>% mutate(Source = "CSV_Tanner"),
  excel_data_clean %>% mutate(Source = "Excel_Basil")
)

# View the structure (optional)
str(combined_data)

# statistical summaries
compute_stats <- function(data, sheet_name) {
  cat("Summary statistics for", sheet_name, "sheet:\n")
  cat("Initial_Speed - Mean:", mean(data$Initial_Speed, na.rm = TRUE),
      "Median:", median(data$Initial_Speed, na.rm = TRUE),
      "Min:", min(data$Initial_Speed, na.rm = TRUE),
      "Max:", max(data$Initial_Speed, na.rm = TRUE), "\n")
  cat("Final_Speed   - Mean:", mean(data$Final_Speed, na.rm = TRUE),
      "Median:", median(data$Final_Speed, na.rm = TRUE),
      "Min:", min(data$Final_Speed, na.rm = TRUE),
      "Max:", max(data$Final_Speed, na.rm = TRUE), "\n")
  cat("Difference    - Mean:", mean(data$Difference, na.rm = TRUE),
      "Median:", median(data$Difference, na.rm = TRUE),
      "Min:", min(data$Difference, na.rm = TRUE),
      "Max:", max(data$Difference, na.rm = TRUE), "\n")
  cat("------------------------------------------------------------\n")
}

compute_stats(combined_data, "All Combined Data")

# ANOVA comparisons using full combined data
anova_initial <- aov(Initial_Speed ~ Source, data = combined_data)
summary(anova_initial)

anova_final <- aov(Final_Speed ~ Source, data = combined_data)
summary(anova_final)

anova_diff <- aov(Difference ~ Source, data = combined_data)
summary(anova_diff)

# Combined dataset for shiny app
df_combined <- combined_data
speed_limit <- 30

# create shiny app
ui <- fluidPage(
  titlePanel("Counting Cars Project"),
  tags$h4("Collected at 30th Street"),
  sidebarLayout(
    sidebarPanel(
      selectInput("variable", "Select Variable:",
                  choices = c("Initial_Speed", "Final_Speed", "Difference")),
      tags$p(strong("Speed limit is 30 mph"))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Distribution",
                 plotOutput("histPlot"),
                 tableOutput("summaryTable")
        ),
        tabPanel("Exceedance",
                 plotOutput("barInitial"),
                 plotOutput("barFinal"),
                 plotOutput("propInitial"),
                 plotOutput("propFinal"),
                 plotOutput("distInitial"),
                 plotOutput("distFinal")
        ),
        tabPanel("Slowdown",
                 tableOutput("slowdownTable"),
                 plotOutput("slowdownBar")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  df <- df_combined
  
  output$histPlot <- renderPlot({
    var <- input$variable
    m   <- mean(df[[var]], na.rm = TRUE)
    med <- median(df[[var]], na.rm = TRUE)
    ggplot(df, aes_string(x = var)) +
      geom_histogram(fill = "lightblue", color = "black", bins = 30) +
      geom_vline(xintercept = m, linetype = "dashed", color = "red") +
      geom_vline(xintercept = med, linetype = "dotted", color = "darkgreen") +
      labs(title = paste(var, "Distribution"), x = var, y = "Count") +
      theme_minimal()
  })
  
  output$summaryTable <- renderTable({
    var <- input$variable
    data.frame(
      Statistic = c("Mean", "Median", "Min", "Max"),
      Value = c(mean(df[[var]], na.rm = TRUE),
                median(df[[var]], na.rm = TRUE),
                min(df[[var]], na.rm = TRUE),
                max(df[[var]], na.rm = TRUE))
    )
  })
  
  exceed_df <- df %>%
    mutate(
      ExceedInitial = Initial_Speed > speed_limit,
      ExceedFinal   = Final_Speed > speed_limit
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
      scale_fill_manual(values = c("TRUE" = "#d9534f", "FALSE" = "#5bc0de"),
                        labels = c("Not Exceed", "Exceed")) +
      labs(title = "Initial: Proportion Exceeding", x = "Type", y = "Proportion") + theme_minimal()
  })
  
  output$propFinal <- renderPlot({
    exceed_df %>% count(Body_Style, ExceedFinal) %>% group_by(Body_Style) %>%
      mutate(prop = n / sum(n)) %>%
      ggplot(aes(Body_Style, prop, fill = ExceedFinal)) + geom_col() +
      scale_fill_manual(values = c("TRUE" = "#d9534f", "FALSE" = "#5bc0de"),
                        labels = c("Not Exceed", "Exceed")) +
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
  
  slowdown_df <- df %>%
    mutate(SlowDown = Final_Speed < Initial_Speed) %>%
    group_by(Body_Style) %>%
    summarise(
      Count_Slowdown = sum(SlowDown, na.rm = TRUE),
      Total_Vehicles = n(),
      Proportion_Slow = Count_Slowdown / Total_Vehicles
    )
  
  output$slowdownTable <- renderTable(slowdown_df)
  
  output$slowdownBar <- renderPlot({
    ggplot(slowdown_df, aes(x = Body_Style, y = Proportion_Slow, fill = Body_Style)) +
      geom_col() +
      labs(title = "Proportion of Vehicles Slowing Down", x = "Type", y = "Proportion") +
      scale_y_continuous(labels = scales::percent) + theme_minimal()
  })
}

# Run the app
shinyApp(ui, server)


