# ExB ####
# Libraries
library("readr")
library("sf")
library("dplyr")
library("ggplot2")
library("tidyr")

# Functions
difftime_secs <- function(x, y){
  as.numeric(difftime(x, y, units = "secs"))
}

distance_by_element <- function(later, now){
  as.numeric(
    st_distance(later, now, by_element = TRUE)
  )
}
# Task 1 ####
# load data
caro <- read_delim("caro60.csv", ",") |>
  st_as_sf(coords = c("E","N"), crs = 2056) |> 
  select(DatetimeUTC)

# assume a sampling window of 120 seconds
now_t <- caro$DatetimeUTC
later_t <- lead(now_t, n = 2)

caro$timelag <- difftime_secs(later_t, now_t)

now_s <- caro$geometry
later_s <- lag(caro$geometry, n = 2)

caro$steplength <- distance_by_element(later_s, now_s)

caro$speed <- caro$steplength / caro$timelag
caro

# Task 2 ####
# assume a sampling window of 240 seconds
now_t <- caro$DatetimeUTC
later_t2 <- lead(now_t, n = 4)

caro$timelag2 <- difftime_secs(later_t2, now_t)

now_s <- caro$geometry
later_s2 <- lag(caro$geometry, n = 4)

caro$steplength2 <- distance_by_element(later_s2, now_s)

caro$speed2 <- caro$steplength2 / caro$timelag2
caro

# Task 3 ####
# assume a sampling window of 480 seconds
now_t <- caro$DatetimeUTC
later_t3 <- lead(now_t, n = 8)

caro$timelag3 <- difftime_secs(later_t3, now_t)

now_s <- caro$geometry
later_s3 <- lag(caro$geometry, n = 8)

caro$steplength3 <- distance_by_element(later_s3, now_s)

caro$speed3 <- caro$steplength3 / caro$timelag3
caro
caro |> 
  st_drop_geometry() |> 
  select(timelag3, steplength3, speed3)

# Task 4 ####
# compare speed across scales
caro |> 
  st_drop_geometry() |> 
  select(DatetimeUTC, speed, speed2, speed3)

# plot results


ggplot(caro, aes(y = speed)) + 
  # we remove outliers to increase legibility, analogue
  # Laube and Purves (2011)
  geom_boxplot(outlier.shape = NA)



# before pivoting, let's simplify our data.frame
caro2 <- caro |> 
  st_drop_geometry() |> 
  select(DatetimeUTC, speed, speed2, speed3)

caro_long <- caro2 |> 
  pivot_longer(c(speed, speed2, speed3))

head(caro_long)
ggplot(caro_long, aes(name, value)) +
  # we remove outliers to increase legibility, analogue
  # Laube and Purves (2011)
  geom_boxplot(outlier.shape = NA)

