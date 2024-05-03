# Demo ####
### `difftime` {#sec-difftime}

now <- as.POSIXct("2024-04-26 10:20:00")
later <- as.POSIXct("2024-04-26 11:35:00")

later <- now + 10000
later

time_difference <- difftime(later, now)
time_difference

# You can also specify the unit of the output.

time_difference <- difftime(later, now, units = "secs")
time_difference

# `difftime` returns an object of the class `difftime`. 

#| collapse: true
class(time_difference)

str(time_difference)

# However in our case, numeric values would be more handy than the class `difftime`. So we'll wrap the command in `as.numeric()`:

#| collapse: true

time_difference <- as.numeric(difftime(later, now, units = "secs"))

str(time_difference)
class(time_difference)

# In fact, we will use this exact operation multiple times, so let's create a function for this:
  
difftime_secs <- function(later, now){
  as.numeric(difftime(later, now, units = "secs"))
}

### `lead()` / `lag()` {#sec-lead-lag}

# `lead()` and `lag()` return a vector of the same length as the input, just offset by a specific number of values (default is 1). Consider the following sequence:
numbers <- 1:10
numbers

# We can now run `lead()` and `lag()` on this sequence to illustrate the output. `n =` specifies the offset, `default =` specifies the default value used to "fill" the emerging "empty spaces" of the vector. This helps us performing operations on subsequent values in a vector (or rows in a table).

library("dplyr")

lead(numbers)

lead(numbers, n = 2)

lag(numbers)

lag(numbers, n = 5)

lag(numbers, n = 5, default = 0)

### `mutate()`

# Using the above functions (`difftime()` and `lead()`), we can calculate the time lag, that is, the time difference between consecutive positions. We will try this on a dummy version of our wild boar dataset.

wildschwein <- tibble(
  TierID = c(rep("Hans", 5), rep("Klara", 5)),
  DatetimeUTC = rep(as.POSIXct("2015-01-01 00:00:00", tz = "UTC") + 0:4 * 15 * 60, 2)
)

wildschwein

# If we are interested to calculate the speed travelled between subsequent locations, we need to calculate the elapsed time first. Since R does most operations in a vectorized manner, we can use `difftime_secs` on the entire column `DatetimeUTC` of our dataframe `wildschwein` and store the output in a new column. 

now <- wildschwein$DatetimeUTC
later <- lead(now)

wildschwein$timelag <- difftime_secs(later, now)

wildschwein

#However, we have an issue at the transion between the two animals. We can overcome this issue using dplyr's `mutate` with `group_by`. **If we use `mutate`, we do not use the `$` notation!**

# note the lack of "$"
wildschwein <- mutate(wildschwein, timelag = difftime_secs(lead(DatetimeUTC), DatetimeUTC))

wildschwein

# The output is equivalent, we need `group_by` as well.

### `group_by()`
# To distinguish groups in a dataframe, we need to specify these using `group_by()`. 
# again, note the lack of "$"
wildschwein <- group_by(wildschwein, TierID)

# After adding this grouping variable, calculating the `timelag` automatically accounts for the individual trajectories.
# again, note the lack of "$"
wildschwein <- mutate(wildschwein, timelag = difftime(lead(DatetimeUTC), DatetimeUTC))

wildschwein


### Piping 
# Piping can simplify the process and help us write our sequence of operations in a manner as we would explain them to another human being.
# In order to make code readable in a more human-friendly way, we can use the piping command (`|>` or `%>%`, it does not matter which).

wildschwein |>                                            # Take wildschwein...
    group_by(TierID) |>                                   # ...group it by TierID
    mutate(
        timelag = difftime(lead(DatetimeUTC), DatetimeUTC)# Caculate difftime
        )

### `summarise()`

# If we want to summarise our data and get metrics *per animal*, we can use the `dplyr` function `summarise()`. In contrast to `mutate()`, which just adds a new column to the dataset, `summarise()` "collapses" the data to one row per individual (specified by `group_by`).

summarise(wildschwein, mean = mean(timelag, na.rm = TRUE))
