# ExC: Prep own data ####
# install.packages("XML")
# install.packages("leaflet")
library("XML")
library("leaflet")
library("sf")
library("tmap")

# this is an alternative approach with one activity as the way we learned did not work with gpx data and i couldn't find the data in a different format

#read data
act1_parsed <- htmlTreeParse(file = "activities/11034695746.gpx", useInternalNodes = TRUE)
act1_parsed

# get coordinates
coords <- xpathSApply(doc = act1_parsed, path = "//trkpt", fun = xmlAttrs)

# get elevation
elevation <- xpathSApply(doc = act1_parsed, path = "//trkpt/ele", fun = xmlValue)

# built data frame
act1_df <- data.frame(
  lat = as.numeric(coords["lat", ]),
  lon = as.numeric(coords["lon", ]),
  elevation = as.numeric(elevation)
)

# look at data frame
head(act1_df, 10)
tail(act1_df, 10)

# plot data
plot(x = act1_df$lon, y = act1_df$lat, type = "l", col = "black", lwd = 3,
     xlab = "Longitude", ylab = "Latitude")

# add basemap
leaflet() |> 
  addTiles() |> 
  addPolylines(data = act1_df, lat = ~lat, lng = ~lon, color = "#000000", opacity = 0.8, weight = 3)


# this approach did not work as the data format was different
# Import your data as a data frame and convert it to an sf object, using the correct CRS information
walks <- read_delim("activities.csv", ",")
walks <- st_as_sf(walks, coords = c("E", "N"), crs = 3857)

# Convert your data to CH1903+ LV95
walks_ch <- st_transform(walks, crs = 2056)

# Make a map of your data using ggplot2 or tmap.

walks_line <- walks_ch |> 
  summarise(do_union = FALSE) |> 
  st_cast("LINESTRING")

tmap_options(basemaps = "OpenStreetMap")
tmap_mode("view")

tm_shape(walks_ch) +
  tm_dots(col = "TrajID") 
tm_shape(walks_line) +
  tm_lines()
