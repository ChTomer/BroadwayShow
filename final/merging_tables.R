library(dplyr)
library(lubridate)

# change the value of the broadway_old and make sure that the broadway_new has the correct path and name

# Read the old and new datasets (if not already in memory)
broadway_old <- read.csv("broadway_grosses_historical.csv")
broadway_new <- read.csv("broadway_grosses_historical_new.csv")

# Rename columns to the specified format for broadway_old
colnames(broadway_old) <- c("show", "theater", "this_week_gross", "potential_gross", 
                            "avg_ticket_price", "top_ticket_price", "seats_sold", 
                            "seats_in_theater", "performances", "previews", 
                            "capacity", "week_date")
# Rename columns to the specified format for broadway_new
colnames(broadway_new) <- c("show", "theater", "this_week_gross", "potential_gross", 
                        "avg_ticket_price", "top_ticket_price", "seats_sold", 
                        "seats_in_theater", "performances", "previews", 
                        "capacity", "week_date")

# Check for any duplicates before merging 
duplicates <- inner_join(broadway_old, broadway_new, by = c("week_date", "show"))

if (nrow(duplicates) > 0) {
  print("Warning: There are duplicates between the old and new datasets.")
  print(duplicates)
  # check and remove duplicates
  broadway_new <- anti_join(broadway_new, broadway_old, by = c("week_date", "show"))
}


# Merge the old and new datasets
broadway <- bind_rows(broadway_new, broadway_old)%>%
  distinct(week_date, show, .keep_all = TRUE)

# Convert columns to appropriate data types if needed
broadway$this_week_gross <- as.numeric(gsub("[\\$,]", "", broadway$this_week_gross))
broadway$avg_ticket_price <- as.numeric(gsub("[\\$,]", "", broadway$avg_ticket_price))
broadway$top_ticket_price <- as.numeric(gsub("[\\$,]", "", broadway$top_ticket_price))
broadway$seats_sold <- as.numeric(gsub("[\\$,]", "", broadway$seats_sold))
broadway$seats_in_theater <- as.numeric(gsub("[\\$,]", "", broadway$seats_in_theater))
broadway$capacity <- as.numeric(gsub("[\\%,]", "", broadway$capacity))
broadway$week_date <- as.Date(broadway$week_date, format="%Y-%m-%d")
broadway$theater <- gsub("Theatre","Theater", broadway$theater, ignore.case = TRUE)

# broadway$decade <- floor(as.numeric(format(broadway$week_date, "%Y")) / 10) * 10


# Save the merged dataset
write.csv(broadway, "broadway_data.csv", row.names = FALSE)

