# ExA ###
# Preparation ####
# load libraries 
library("readr")
library("sf")
library("dplyr")
library("tmap")

# Task 1 ####
# load data
wildschwein_BE <- read_delim("wildschwein_BE_2056.csv", ",")
wildschwein_BE <- st_as_sf(wildschwein_BE, coords = c("E", "N"), crs = 2056)

# Task 2 ####
# Calculate time difference between subsequent rows using function
difftime_secs <- function(later, now){
  as.numeric(difftime(later, now, units = "secs"))
}

now <- wildschwein_BE$DatetimeUTC
later <- lead(now)
wildschwein_BE$timelag_sec <- difftime_secs(later, now)
wildschwein_BE

# drop geometry for faster summary
wildschwein_pure <- st_drop_geometry(wildschwein_BE)


# getting additional info
wildschwein_pure |> 
  group_by(TierName) |> 
  summarise(min=min(DatetimeUTC, na.rm = TRUE), 
            max=max(DatetimeUTC, na.rm = TRUE), 
            mean=mean(timelag_sec, na.rm = TRUE), 
            median=median(timelag_sec, na.rm=TRUE),
            maxlag=max(timelag_sec, na.rm = TRUE))
# How many individuals were tracked?
# tree individuals were tracked
# For how long were the individual tracked? Are there gaps?
# Rosa     2014-11-07 07:45:44 2015-06-29 23:45:11 
# Ruth     2014-11-07 18:00:43 2015-07-27 09:45:15 
# Sabi     2014-08-22 21:00:12 2015-07-27 11:00:14 
# Were all individuals tracked concurrently or sequentially?
# concurrently
# What is the temporal sampling interval between the locations?
# 903 / 904 sec

# Task 3 ####
# create later and now for geometry
later <- lag(wildschwein_BE$geometry)
now <- wildschwein_BE$geometry

st_distance(later, now, by_element = TRUE)  # by_element must be set to TRUE

# create function to calculate distance
distance_by_element <- function(later, now){
  as.numeric(
    st_distance(later, now, by_element = TRUE)
  )
}  
# calculate steplength between locations
wildschwein_BE$steplength <- distance_by_element(later, now)
wildschwein_BE

# Task 4 ####
# calculate speed based on timelag and steplength
wildschwein_BE$speed <- wildschwein_BE$steplength/wildschwein_BE$timelag_sec
wildschwein_BE

# Task 5 ####
# check plausibility
wildschwein_sample <- wildschwein_BE |>
  filter(TierName == "Sabi") |> 
  head(100)

tmap_mode("view")

tm_shape(wildschwein_sample) + 
  tm_dots()

wildschwein_sample_line <- wildschwein_sample |> 
  # dissolve to a MULTIPOINT:
  summarise(do_union = FALSE) |> 
  st_cast("LINESTRING")

tmap_options(basemaps = "OpenStreetMap")

tm_shape(wildschwein_sample_line) +
  tm_lines() +
  tm_shape(wildschwein_sample) + 
  tm_dots()
