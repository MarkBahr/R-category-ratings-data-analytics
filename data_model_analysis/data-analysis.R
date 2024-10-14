# PROJECT: Content Category Analysis for Social Buzz
# AUTHOR: Mark Bahr
# CURRENT TASKS: 
    # 1. Create a final data set by merging your three tables together
    # 2. Figure out the Top 5 performing categories
    # Rename columns
    # Make sure unique values of columns match

# ------------------------------------------------------------------- #
#                       LOAD DATA AND LIBRARIES                       #
# ------------------------------------------------------------------- #
# Load libraries
library(tidyverse)
library(lm.beta)

# set working directory
setwd("C:/Users/Admin/Data-Science/Data-Science/Forage-Data-Science/Accenture/data_analysis")

# Load the Data
reactions <- read_csv("reactions_clean.csv")
reaction_types <- read_csv("reaction_types_clean.csv")
content <- read_csv("content_clean.csv")


# ------------------------------------------------------------------- #
#                             MERGE TABLES                            #
# ------------------------------------------------------------------- #

# Remove Index and Datetime from reactions
reactions <- reactions %>%
  select(-c(...1))

# Remove Index and Sentiment from reaction_types
reaction_types <- reaction_types %>%
  select(-c(...1))

# Remove Index and URL from content
content <- content %>%
  select(-c(...1))

view(reactions)
view(reaction_types)
view(content)

# List the reaction dfs
react_list <- list(reactions, reaction_types)

# Use the list to merge the reaction and reaction_type dataframes
react <- react_list %>%
  reduce(full_join, by = 'reaction_type')
  
# List the react and content dataframes
content_list <- list(content, react)

# Use the list to merge the react and content dataframes
content_react <- content_list %>%
  reduce(full_join, by = 'content_id')

# See the content_react dataframe
view(content_react)

# ------------------------------------------------------------------- #
#                      CATEGORY AGGREGATES                            #
# ------------------------------------------------------------------- #
# How many unique categories are there?
length(unique(content_react$category))  # 16

# How many reactions are there to the most popular category?
# Let's look at the total score, average score and number of reactions for each category
category_agg <- content_react %>%
  group_by(category) %>%
  summarise(
    sum_score = round(sum(score, na.rm = TRUE), 2),
    reaction_count = length(reaction_type),
    min_score = round(min(score, na.rm = TRUE), 2),
    max_score = round(max(score, na.rm = TRUE), 2),
    avg_score = round(mean(score, na.rm = TRUE), 2)) %>%
  arrange(desc(sum_score))

view(category_agg)

top_five <- head(category_agg, 5)

# What are the top categories by average score?
sort_by_avg <- category_agg %>%
  arrange(desc(avg_score))

view(sort_by_avg)


# ------------------------------------------------------------------- #
#                       DATES, MONTHS, & YEARS                        #
# ------------------------------------------------------------------- #
# To do date analysis, we will create new columns for date, month, and year

# Change data type for date_time column from string to Datetime format
content_react$date_time <- as.POSIXct(content_react$date_time, format = "%m/%d/%Y %H:%M")

#  Create date column
content_react$date <- format(content_react$date_time, "%m/%d/%Y")

# Create month column
content_react$month <- format(content_react$date_time, "%m")

#  Create year column
content_react$year <- format(content_react$date_time, "%Y")

# How many unique dates are there?
length(unique(content_react$date))  # 367

# What unique years are there?
length(unique(content_react$year))  # 367, including NA
unique(content_react$year)  # 2020, 2021, and NA

# What was the month with the most posts?
month_count <- content_react %>%
  group_by(month) %>%
  summarise(
    reaction_count = length(reaction_type)) %>%
  arrange(desc(reaction_count))

view(month_count) # May had 2138, while the month with the fewest, February had 1914

# What was the date with the most posts? 
date_count <- content_react %>%
  group_by(date) %>%
  summarise(
    reaction_count = length(reaction_type)) %>%
  arrange(desc(reaction_count))

view(date_count) # 1/11/2021 had 95, while June 18th had 30


# ------------------------------------------------------------------- #
#               SELECT DATA FROM 5 TOP CATEGORIES ONLY                #
# ------------------------------------------------------------------- #

# Filter the merged data for the top five categories
top_data <- content_react %>%
  filter((category == 'animals') | (category == 'science') | 
           (category == 'healthy eating') | (category == 'technology') | (category == 'food'))

# Check that only the top categories remain
unique(top_data$category)
nrow(top_data)

# Use write.table() function to export csv files
write.csv(top_data, file = "top_five_data.csv")
write.csv(top_five, file = "top_five.csv")
write.csv(category_agg, file = "category_aggregates.csv")
write.csv(content_react, file = "content_reactions.csv")
write.csv(month_count, file = "month_count.csv")
write.csv(date_count, file = "date_count.csv")
