# PROJECT: Content Category Analysis for Social Buzz
# AUTHOR: Mark Bahr
# CURRENT TASKS: 
    # Remove unneeded columns
    # Remove rows with missing values
    # Rename columns
    # Make sure unique values of columns match

# ------------------------------------------------------------------- #
#                       LOAD DATA AND LIBRARIES                       #
# ------------------------------------------------------------------- #

# Load libraries
library(tidyverse)
library(lm.beta)

# Get Working Directory
getwd()

# set working directory
setwd("C:/Users/Admin/Data-Science/Data-Science/Forage-Data-Science/Accenture")

# Load the Data
reactions <- read_csv("Reactions.csv")
reaction_types <- read_csv("ReactionTypes.csv")
content <- read_csv("Content.csv")

# View data structure, such as names & datatypes for each column in each data frame
str(reactions)
str(reaction_types)
str(content)


# ------------------------------------------------------------------- #
#                     REMOVE UNWANTED COLUMNS                         #
# ------------------------------------------------------------------- #

# Keep these columns: content ID, category, content type, reaction type, and reaction score
# Remove the following columns: url, User Id, sentiment, index, datetime

# Remove Index and Datetime from reactions
reactions <- reactions %>%
  select(-c(Index, `User ID`))

# Remove Index and Sentiment from reaction_types
reaction_types <- reaction_types %>%
  select(-c(Index))

# Remove Index and URL from content
content <- content %>%
  select(-c(Index, `User ID`, URL))


# ------------------------------------------------------------------- #
#                 REMOVE ROWS WITH MISSING VALUES                     #
# ------------------------------------------------------------------- #

# Count rows
nrow(reactions) # 25553
nrow(content) # 1000
nrow(reaction_types) # 16

# Count null values in each column
sum(is.na(reactions$`Content ID`)) # 0
sum(is.na(reactions$Type)) # 980
sum(is.na(reactions$Datetime)) # 0
sum(is.na(content$`Content ID`)) # 0
sum(is.na(content$Type)) # 0
sum(is.na(content$Category)) # 0
sum(is.na(reaction_types$Type)) # 0
sum(is.na(reaction_types$Sentiment)) # 0
sum(is.na(reaction_types$Score)) # 0

# Remove rows with missing values in reactions.
reactions <- na.omit(reactions)

# Count rows
nrow(reactions) # Now only 24573

# View the data
view(reactions)
view(reaction_types)
view(content)



# ------------------------------------------------------------------- #
#               UNIQUE VALUES & RENAME COLUMN NAMES                   #
# ------------------------------------------------------------------- #

# Rename the type columns in the content data to eliminate ambiguity, whitespace, and capital letters
content <- content %>%
  rename(content_id = `Content ID`,
         category = Category,
         content_type = Type)

# Rename the type columns in the reaction_types data to eliminate ambiguity, whitespace, and capital letters
reaction_types <- reaction_types %>%
  rename(score = Score,
         sentiment = Sentiment,
         reaction_type = Type)

# Rename the type columns in the reactions data to eliminate ambiguity, whitespace, and capital letters
reactions <- reactions %>%
  rename(content_id = `Content ID`,
         date_time = Datetime,
         reaction_type = Type)

# Find the number of unique values in each column
length(unique(reactions$`Content ID`)) # 962
length(unique(content$Category)) # 42
length(unique(content$Type)) # 4
length(unique(reactions$Type)) # 16
length(unique(reaction_types$Score)) # 15

# List the unique values for columns with < 20 unique values. Check for diff spellings of same category & type.
unique(content$content_type)
unique(content$category) 
unique(reactions$reaction_type)
unique(reaction_types$score)

# - - - - - - - - 
# Remove quotation marks inside strings in the content_type column

# Create empty vector
no_quotes <- c()

#get length of category list
len <- length(content$category)

#append values to list without quotes
i = 1
while(i <= len) {
  no_quotes[i] <- gsub('"', '', tolower(content$category[i]))
  i <- i + 1
}

# Assign no quotes values to categories
content$category <- no_quotes

# Test for unique categories again
unique(content$category)

# Use write.table() function to export csv files
write.csv(content, file = "content_clean.csv")
write.csv(reaction_types, file = "reaction_types_clean.csv")
write.csv(reactions, file = "reactions_clean.csv")