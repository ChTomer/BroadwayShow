import pandas as pd

# Load the dataset
''' 
No need to change anything in this code. just open and run. 
It will update the broadway_show_summaries.csv file  
'''
broadway = pd.read_csv('broadway_data.csv')

# Ensure columns are correctly named
broadway.columns = [
    "show", "theater", "this_week_gross", "potential_gross",
  "avg_ticket_price", "top_ticket_price", "seats_sold",
  "seats_in_theater", "performances", "previews",
  "capacity", "week_date", 'decade'
]

# Convert week_date to datetime
broadway['week_date'] = pd.to_datetime(broadway['week_date'])

# Generate the summary information for each show
show_summaries = []

for show in broadway['show'].unique():
    show_data = broadway[broadway['show'] == show]

    # figure the first and last date of show
    start_date = show_data['week_date'].min().strftime('%Y-%m-%d')
    end_date = show_data['week_date'].max().strftime('%Y-%m-%d')
    # sum and avg of revenue for later
    total_revenue = show_data['this_week_gross'].sum()
    avg_weekly_revenue = show_data['this_week_gross'].mean()
    # create the prompt for the summary to each show in the df.
    summary = f"The show '{show}' ran from {start_date} to {end_date}. It had an average weekly revenue of ${avg_weekly_revenue:,.2f} and a total revenue of ${total_revenue:,.2f}."
    # create the df with both only relevant columns
    show_summaries.append([show, summary])

# Create a DataFrame for the summaries
show_summaries_df = pd.DataFrame(show_summaries, columns=['show', 'description'])

# Save to CSV
summary_csv_path = 'broadway_show_summaries.csv'
show_summaries_df.to_csv(summary_csv_path, index=False)

summary_csv_path
