# app.R

# load libraries
library(shiny)
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)
library(leaflet)
library(caret)

# grab data from GitHub
master_url <- "https://raw.githubusercontent.com/kritansth/data332/main/uber/master_data.rds"
tf <- tempfile(fileext = ".rds")
download.file(master_url, tf, mode = "wb")
uber_raw <- readRDS(tf)
unlink(tf)

# add week-of-month
uber_raw <- uber_raw %>%
  mutate(WeekOfMonth = ceiling(Day / 7))

# set factor levels
month_levels <- c("Apr","May","Jun","Jul","Aug","Sep")
wday_levels  <- c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")

# train simple lm model on hourly/weekday/monthly counts
model_data <- uber_raw %>%
  count(Hour, Wday, Month) %>%
  mutate(
    Wday_num  = as.integer(factor(Wday,  levels = wday_levels)),
    Month_num = as.integer(factor(Month, levels = month_levels))
  )
set.seed(123)
pred_model <- train(n ~ Hour + Wday_num + Month_num,
                    data   = model_data,
                    method = "lm")

# UI
ui <- fluidPage(
  titlePanel("NYC Uber 2014 Dashboard"),
  sidebarLayout(
    sidebarPanel(
      selectInput("months", "Months:", month_levels,
                  selected = month_levels, multiple = TRUE),
      selectInput("bases",  "Bases:",  sort(unique(uber_raw$Base)),
                  selected = sort(unique(uber_raw$Base)), multiple = TRUE),
      hr(),
      h4("Predict rides"),
      selectInput("pred_hour",  "Hour:",   choices = 0:23, selected = 17),
      selectInput("pred_wday",  "Weekday:", choices = wday_levels, selected = "Wednesday"),
      selectInput("pred_month", "Month:",   choices = month_levels, selected = "Jul"),
      actionButton("goPred", "Predict")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("By Hour",
                 plotOutput("plot_hour"),
                 plotOutput("plot_hour_month")
        ),
        tabPanel("By Day",
                 plotOutput("plot_day"),
                 plotOutput("plot_wday_month")
        ),
        tabPanel("Month & Base",
                 plotOutput("plot_month"),
                 plotOutput("plot_base_month")
        ),
        tabPanel("Heatmaps",
                 plotOutput("heat1"),
                 plotOutput("heat2"),
                 plotOutput("heat3"),
                 plotOutput("heat4")
        ),
        tabPanel("Map",
                 leafletOutput("map", height = 500)
        ),
        tabPanel("Predictor",
                 verbatimTextOutput("pred_text")
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  # subset data based on filters
  df <- reactive({
    uber_raw %>%
      filter(Month %in% input$months,
             Base  %in% input$bases)
  })
  
  # 1) trips every hour
  output$plot_hour <- renderPlot({
    d <- df() %>% count(Hour) %>% arrange(Hour)
    ggplot(d, aes(Hour, n)) +
      geom_col(fill = "steelblue") +
      scale_x_continuous(breaks = 0:23) +
      scale_y_continuous(labels = comma, breaks = pretty_breaks(5)) +
      labs(x = "Hour", y = "Trips") +
      theme_minimal()
  })
  
  # 2) trips by hour & month
  output$plot_hour_month <- renderPlot({
    d <- df() %>%
      count(Month, Hour) %>%
      mutate(Month = factor(Month, levels = month_levels))
    ggplot(d, aes(Hour, n, color = Month, group = Month)) +
      geom_line(linewidth = 1) + geom_point(size = 1.5) +
      labs(x = "Hour", y = "Trips") +
      theme_minimal() +
      theme(legend.position = "bottom")
  })
  
  # 3) trips by day of month
  output$plot_day <- renderPlot({
    d <- df() %>% count(Day) %>% arrange(Day)
    ggplot(d, aes(Day, n)) +
      geom_col(fill = "coral") +
      scale_x_continuous(breaks = 1:31) +
      scale_y_continuous(labels = comma, breaks = pretty_breaks(5)) +
      labs(x = "Day", y = "Trips") +
      theme_minimal()
  })
  
  # 4) trips by weekday & month (facets)
  output$plot_wday_month <- renderPlot({
    d <- df() %>%
      count(Wday, Month) %>%
      mutate(
        Wday  = factor(Wday, levels = wday_levels),
        Month = factor(Month, levels = month_levels)
      )
    ggplot(d, aes(Wday, n)) +
      geom_col(fill = "steelblue") +
      facet_wrap(~Month, ncol = 3) +
      scale_y_continuous(labels = comma, breaks = pretty_breaks(5)) +
      labs(x = "Weekday", y = "Trips") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # 5) trips by month
  output$plot_month <- renderPlot({
    d <- df() %>% count(Month) %>% mutate(Month = factor(Month, levels = month_levels))
    ggplot(d, aes(Month, n)) +
      geom_col(fill = "darkgreen") +
      scale_y_continuous(labels = comma, breaks = pretty_breaks(5)) +
      labs(x = "Month", y = "Trips") +
      theme_minimal()
  })
  
  # 6) trips by base & month (faceted)
  output$plot_base_month <- renderPlot({
    d <- df() %>%
      count(Base, Month) %>%
      mutate(Month = factor(Month, levels = month_levels))
    ggplot(d, aes(Base, n, fill = Base)) +
      geom_col() +
      facet_wrap(~Month, ncol = 3) +
      theme_minimal() +
      theme(
        legend.position = "none",
        axis.text.x     = element_text(angle = 45, hjust = 1)
      )
  })
  
  # 7) heatmap 1: hour vs weekday
  output$heat1 <- renderPlot({
    d <- df() %>%
      count(Hour, Wday) %>%
      mutate(Wday = factor(Wday, levels = rev(wday_levels)))
    ggplot(d, aes(Hour, Wday, fill = n)) +
      geom_tile() +
      scale_x_continuous(breaks = seq(0,23,2)) +
      labs(x = "Hour", y = "Weekday") +
      theme_minimal()
  })
  
  # 8) heatmap 2: day vs month
  output$heat2 <- renderPlot({
    d <- df() %>%
      mutate(Month = factor(Month, levels = rev(month_levels))) %>%
      count(Day, Month)
    ggplot(d, aes(Day, Month, fill = n)) +
      geom_tile() +
      scale_x_continuous(breaks = seq(1,31,5)) +
      theme_minimal()
  })
  
  # 9) heatmap 3: week-of-month vs month
  output$heat3 <- renderPlot({
    d <- df() %>%
      mutate(
        WoM   = factor(ceiling(Day/7), levels = 1:5),
        Month = factor(Month, levels = rev(month_levels))
      ) %>%
      count(WoM, Month)
    ggplot(d, aes(WoM, Month, fill = n)) +
      geom_tile() +
      theme_minimal()
  })
  
  # 10) heatmap 4: base vs weekday
  output$heat4 <- renderPlot({
    d <- df() %>%
      count(Base, Wday) %>%
      mutate(
        Base = factor(Base, levels = rev(sort(unique(Base)))),
        Wday = factor(Wday, levels = wday_levels)
      )
    ggplot(d, aes(Wday, Base, fill = n)) +
      geom_tile() +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # 11) map of pickup points
  output$map <- renderLeaflet({
    rows      <- sample(seq_len(nrow(df())), min(50000, nrow(df())))
    sample_df <- df()[rows, ]
    m <- leaflet(sample_df)
    m <- addTiles(m)
    m <- addCircleMarkers(
      m,
      lng            = ~Lon,
      lat            = ~Lat,
      radius         = 4,
      stroke         = FALSE,
      fillOpacity    = 0.4,
      clusterOptions = markerClusterOptions()
    )
    setView(m,
            lng  = mean(sample_df$Lon, na.rm = TRUE),
            lat  = mean(sample_df$Lat, na.rm = TRUE),
            zoom = 12
    )
  })
  
  # 12) ride-count predictor (fix types)
  ride_pred <- eventReactive(input$goPred, {
    hr <- as.numeric(input$pred_hour)
    wd <- as.integer(factor(input$pred_wday,  levels = wday_levels))
    mo <- as.integer(factor(input$pred_month, levels = month_levels))
    predict(pred_model,
            newdata = data.frame(
              Hour      = hr,
              Wday_num  = wd,
              Month_num = mo
            ))
  })
  
  # show prediction
  output$pred_text <- renderText({
    req(input$goPred)
    paste0("Estimated rides: ", round(ride_pred()))
  })
}

# launch app
shinyApp(ui, server)

