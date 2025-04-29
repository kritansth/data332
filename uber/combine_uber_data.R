# combine_data_simple.R

setwd("~/Documents/r_projects/uber")  

files <- list.files(pattern = "^uber-raw-data-.*\\.csv$")

# Read each into a list:
data_list <- lapply(files, function(f) {
  read.csv(f, stringsAsFactors = FALSE)
})

# Row-bind into one big data.frame:
uber_raw <- do.call(rbind, data_list)

# Convert the Date.Time column and extract components:
uber_raw$Date.Time <- as.POSIXct(
  uber_raw$Date.Time,
  format = "%m/%d/%Y %H:%M:%S"
)
uber_raw$Hour  <- as.numeric(format(uber_raw$Date.Time, "%H"))
uber_raw$Day   <- as.numeric(format(uber_raw$Date.Time, "%d"))
uber_raw$Wday  <- weekdays(uber_raw$Date.Time)     # e.g. "Monday"
uber_raw$Month <- format(uber_raw$Date.Time, "%b")  # e.g. "Apr"

# Write out the single master file:
write.csv(uber_raw, "master_data.csv", row.names = FALSE)

# save as a compressed RDS
saveRDS(uber_raw, file = "master_data.rds", compress = "xz")

# check file size to upload to github
file.info("master_data.rds")$size / 1024^2  # prints MB
