# app.R

# ── Libraries ────────────────────────────────────────────────────────────────
library(shiny)
library(dplyr)
library(lubridate)
library(ggplot2)
library(scales)
library(leaflet)
library(caret)

# ── Load the combined data ───────────────────────────────────────────────────
master_url <- "https://raw.githubusercontent.com/kritansth/data332/main/uber/master_data.rds"
tf <- tempfile(fileext = ".rds")
download.file(master_url, tf, mode = "wb")
uber_raw <- readRDS(tf)
unlink(tf)

# ── Add Week-of-Month for heatmap ─────────────────────────────────────────────
uber_raw <- uber_raw %>% mutate(WeekOfMonth = ceiling(Day/7))

# ── Factor levels for ordered plots ──────────────────────────────────────────
month_levels <- c("Apr","May","Jun","Jul","Aug","Sep")
wday_levels  <- c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")

# ── Train a simple lm predictor ──────────────────────────────────────────────
model_data <- uber_raw %>%
  count(Hour, Wday, Month) %>%
  mutate(
    Wday_num  = as.integer(factor(Wday,  levels = wday_levels)),
    Month_num = as.integer(factor(Month, levels = month_levels))
  )
set.seed(123)
pred_model <- train(
  n ~ Hour + Wday_num + Month_num,
  data   = model_data,
  method = "lm"
)

# ── UI ───────────────────────────────────────────────────────────────────────
ui <- fluidPage(
  titlePanel("NYC Uber 2014 Dashboard"),
  tabsetPanel(
    tabPanel("By Hour",
             h4("Trips Every Hour"),            plotOutput("plot_hour"),
             h4("Hourly Ride Patterns by Month"), plotOutput("plot_hour_month")
    ),
    tabPanel("By Day",
             h4("Trips by Day of Month"),       plotOutput("plot_day"),
             h4("Trips by Weekday & Month"),    plotOutput("plot_wday_month")
    ),
    tabPanel("Month & Base",
             h4("Trips by Month"),              plotOutput("plot_month"),
             h4("Trips by Base & Month"),       plotOutput("plot_base_month")
    ),
    tabPanel("Heatmaps",
             h4("Hour vs Weekday"),             plotOutput("heat1"),
             h4("Day vs Month"),                plotOutput("heat2"),
             h4("Week-of-Month vs Month"),      plotOutput("heat3"),
             h4("Base vs Weekday"),             plotOutput("heat4")
    ),
    tabPanel("Map",
             h4("Pickup Locations"),            leafletOutput("map", height = 500)
    ),
    tabPanel("Predictor",
             sidebarLayout(
               sidebarPanel(
                 selectInput("pred_hour",  "Hour:",    choices = 0:23),
                 selectInput("pred_wday",  "Weekday:", choices = wday_levels),
                 selectInput("pred_month", "Month:",   choices = month_levels),
                 actionButton("goPred", "Predict")
               ),
               mainPanel(
                 verbatimTextOutput("pred_text")
               )
             )
    )
  )
)

