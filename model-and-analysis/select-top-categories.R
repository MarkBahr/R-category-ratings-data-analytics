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
setwd("C:/Users/Admin/Data-Science/Data-Science/Forage-Data-Science/Accenture")

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
#                     FIND 5 TOP CATEGORIES                           #
# ------------------------------------------------------------------- #

# List the sum of scores for each category from greatest to least (i.e.Get a sum of scores grouped by category.)
grouped_cat <- content_react %>%
  group_by(category) %>%
  summarise(sum_score = round(sum(score, na.rm = TRUE), 2)) %>%
  arrange(desc(sum_score))

# Turn the tibble back into a dataframe
grouped_categories <- as.data.frame(grouped_cat)

# Select the top five categories
top_five <- head(grouped_categories, 5)

# View to double check we have what we want
view(grouped_categories)
view(top_five)

# Not sure if they want all the data for those five cateogories only, if so, here's the code to get that.
# Return categories where categories is in the top five.
top_categories <- top_five$category


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
