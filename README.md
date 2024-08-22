# Broadway shows NYC

## My R project for NYC Data Science Academy.

-   The Broadway Shows Analysis App is a Shiny web application designed to provide an in-depth analysis of Broadway shows. It offers valuable insights for both theater enthusiasts and industry professionals, focusing on metrics such as revenue, ticket prices, and theater performance over time.

-   please visit [my App](https://chtomer.shinyapps.io/Broadway_Show_NYC/) and enjoy the show.

### Scraping Code:

-   You can find the code to scrape the data directly from [playbill.com](https://playbill.com/grosses). Please look inside the code and adjust the start date for scraping. The scraping file is called `main.py`. Instructions for updating the data:

1.  Open `ShortScraping.py` and scroll down to change the date range for the scraping process, then run the code. It will re-create a file called `Broadway_grosses_historical_new.csv`.
2.  Next, go to `merging_table.R` and run the code. It will create a new file with the data for the app, called `broadway_data.csv`.
3.  Run the app as before, and the app should be updated.
4.  Since it's not common to add data files to GitHub, you can find and download all of them from [this link](https://drive.google.com/drive/folders/1UcAumUzVbhjflGsMMzO5kPQF7c9SiC4D?usp=drive_link).

### Features:

-   Top 20 Shows: Compare the top 20 Broadway shows based on revenue, ticket prices, and length of run.
-   Compare Shows: Analyze multiple shows on metrics like revenue, run length, and ticket sales.
-   Total Revenue by Week: Track weekly revenue trends for selected shows across different years.
-   Yearly Heatmap: Visualize the total weekly gross revenue for each show.
-   Theater Summary by Decade: Review statistics on theater performance over different decades, along with other metrics related to theaters and shows within this tab.

### Usage

-   Navigating the App: Use the tabs on the left to switch between different analysis sections.
-   Selecting Shows: Use the drop-down menus to select shows or theaters for comparison or to view specific data.
-   Interpreting the Data: The app provides interactive plots and tables; hover over points for more details.
-   Known Issue: Some shows with minimal data may not display correctly in comparisons.

### Contact Me:

Please feel free to reach out to me on [LinkedIn](https://www.linkedin.com/in/tomer-choresh/).
