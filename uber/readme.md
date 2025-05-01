# NYC Uber 2014 Dashboard

## Live App
https://kritanshrestha.shinyapps.io/uber/

---

## Load the Data
```r
master_url <- "https://raw.githubusercontent.com/kritansth/data332/main/uber/master_data.rds"
tf <- tempfile(fileext = ".rds")
download.file(master_url, tf, mode = "wb")
uber_raw <- readRDS(tf)
```

---

## Example Pivot & Plot
```r
trips_by_hour <- uber_raw %>% 
  count(Hour)

ggplot(trips_by_hour, aes(Hour, n)) +
  geom_col(fill = "steelblue") +
  labs(
    x = "Hour of Day",
    y = "Number of Trips"
  )
```

---

## Leaflet Map Snippet
```r
leaflet(uber_raw %>% sample_n(50000)) %>%
  addTiles() %>%
  addCircleMarkers(
    lng            = ~Lon,
    lat            = ~Lat,
    clusterOptions = markerClusterOptions()
  )
```

---

## Prediction Model
```r
pred_model <- train(
  n ~ Hour + Wday_num + Month_num,
  data   = model_data,
  method = "lm"
)
```
