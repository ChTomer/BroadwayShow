import requests
from bs4 import BeautifulSoup
import pandas as pd
from datetime import datetime, timedelta
import time
import random
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


# Define the function to fetch data from a given URL
def fetch_data(url, week_date, retries=3):
    try:
        response = requests.get(url, timeout=10)
        if response.status_code != 200:
            logging.warning(f"No data found for {url}, skipping.")
            return None

        soup = BeautifulSoup(response.content, 'html.parser')
        rows = []

        # Find the table
        table = soup.find('table', class_='bsp-table')
        if not table:
            logging.warning("Table not found")
            return None

        # Loop through each row in the table
        for row in table.find('tbody').find_all('tr'):  # Directly access tbody to skip the header
            columns = row.find_all('td')
            if len(columns) >= 8:  # Ensure there are enough columns
                show_name_elem = columns[0].find('span', class_='data-value')
                theater_name_elem = columns[0].find('span', class_='subtext')

                if show_name_elem and theater_name_elem:
                    show_name = show_name_elem.text.strip()
                    theater_name = theater_name_elem.text.strip()
                else:
                    continue

                this_week_gross_elem = columns[1].find('span', class_='data-value')
                potential_gross_elem = columns[1].find('span', class_='subtext')

                if this_week_gross_elem:
                    this_week_gross = this_week_gross_elem.text.strip()
                    potential_gross = potential_gross_elem.text.strip() if potential_gross_elem else ''
                else:
                    continue

                avg_ticket_price_elem = columns[3].find('span', class_='data-value')
                top_ticket_price_elem = columns[3].find('span', class_='subtext')

                if avg_ticket_price_elem:
                    avg_ticket_price = avg_ticket_price_elem.text.strip()
                    top_ticket_price = top_ticket_price_elem.text.strip() if top_ticket_price_elem else ''
                else:
                    continue

                seats_sold_elem = columns[4].find('span', class_='data-value')
                seats_in_theater_elem = columns[4].find('span', class_='subtext')

                if seats_sold_elem:
                    seats_sold = seats_sold_elem.text.strip()
                    seats_in_theater = seats_in_theater_elem.text.strip() if seats_in_theater_elem else ''
                else:
                    continue

                performances_elem = columns[5].find('span', class_='data-value')
                previews_elem = columns[5].find('span', class_='subtext')

                if performances_elem:
                    performances = performances_elem.text.strip()
                    previews = previews_elem.text.strip() if previews_elem else ''
                else:
                    continue

                capacity_percentage_elem = columns[6].find('span', class_='data-value')

                if capacity_percentage_elem:
                    capacity_percentage = capacity_percentage_elem.text.strip()
                else:
                    continue

                current_row = [
                    show_name, theater_name, this_week_gross, potential_gross,
                    avg_ticket_price, top_ticket_price, seats_sold, seats_in_theater,
                    performances, previews, capacity_percentage, week_date
                ]

                rows.append(current_row)

        return rows

    except requests.RequestException as e:
        logging.error(f"Error fetching data for {url}: {e}")
        if retries > 0:
            time.sleep(2)  # wait for 2 seconds before retrying
            return fetch_data(url, week_date, retries - 1)
        else:
            return None


# Define the function to generate URLs based on weekly intervals
def generate_urls(start_date, end_date):
    current_date = start_date
    while current_date >= end_date:
        yield f'https://www.playbill.com/grosses?week={current_date.strftime("%Y-%m-%d")}', current_date.strftime(
            "%Y-%m-%d")
        current_date -= timedelta(days=7)


# Define column names excluding "DIFF $" and "DIFF % CAP" and including separate columns for AVG and TOP TICKET, SEATS SOLD and SEATS IN THEATRE
column_names = [
    "SHOW", "THEATER", "THIS WEEK GROSS", "POTENTIAL GROSS",
    "AVG TICKET PRICE", "TOP TICKET PRICE", "SEATS SOLD", "SEATS IN THEATER",
    "PERFORMANCES", "PREVIEWS", "CAPACITY %", 'WEEK DATE'
]

all_data = []

# Define the date range for scraping
start_date = datetime.strptime('2024-08-11', '%Y-%m-%d')
end_date = datetime.strptime('2024-07-28', '%Y-%m-%d')

# Scrape data until no more data is found
for url, week_date in generate_urls(start_date, end_date):
    logging.info(f"Fetching data from: {url}")
    weekly_data = fetch_data(url, week_date)
    if weekly_data:
        all_data.extend(weekly_data)
    else:
        logging.info(f"Skipping week {week_date}.")
    # Add a shorter random delay between requests to improve speed
    time.sleep(random.uniform(0.05, 0.2))

# Save the combined data to CSV
df = pd.DataFrame(all_data, columns=column_names)
df.to_csv('broadway_grosses_historical_new.csv', index=False)
logging.info("Data saved to broadway_grosses_historical_new.csv")
