###################################################
####### broadway_grosses_historical version #######
###################################################
# install.packages("plotly")
getwd()
library(DT)
library(dplyr)
library(forecast) # remove?
library(ggplot2)
library(ggridges)
library(htmltools)
library(plotly)
library(rsconnect)
library(scales)
library(shiny)
library(shinydashboard)
library(tidyr)
 
# Load the datasets
broadway <- read.csv("broadway_data.csv")
show_summaries <- read.csv("broadway_show_summaries.csv") # dry information for the summary in comparison tab

# Rename columns to the specified format
colnames(broadway) <- c("show", "theater", "this_week_gross", "potential_gross", 
                        "avg_ticket_price", "top_ticket_price", "seats_sold", 
                        "seats_in_theater", "performances", "previews", 
                        "capacity", "week_date")

# Convert columns to appropriate data types if needed
broadway$this_week_gross <- as.numeric(gsub("[\\$,]", "", broadway$this_week_gross))
broadway$avg_ticket_price <- as.numeric(gsub("[\\$,]", "", broadway$avg_ticket_price))
broadway$top_ticket_price <- as.numeric(gsub("[\\$,]", "", broadway$top_ticket_price))
broadway$seats_sold <- as.numeric(gsub("[\\$,]", "", broadway$seats_sold))
broadway$seats_in_theater <- as.numeric(gsub("[\\$,]", "", broadway$seats_in_theater))
broadway$capacity <- as.numeric(gsub("[\\%,]", "", broadway$capacity))
broadway$week_date <- as.Date(broadway$week_date, format="%Y-%m-%d")
broadway$theater <- gsub("Theatre","Theater", broadway$theater, ignore.case = TRUE)

broadway$decade <- floor(as.numeric(format(broadway$week_date, "%Y")) / 10) * 10

my_colors <- RColorBrewer::brewer.pal(3, "Set2")

# print(head(broadway))
# print(summary(broadway))