# ── Server ───────────────────────────────────────────────────────────────────
server <- function(input, output, session) {
  # 1) Trips Every Hour
  output$plot_hour <- renderPlot({
    d <- uber_raw %>% count(Hour) %>% arrange(Hour)
    ggplot(d, aes(Hour, n)) +
      geom_col(fill = "steelblue") +
      scale_x_continuous(breaks = 0:23) +
      scale_y_continuous(labels = comma, breaks = pretty_breaks(5)) +
      labs(x = "Hour", y = "Trips") +
      theme_minimal()
  })
  
  # 2) Trips by Hour & Month
  output$plot_hour_month <- renderPlot({
    d <- uber_raw %>%
      count(Month, Hour) %>%
      mutate(Month = factor(Month, levels = month_levels))
    ggplot(d, aes(Hour, n, color = Month, group = Month)) +
      geom_line(linewidth = 1) + geom_point(size = 1.5) +
      labs(x = "Hour", y = "Trips") +
      theme_minimal() +
      theme(legend.position = "bottom")
  })
  
  # 3) Trips by Day of Month
  output$plot_day <- renderPlot({
    d <- uber_raw %>% count(Day) %>% arrange(Day)
    ggplot(d, aes(Day, n)) +
      geom_col(fill = "coral") +
      scale_x_continuous(breaks = 1:31) +
      scale_y_continuous(labels = comma, breaks = pretty_breaks(5)) +
      labs(x = "Day", y = "Trips") +
      theme_minimal()
  })
  
  # 4) Trips by Weekday & Month (Facets)
  output$plot_wday_month <- renderPlot({
    d <- uber_raw %>%
      count(Wday, Month) %>%
      mutate(
        Wday  = factor(Wday, levels = wday_levels),
        Month = factor(Month, levels = month_levels)
      )
    ggplot(d, aes(Wday, n)) +
      geom_col(fill = "steelblue") +
      facet_wrap(~ Month, ncol = 3) +
      scale_y_continuous(labels = comma, breaks = pretty_breaks(5)) +
      labs(x = "Weekday", y = "Trips") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # 5) Trips by Month
  output$plot_month <- renderPlot({
    d <- uber_raw %>% count(Month) %>% mutate(Month = factor(Month, levels = month_levels))
    ggplot(d, aes(Month, n)) +
      geom_col(fill = "darkgreen") +
      scale_y_continuous(labels = comma, breaks = pretty_breaks(5)) +
      labs(x = "Month", y = "Trips") +
      theme_minimal()
  })
  
  # 6) Trips by Base & Month (Faceted)
  output$plot_base_month <- renderPlot({
    d <- uber_raw %>%
      count(Base, Month) %>%
      mutate(Month = factor(Month, levels = month_levels))
    ggplot(d, aes(Base, n, fill = Base)) +
      geom_col() +
      facet_wrap(~ Month, ncol = 3) +
      theme_minimal() +
      theme(
        legend.position = "none",
        axis.text.x     = element_text(angle = 45, hjust = 1)
      )
  })
  
  # 7) Heatmap: Hour vs Weekday
  output$heat1 <- renderPlot({
    d <- uber_raw %>%
      count(Hour, Wday) %>%
      mutate(Wday = factor(Wday, levels = rev(wday_levels)))
    ggplot(d, aes(Hour, Wday, fill = n)) +
      geom_tile() +
      scale_x_continuous(breaks = seq(0, 23, 2)) +
      labs(x = "Hour", y = "Weekday") +
      theme_minimal()
  })
  
  # 8) Heatmap: Day vs Month
  output$heat2 <- renderPlot({
    d <- uber_raw %>%
      mutate(Month = factor(Month, levels = rev(month_levels))) %>%
      count(Day, Month)
    ggplot(d, aes(Day, Month, fill = n)) +
      geom_tile() +
      scale_x_continuous(breaks = seq(1, 31, 5)) +
      theme_minimal()
  })
  
  # 9) Heatmap: Week-of-Month vs Month
  output$heat3 <- renderPlot({
    d <- uber_raw %>%
      mutate(
        WoM   = factor(ceiling(Day/7), levels = 1:5),
        Month = factor(Month, levels = rev(month_levels))
      ) %>%
      count(WoM, Month)
    ggplot(d, aes(WoM, Month, fill = n)) +
      geom_tile() +
      theme_minimal()
  })
  
  # 10) Heatmap: Base vs Weekday
  output$heat4 <- renderPlot({
    d <- uber_raw %>%
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
  
  # 11) Leaflet map of pickup points (sampled + clustered)
  output$map <- renderLeaflet({
    samp <- sample_n(uber_raw, 50000)
    m <- leaflet(samp) %>% addTiles()
    m <- addCircleMarkers(
      m, lng = ~Lon, lat = ~Lat,
      radius = 4, stroke = FALSE, fillOpacity = 0.4,
      clusterOptions = markerClusterOptions()
    )
    setView(m,
            lng  = mean(samp$Lon, na.rm = TRUE),
            lat  = mean(samp$Lat, na.rm = TRUE),
            zoom = 12
    )
  })
  
  # 12) Ride-count predictor
  ride_pred <- eventReactive(input$goPred, {
    hr <- as.numeric(input$pred_hour)
    wd <- as.integer(factor(input$pred_wday, levels = wday_levels))
    mo <- as.integer(factor(input$pred_month, levels = month_levels))
    predict(pred_model, newdata = data.frame(
      Hour = hr,
      Wday_num = wd,
      Month_num = mo
    ))
  })
  output$pred_text <- renderText({
    req(input$goPred)
    paste0("Estimated rides: ", round(ride_pred()))
  })
}

# ── Run the app ──────────────────────────────────────────────────────────────
shinyApp(ui, server)
