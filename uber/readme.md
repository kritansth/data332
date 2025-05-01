# NYC Uber 2014 Dashboard

## Live App
https://yourname.shinyapps.io/uber2014/

---

## Load the Data
```r
master_url <- "https://raw.githubusercontent.com/kritansth/data332/main/uber/master_data.rds"
tf <- tempfile(fileext = ".rds")
download.file(master_url, tf, mode = "wb")
uber_raw <- readRDS(tf)
