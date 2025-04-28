# app.R

# ── Libraries ─────────────────────────────────────────────────────────
library(readxl)
library(dplyr)
library(shiny)
library(ggplot2)
library(httr)
library(scales)

# ── Load master data from your GitHub ────────────────────────────────
data_url <- "https://raw.githubusercontent.com/kritansth/data332/b9960d348786acb381be074978af4359cddb9770/counting_cars_combined/master_data.xlsx"
tmp      <- tempfile(fileext = ".xlsx")
GET(data_url, write_disk(tmp, overwrite = TRUE))
df       <- read_excel(tmp)

# ── Speed limit ──────────────────────────────────────────────────────
speed_limit <- 30

# ── UI ───────────────────────────────────────────────────────────────
ui <- fluidPage(
  titlePanel("Counting Cars Project"),
  sidebarLayout(
    sidebarPanel(
      selectInput("variable", "Select Variable:",
                  choices = c("Initial_Speed", "Final_Speed", "Difference")),
      tags$p(strong("Speed limit is 30 mph"))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Histogram & Summary",
                 plotOutput("histPlot"),
                 tableOutput("summaryTable")
        ),
        tabPanel("Comparison",
                 h4("Summary Statistics by Vehicle Type"),
                 tableOutput("comparisonTable")
        ),
        tabPanel("Exceedance",
                 h4("Counts Exceeding 30 mph by Type"),
                 plotOutput("barInitial"), plotOutput("barFinal"),
                 h4("Proportions"),
                 plotOutput("propInitial"), plotOutput("propFinal"),
                 h4("Density"),
                 plotOutput("distInitial"), plotOutput("distFinal")
        ),
        tabPanel("Slowdown",
                 h4("Vehicles Slowing Down After Radar by Type"),
                 tableOutput("slowdownTable"), plotOutput("slowdownBar")
        )
      )
    )
  )
)

# ── Server ───────────────────────────────────────────────────────────
server <- function(input, output, session) {
  var <- reactive(input$variable)
  
  # Histogram & summary table
  output$histPlot <- renderPlot({
    vals <- df[[var()]]
    ggplot(df, aes_string(x = var())) +
      geom_histogram(bins = 30, fill = "lightblue", color = "black") +
      geom_vline(xintercept = mean(vals, na.rm = TRUE), linetype = "dashed") +
      geom_vline(xintercept = median(vals, na.rm = TRUE), linetype = "dotted") +
      labs(title = paste(var(), "Distribution"), x = var(), y = "Count") +
      theme_minimal()
  })
  output$summaryTable <- renderTable({
    vals <- df[[var()]]
    data.frame(
      Statistic = c("Mean","Median","Min","Max"),
      Value     = c(mean(vals,na.rm=TRUE),
                    median(vals,na.rm=TRUE),
                    min(vals,na.rm=TRUE),
                    max(vals,na.rm=TRUE))
    )
  })
  
  # Comparison by Body_Style
  output$comparisonTable <- renderTable({
    df %>%
      group_by(Body_Style) %>%
      summarise(
        Mean   = mean(.data[[var()]], na.rm = TRUE),
        Median = median(.data[[var()]], na.rm = TRUE)
      ) %>%
      ungroup()
  })
  
  # Precompute exceedance flags
  exceed_df <- df %>%
    mutate(
      ExceedInitial = Initial_Speed > speed_limit,
      ExceedFinal   = Final_Speed   > speed_limit
    )
  
  # Exceedance plots
  output$barInitial <- renderPlot({
    exceed_df %>%
      filter(ExceedInitial) %>%
      count(Body_Style) %>%
      ggplot(aes(Body_Style, n, fill = Body_Style)) +
      geom_col() +
      labs(title = "Initial Speed Exceedances", x = "Type", y = "Count") +
      theme_minimal()
  })
  output$barFinal <- renderPlot({
    exceed_df %>%
      filter(ExceedFinal) %>%
      count(Body_Style) %>%
      ggplot(aes(Body_Style, n, fill = Body_Style)) +
      geom_col() +
      labs(title = "Final Speed Exceedances", x = "Type", y = "Count") +
      theme_minimal()
  })
  output$propInitial <- renderPlot({
    exceed_df %>%
      count(Body_Style, ExceedInitial) %>%
      group_by(Body_Style) %>%
      mutate(prop = n/sum(n)) %>%
      ggplot(aes(Body_Style, prop, fill = ExceedInitial)) +
      geom_col(position = "dodge") +
      scale_y_continuous(labels = percent_format()) +
      theme_minimal()
  })
  output$propFinal <- renderPlot({
    exceed_df %>%
      count(Body_Style, ExceedFinal) %>%
      group_by(Body_Style) %>%
      mutate(prop = n/sum(n)) %>%
      ggplot(aes(Body_Style, prop, fill = ExceedFinal)) +
      geom_col(position = "dodge") +
      scale_y_continuous(labels = percent_format()) +
      theme_minimal()
  })
  
  # Density plots
  output$distInitial <- renderPlot({
    ggplot(exceed_df, aes(Initial_Speed, color = Body_Style, fill = Body_Style)) +
      geom_density(alpha = 0.3) +
      geom_vline(xintercept = speed_limit, linetype = "dashed") +
      theme_minimal()
  })
  output$distFinal <- renderPlot({
    ggplot(exceed_df, aes(Final_Speed, color = Body_Style, fill = Body_Style)) +
      geom_density(alpha = 0.3) +
      geom_vline(xintercept = speed_limit, linetype = "dashed") +
      theme_minimal()
  })
  
  # Slowdown analysis
  slowdown_df <- df %>%
    mutate(SlowDown = Final_Speed < Initial_Speed) %>%
    group_by(Body_Style) %>%
    summarise(
      Count_Slowdown  = sum(SlowDown, na.rm = TRUE),
      Total_Vehicles  = n(),
      Proportion_Slow = Count_Slowdown / Total_Vehicles
    ) %>%
    ungroup()
  output$slowdownTable <- renderTable(slowdown_df)
  output$slowdownBar   <- renderPlot({
    ggplot(slowdown_df, aes(Body_Style, Proportion_Slow, fill = Body_Style)) +
      geom_col() +
      scale_y_continuous(labels = percent_format()) +
      labs(title = "Proportion of Vehicles Slowing Down", x = "Type", y = "Proportion") +
      theme_minimal()
  })
}

# Run the app
shinyApp(ui, server)

