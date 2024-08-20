# Broadway shows NYC
## My R project for NYC Data Science Academy.

- The Broadway Shows Analysis App is a Shiny web application designed to provide an in-depth analysis of Broadway shows. It offers valuable insights for both theater enthusiasts and industry professionals, focusing on metrics such as revenue, ticket prices, and theater performance over time.

### scraping code:
* You can find the code to scrape the data directly from www.playbill.com/revenue. 
Please take a look inside the code and adjust the beginning date of scraping.
The scraping file called `main.py`.
instructions for updating the data:
1. Open `ShortScraping.py` and scroll down to change the range of dates for the scraping process and run the code. it will re-create a file called `Broadway_grosses_historical_new.csv`.
2. Now go to `merging_table.R` and run the code. It will re-create a new file with the data for the app, called `broadway_data.csv`.
3. Run the app as before and the app suppose to be updated.


### Features:
* Top 20 Shows: Compare the top 20 Broadway shows based on revenue, ticket prices, and length of running.
* Compare Shows: Analyze multiple shows on metrics like revenue, running length, and ticket sales.
* Total Revenue by Week: Track weekly revenue trends for selected shows across different years.
* Yearly Heatmap: Visualize the total weekly gross revenue for each show.
* Theater Summary by Decade: Review statistics on theater performance over different decades. Also other matrics related to theaters and show inside this tab.

### Usage
* Navigating the App: Use the tabs at the left to switch between different analysis sections.
* Selecting Shows: Use the drop-down menus to select shows/ theater for comparison or to view specific data.
* Interpreting the Data: The app provides interactive plots and tables; hover over points for more details.
* Known Issue: Some shows with minimal data may not display correctly in comparisons.

### Contact me: 
**Please feel free to reach me on Linkedin - https://www.linkedin.com/in/tomer-choresh/**