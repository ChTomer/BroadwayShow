# library(shiny)
# library(dplyr)
# library(ggplot2)
# library(shinydashboard)
# 
# #  import data
# broadway = read.csv(file = 'playbill_data.csv')
# broadway = broadway |> rename(
#   show = SHOW,
#   gross = THIS.WEEK.GROSS...POTENTIAL.GROSS,
#   diff_gross = DIFF..,
#   avg_ticket_price = AVG.TICKET...TOP.TICKET,
#   seats_sold = SEATS.SOLD...SEATS.IN.THEATRE,
#   perfs_previews = PERFS.PREVIEWS,
#   capacity = X..CAP,
#   diff_capacity = DIFF...CAP,
#   week_date = WEEK.DATE
# )
# # Convert week_date to Date type
# broadway$week_date <- as.Date(broadway$week_date, format = "%Y-%m-%d")
# 
# 
# # In global.R file I can leave the data, packages, /
# # I can leave also functions if I use them again and again.


library(shiny)
library(dplyr)
library(ggplot2)
library(shinydashboard)
library(htmltools)

# Load the data
broadway <- read.csv("playbill_data.csv")
# Load the show summaries
show_summaries <- read.csv("broadway_show_summaries.csv")

# Rename columns
broadway <- broadway %>%
  rename(
    show = SHOW,
    gross = THIS.WEEK.GROSS...POTENTIAL.GROSS,
    diff_gross = DIFF..,
    avg_ticket_price = AVG.TICKET...TOP.TICKET,
    seats_sold = SEATS.SOLD...SEATS.IN.THEATRE,
    perfs_previews = PERFS.PREVIEWS,
    capacity = X..CAP,
    diff_capacity = DIFF...CAP,
    week_date = WEEK.DATE
  )

# Convert week_date to Date type
broadway$week_date <- as.Date(broadway$week_date, format = "%Y-%m-%d")
