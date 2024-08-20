library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(scales)

shinyServer(function(input, output, session) {
  
  observe({
  # Populate selectize inputs with server-side processing
  updateSelectizeInput(session, "first_show", choices = unique(broadway$show), server = TRUE)
  updateSelectizeInput(session, "second_show", choices = unique(broadway$show), server = TRUE)
  updateSelectizeInput(session, "selected_show", choices = unique(broadway$show), server = TRUE)
  updateSelectizeInput(session, "selected_shows", choices = unique(broadway$show), server = TRUE)
  })

  #####################################
  ####### Introduction section  #######
  #####################################

  output$project_summary <- renderUI({
    HTML("
    <h1><strong>Welcome to the Broadway Shows Analysis App</strong></h1>
    <p>This app provides a comprehensive analysis of the financial performance of Broadway shows, 
    offering valuable insights for both fans and industry professionals.</p>
    
    <h3>App Feature</h3>
    <p>Explore Broadway shows through these key features:</p>
    <ul>
      <li>Top 20 Shows: Compare the top 20 shows based on different matrics.</li>
      <li>Compare Shows: Analyze multiple shows on metrics like revenue 
      and audience engagement using interactive charts.</li>
      <li>Total Revenue by Week: Visualize the total weekly gross revenue for each show 
      through interactive heatmaps.</li>
      <li>Theater: Delve into a decade-wise analysis of Broadway theaters. you can explore detailed summaries of shows performed at specific theaters or discover which theaters 
      hosted a particular show.</li>
      
    </ul>
    
    <h3>Why Use This App?</h3>
    <p>Whether you're a Broadway fan or an industry professional, this app provide you tools 
    to explore and understand the financial dynamics of Broadway. Use it to make informed decisions, 
    discover trends, and gain insights into the theater world.</p>
    
    <h3>Data and Code</h3>
    <p>The data is sourced from <a href='https://playbill.com/grosses'>Playbill's historical revenue</a> reports. For the data scraping code, 
    visit my <a href='https://github.com/ChTomer/BroadwayShow/'>GitHub Repository</a>.</p>
  ")
  })
  
  
  #####################################
  ######## compare show guide  ########
  #####################################
  
  output$compare_shows_guide <- renderUI({
    HTML("
    <ul>
      <h4>Compare Two Shows Tab:</h4>
      <li>Select Shows:Choose any two shows you want to compare.</li>
      <li>Set a Date Range: Use the slider to pick the years you’re interested in.</li>
      <li>Choose a Comparison Type: Select one of the following:
        <ul>
          <li>Revenue Difference: See how the weekly gross revenue compares.</li>
          <li>Length of Show: Compare how long each show has run (in weeks).</li>
          <li>Seats Sold: Compare the weekly seat sales between the shows.</li>
          <li>Average Ticket Price: See the differences in ticket prices.</li>
        </ul>
      </li>
      <br>
      <h4>Average Ticket Price Destribution Tab:</h4>
      <li>Explore the Violin Plot: Select 2 or more shows to visualize the distribution of average ticket prices. 
      <p>A violin plot helps you compare the price distribution, showing where ticket prices are most concentrated.</p></li>
      <br>
      <h4>In Both Tabs:</h4>
      <li>View Show Summaries: Scroll down to see a quick summary of the selected shows, including key stats and insights.</li>
    </p>
  ")
  })
  
  #####################################
  ### Total revenue by week guide  ####
  #####################################
  
  output$total_revenue_guide <- renderUI({
    HTML("
    
    <ul>
      <li>Select a Year: Choose the year from the dropdown list to view the total revenue for each week of that year.</li>
      <li>View Heatmap: The heatmap will display the total revenue for each show by week. Move your mouse over the colorful cubes to understand better the weekly revenue for each show.</li>
    </ul>
  ")
  })
  
  
  output$theater_by_show_guide <- renderUI({
    HTML("
    <ul>
      <li>Select a Show: Choose a show from the dropdown to view all theaters that hosted the show.</li>
      <li>Sort Data: Click on column headers to sort the table by different criteria.</li>
    </ul>
  ")
  })
  
  output$show_by_theaters_guide <- renderUI({
    HTML("
    <ul>
      <li>Select a Theater: Choose a theater from the dropdown to view all shows presented there.</li>
      <li>Sort Data: Click on column headers to sort the table by different criteria.</li>
    </ul>
  ")
  })
  
  
  # Custom theme font-size function
  custom_theme <- function() {
    theme_minimal() +
      theme(
        plot.title = element_text(size = 20),         # Title font size
        axis.title.x = element_text(size = 15),       # X-axis title font size
        axis.title.y = element_text(size = 15),       # Y-axis title font size
        axis.text.x = element_text(size = 12),        # X-axis text font size
        axis.text.y = element_text(size = 12)         # Y-axis text font size
      )
  }
  
  
  # Render Plotly Line Chart for Total Weekly Revenue Comparison
  output$revenue_comparison_plot <- renderPlotly({
    req(input$selected_years)
    
    # Filter data for the selected years
    data <- broadway %>%
      filter(format(week_date, "%Y") %in% input$selected_years) %>%
      mutate(year = format(week_date, "%Y"), week = format(week_date, "%U")) %>%
      group_by(year, week) %>%
      summarise(total_revenue = sum(this_week_gross, na.rm = TRUE), .groups = 'drop') %>%
      mutate(hover_text = paste("Year:", year, 
                                "<br>Week number:", week, 
                                "<br>Total revenue: $", scales::comma(total_revenue)))
    
    # Generate Plotly line chart
    plot_ly(data, x = ~week, y = ~total_revenue, color = ~year, type = 'scatter', mode = 'lines',
            colors = my_colors,
            text = ~hover_text, hoverinfo = 'text') %>%
      layout(title = "Total Weekly Revenue Comparison",
             xaxis = list(title = "Week"),
             yaxis = list(title = "Total Revenue",
                          tickformat = ",",  # Add commas to the y-axis labels
                          tickprefix = "$"),  # Optionally add a dollar sign prefix
             legend = list(title = list(text = "Year")))
  })
  
  #####################################
  ########### Top 20 Shows  ###########
  #####################################
  # Top 20 Shows By Revenue
  output$top_20_revenue <- renderPlot({
    data <- broadway %>%
      group_by(show) %>%
      summarise(this_week_gross = sum(this_week_gross, na.rm = TRUE), .groups = 'drop') %>%
      arrange(desc(this_week_gross)) %>%
      top_n(20, this_week_gross)
    
    ggplot(data, aes(x = reorder(show, this_week_gross), y = this_week_gross, fill = show)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      coord_flip() +
      theme_minimal() +
      labs(title = "Top 20 Shows by Total Revenue", x = "Show", y = "Total Gross ($)") +
      scale_y_continuous(labels = comma) +  
      theme(legend.position = "none")+
      custom_theme()
  })
  
  # Top 20 Shows by Average Weekly Revenue
  output$top_20_avg_weekly_revenue <- renderPlot({
    data <- broadway %>%
      group_by(show) %>%
      summarise(avg_weekly_revenue = mean(this_week_gross, na.rm = TRUE), .groups = 'drop') %>%
      arrange(desc(avg_weekly_revenue)) %>%
      top_n(20, avg_weekly_revenue)
    
    ggplot(data, aes(x = reorder(show, avg_weekly_revenue), y = avg_weekly_revenue, fill = show)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      coord_flip() +
      theme_minimal() +
      labs(title = "Top 20 Shows by Average Weekly Revenue", x = "Show", y = "Average Weekly Revenue ($)") +
      scale_y_continuous(labels = comma) +  
      theme(legend.position = "none")+
      custom_theme()
  })
  
  # Top 20 Shows by Length of Running
  output$top_20_length <- renderPlot({
    data <- broadway %>%
      group_by(show) %>%
      summarise(length_of_run = n_distinct(week_date), .groups = 'drop') %>%
      arrange(desc(length_of_run)) %>%
      top_n(20, length_of_run)
    
    ggplot(data, aes(x = reorder(show, length_of_run), y = length_of_run, fill = show)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      coord_flip() +
      theme_minimal() +
      labs(title = "Top 20 Shows by Length of Running", x = "Show", y = "Number of Weeks") +
      scale_y_continuous(labels = comma) +
      theme(legend.position = "none")+
      custom_theme()
  })
  
  
  ####################################
  ######### Compare show tab #########
  ####################################
  
  filtered_data <- reactive({
    req(input$first_show, input$second_show, input$date_range)
    data <- broadway %>%
      filter(show %in% c(input$first_show, input$second_show)) %>%
      filter(format(week_date, "%Y") >= input$date_range[1] & format(week_date, "%Y") <= input$date_range[2])
    return(data)
  })
  
  output$comparison_plot <- renderPlotly({
    data <- filtered_data()
    
    if (input$comparison_type == "Revenue Difference") {
      data <- data %>%
        group_by(show, week_date) %>%
        summarise(this_week_gross = sum(this_week_gross), .groups = 'drop')
      
      plot_ly(data, x = ~week_date, y = ~this_week_gross, type = 'scatter', mode = 'lines+markers', color = ~show,
              colors = my_colors,
              text = ~paste("Show:", show, "<br>Date:", week_date, "<br>Total Gross: $", scales::comma(this_week_gross)),
              hoverinfo = 'text',
              height = 400) %>%
        layout(title = "Revenue Difference",
               xaxis = list(title = "Week Date"),
               yaxis = list(title = "Total Gross"))
      
    } else if (input$comparison_type == "Length of Show") {
      data <- data %>%
        group_by(show) %>%
        summarise(length_of_run = n_distinct(week_date), .groups = 'drop')
      
      plot_ly(data, x = ~show, y = ~length_of_run, type = 'bar', color = ~show,
              colors = my_colors,
              text = ~paste("Show:", show, "<br>Length of Run:", length_of_run),
              hoverinfo = 'text',
              height = 400) %>%
        layout(title = "Length of Show",
               xaxis = list(title = "Show"),
               yaxis = list(title = "Number of Weeks"))
      
    } else if (input$comparison_type == "Seats Sold Each Week") {
      data <- data %>%
        group_by(show, week_date) %>%
        summarise(total_seats = sum(seats_sold), .groups = 'drop')
      
      plot_ly(data, x = ~week_date, y = ~total_seats, type = 'scatter', mode = 'lines+markers', color = ~show,
              colors = my_colors,
              text = ~paste("Show:", show, "<br>Date:", week_date, "<br>Total Seats:", scales::comma(total_seats)),
              hoverinfo = 'text',
              height = 400) %>%
        layout(title = "Seats Sold Each Week",
               xaxis = list(title = "Week Date"),
               yaxis = list(title = "Total Seats Sold"))
      
    } else if (input$comparison_type == "Average Ticket Price") {
      data <- data %>%
        group_by(show, week_date) %>%
        summarise(avg_ticket_price = mean(avg_ticket_price), .groups = 'drop')
      
      plot_ly(data, x = ~week_date, y = ~avg_ticket_price, type = 'scatter', mode = 'lines+markers', color = ~show,
              colors = my_colors,
              text = ~paste("Show:", show, "<br>Date:", week_date, "<br>Avg Ticket Price: $", avg_ticket_price),
              hoverinfo = 'text',
              height = 400) %>%
        layout(title = "Average Ticket Price",
               xaxis = list(title = "Week Date"),
               yaxis = list(title = "Average Ticket Price ($)"))
    }
  })
  ##################################################
  ######## Additional SUMMARY OF THE SHOWS  ########
  ##################################################
  
  # Helper function to convert weeks to years, months, and weeks
  
  calculate_running_period <- function(dates) {
    # Check for NA or empty dates
    if (length(dates) == 0 || all(is.na(dates))) {
      return(NA)
    }
    dates <- sort(dates)
    periods <- data.frame(start = dates, end = dates)
    
    # Merge consecutive periods
    for (i in 2:nrow(periods)) {
      if (periods$start[i] == periods$end[i - 1] + 1) {
        periods$end[i - 1] <- periods$end[i]
        periods$start[i] <- NA
        periods$end[i] <- NA
      }
    }
    
    periods <- periods[complete.cases(periods), ]
    total_weeks <- sum(as.numeric(periods$end - periods$start + 1))
    
    return(total_weeks)
  }
  
  convert_weeks_to_period <- function(weeks) {
    years <- floor(weeks / 52)
    remaining_weeks <- weeks %% 52
    months <- floor(remaining_weeks / 4)
    remaining_weeks <- remaining_weeks %% 4
    
    result <- c()
    if (years > 0) {
      result <- c(result, paste(years, ifelse(years == 1, "year", "years")))
    }
    if (months > 0) {
      result <- c(result, paste(months, ifelse(months == 1, "month", "months")))
    }
    if (remaining_weeks > 0) {
      result <- c(result, paste(remaining_weeks, ifelse(remaining_weeks == 1, "week", "weeks")))
    }
    
    return(paste(result, collapse = ", "))
  }
  
  output$first_show_summary <- renderUI({
    req(input$first_show)
    
    show_data <- broadway %>%
      filter(show == input$first_show)
    
    total_revenue <- sum(show_data$this_week_gross, na.rm = TRUE)
    avg_ticket_price <- mean(show_data$avg_ticket_price, na.rm = TRUE)
    total_seats_sold <- sum(show_data$seats_sold, na.rm = TRUE)
    
    # Calculate the number of running weeks
    running_weeks <- calculate_running_period(show_data$week_date)
    
    # Handle NA case for running_weeks
    if (is.na(running_weeks) || running_weeks == 1) {
      running_period <- "This show ran for only 1 week."
    } else {
      running_period <- convert_weeks_to_period(running_weeks)
    }
    
    summary_html <- paste0(
      "<h4>", input$first_show, "</h4>",
      "<ul>",
      "<li>Total Revenue: $", scales::comma(total_revenue), "</li>",
      "<li>Average Ticket Price: $", round(avg_ticket_price, 2), "</li>",
      "<li>Total Seats Sold: ", scales::comma(total_seats_sold), "</li>",
      "<li>Running Period: ", running_period, "</li>",
      "</ul>"
    )
    
    HTML(summary_html)
  })
  
  
  output$second_show_summary <- renderUI({
    req(input$second_show)
    
    show_data <- broadway %>%
      filter(show == input$second_show)
    
    total_revenue <- sum(show_data$this_week_gross, na.rm = TRUE)
    avg_ticket_price <- mean(show_data$avg_ticket_price, na.rm = TRUE)
    total_seats_sold <- sum(show_data$seats_sold, na.rm = TRUE)
    running_weeks <- calculate_running_period(show_data$week_date)
    running_period <- convert_weeks_to_period(running_weeks)
    
    summary_html <- paste0(
      "<h4>", input$second_show, "</h4>",
      "<ul>",
      "<li>Total Revenue: $", scales::comma(total_revenue), "</li>",
      "<li>Average Ticket Price: $", round(avg_ticket_price, 2), "</li>",
      "<li>Total Seats Sold: ", scales::comma(total_seats_sold), "</li>",
      "<li>Running Period: ", running_period, "</li>",
      "</ul>"
    )
    
    HTML(summary_html)
  })

  #################################################### 
  ######## Average Ticket Prices Distribution ########
  ####################################################
  # Average Ticket Prices (Violin Plot)
  output$violin_plot_avg_ticket_prices <- renderPlot({
    req(input$selected_shows)
    
    data <- broadway %>%
      filter(show %in% input$selected_shows)
    
    ggplot(data, aes(x = show, y = avg_ticket_price, fill = show)) +
      geom_violin() +
      theme_minimal() +
      labs(title = "Average Ticket Prices", x = "Show", y = "Average Ticket Price ($)") +
      theme(legend.position = "none")
  })
  
  # Yearly Difference in Gross Revenue
  output$yearly_difference_gross <- renderPlot({
    req(input$selected_shows)
    
    data <- broadway %>%
      filter(show %in% input$selected_shows) %>%
      mutate(year = format(week_date, "%Y")) %>%
      group_by(show, year) %>%
      summarise(yearly_gross = sum(this_week_gross, na.rm = TRUE), .groups = 'drop')
    
    ggplot(data, aes(x = year, y = yearly_gross, color = show, group = show)) +
      geom_line(linewidth = 1) +
      geom_point(size = 2) +
      theme_minimal() +
      scale_y_continuous(labels = comma) +  
      labs(title = "Yearly Difference in Gross Revenue", x = "Year", y = "Yearly Gross Revenue ($)")
  })
  
  # Summary of Selected Shows
  output$selected_shows_summary <- DT::renderDataTable({
    req(input$selected_shows)
    
    data <- broadway %>%
      filter(show %in% input$selected_shows)
    
    summary_stats <- data %>%
      group_by(show) %>%
      summarise(
        Min = round(min(avg_ticket_price, na.rm = TRUE), 2),
        `1st Qu.` = round(quantile(avg_ticket_price, 0.25, na.rm = TRUE), 2),
        Median = round(median(avg_ticket_price, na.rm = TRUE), 2),
        Mean = round(mean(avg_ticket_price, na.rm = TRUE), 2),
        `3rd Qu.` = round(quantile(avg_ticket_price, 0.75, na.rm = TRUE), 2),
        Max = round(max(avg_ticket_price, na.rm = TRUE), 2)
      )
    
    last_theater <- data %>%
      group_by(show) %>%
      summarise(last_theater = last(theater))
    
    combined <- left_join(summary_stats, last_theater, by = "show") %>%
      rename(
        `Show Name` = show,
        `Minimum Ticket Price` = Min,
        `1st Quartile Ticket Price` = `1st Qu.`,
        `Median Ticket Price` = Median,
        `Mean Ticket Price` = Mean,
        `3rd Quartile Ticket Price` = `3rd Qu.`,
        `Maximum Ticket Price` = Max,
        `Last Theater` = last_theater
      )
    
    DT::datatable(combined, options = list(pageLength = 10, autoWidth = TRUE))
  })
  
  #############################################
  ######### Total revenue by week tab #########
  #############################################  
  
  # Heat Map on "Total Revenue By Week" tab:
  output$heatmap_revenue_plot <- renderPlotly({
    req(input$selected_year)
    
    data <- broadway %>%
      filter(format(week_date, "%Y") == input$selected_year) %>%
      group_by(show, week_date) %>%
      summarise(total_gross = sum(this_week_gross), .groups = 'drop')
    
    if (nrow(data) == 0) {
      return(plotly::plot_ly() %>% 
               plotly::add_text(
                 text = paste("No shows were performed in the year", input$selected_year),
                 x = 0.5, y = 0.5,
                 textfont = list(size = 20),
                 showlegend = FALSE
               ) %>% 
               plotly::layout(
                 title = list(text = "No Data Available", x = 0.5),
                 xaxis = list(visible = FALSE),
                 yaxis = list(visible = FALSE)
               ))
    }
    
    # Calculate the dynamic height based on the number of unique shows
    num_shows <- n_distinct(data$show)
    dynamic_height <- num_shows * 25  # height of each show
    
    # Pivot the data to create a matrix for the heatmap
    # Create a text column for hover information
    data <- data %>%
      mutate(hover_text = paste("Show:", show, "<br>Week:", week_date, "<br>Total Revenue: $", scales::comma(total_gross)))
    
    plot_ly(
      data,
      x = ~week_date,
      y = ~show,
      z = ~total_gross,
      type = "heatmap",
      colorscale = "Viridis",
      text = ~hover_text,
      hoverinfo = "text"
    ) %>%
      layout(
        title = paste("Total Revenue by Week in", input$selected_year),
        xaxis = list(title = "Week Date"),
        yaxis = list(title = "Show"),
        height = dynamic_height#, #Set the desired height in pixel
        # width = 800
      )
  })
  
  
  #######################################
  ############## Theaters  ##############
  #######################################
  
  # Plot for Number of Shows per Theater
  # Update the decade choices based on the data
  
  # Preparation for the tables
  #######################################
  observe({
    decades <- sort(unique(broadway$decade))
    updateSelectInput(session, "selected_decade", choices = decades)
  })

  # Reactive data based on selected decade
  decade_data <- reactive({
    req(input$selected_decade)
    broadway %>%
      filter(decade == input$selected_decade)
  })
  
  # Update the theater choices for summary table
  observe({
    theaters <- sort(unique(broadway$theater))
    updateSelectInput(session, "selected_theater_summary", choices = theaters)
  })
  
  # Plots of theater stuff:
  #######################################
  output$shows_per_theater <- renderPlot({
    data <- decade_data() %>%
      group_by(theater) %>%
      summarise(num_shows = n_distinct(show), .groups = 'drop') %>%
      arrange(desc(num_shows))
    
    max_shows <- max(data$num_shows)
    
    p <- ggplot(data, aes(x = reorder(theater, num_shows), y = num_shows, fill = theater)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      coord_flip() +
      labs(title = "Number of Shows per Theater", x = "Theater", y = "Number of Shows") +
      custom_theme()
    
    if (max_shows <= 10) {
      p <- p + scale_y_continuous(breaks = 1:10)
    } else {
      p <- p + scale_y_continuous()
    }
    
    p
  })

  # Plot for Average Gross Revenue per Theater
  output$total_revenue_per_theater <- renderPlot({
    data <- decade_data() %>%
      group_by(theater) %>%
      summarise(avg_revenue = sum(this_week_gross, na.rm = TRUE), .groups = 'drop') %>%
      arrange(desc(avg_revenue))

    ggplot(data, aes(x = reorder(theater, avg_revenue), y = avg_revenue, fill = theater)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      coord_flip() +
      labs(title = "Total Revenue per Theater", x = "Theater", y = "Total Revenue ($)") +
      scale_y_continuous(labels = comma) +  
      custom_theme()
  })

  # Plot for Total Seats per Theater
  output$total_seats_per_theater <- renderPlot({
    data <- decade_data() %>%
      group_by(theater) %>%
      summarise(avg_seats = round(mean(seats_in_theater, na.rm = TRUE)), .groups = 'drop') %>%
      arrange(desc(avg_seats))

    ggplot(data, aes(x = reorder(theater, avg_seats), y = avg_seats, fill = theater)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      coord_flip() +
      labs(title = "Average Seats per Theater", x = "Theater", y = "Average Seats") +
      custom_theme()
  })

  # Plot for Average Ticket Price per Theater
  output$avg_ticket_price_per_theater <- renderPlot({
    data <- decade_data() %>%
      group_by(theater) %>%
      summarise(avg_ticket_price = mean(avg_ticket_price, na.rm = TRUE), .groups = 'drop') %>%
      arrange(desc(avg_ticket_price))

    ggplot(data, aes(x = reorder(theater, avg_ticket_price), y = avg_ticket_price, fill = theater)) +
      geom_bar(stat = "identity", show.legend = FALSE) +
      coord_flip() +
      labs(title = "Average Ticket Price per Theater", x = "Theater", y = "Average Ticket Price ($)") +
      custom_theme()
  })
  ############################# 
  ##### Shows by Theaters #####
  #############################
  # Table for Shows Presented in Selected Theater
  output$shows_in_theater <- renderDataTable({
    req(input$selected_theater)
    data <- filtered_data() %>%
      filter(theater == input$selected_theater) %>%
      select(show, week_date, this_week_gross, avg_ticket_price, seats_sold, capacity = seats_in_theater)
    
    datatable(data, options = list(pageLength = 10))
  })
  
  # Summary table for selected theater
  output$summary_table <- renderDataTable({
    req(input$selected_theater_summary)
    data <- broadway %>%
      filter(theater == input$selected_theater_summary) %>%
      group_by(show) %>%
      summarise(
        num_shows = n(),
        avg_ticket_price = round(mean(avg_ticket_price, na.rm = TRUE), 2),
        total_revenue = scales::comma(round(sum(this_week_gross, na.rm = TRUE), 2)),
        avg_sold_seats = round(mean(seats_sold, na.rm = TRUE), 2),
        start_date = min(week_date),
        end_date = max(week_date),
        .groups = 'drop'
      ) %>%
      rename(
        `Show Name` = show,
        `Number of Running Weeks` = num_shows,
        `Average Ticket Price` = avg_ticket_price,
        `Total Revenue` = total_revenue,
        `Average Weekly Sold Seats` = avg_sold_seats,
        `Start Date` = start_date,
        `End Date` = end_date
      )
    
    datatable(data, options = list(pageLength = 25))
  })
  ############################
  ##### Theater by Shows #####
  ############################
  # Table for Theaters Where Selected Show Was Performed
  output$show_theater_summary <- renderDataTable({
    req(input$selected_show)
    
    data <- broadway %>%
      filter(show == input$selected_show) %>%
      group_by(theater) %>%
      summarise(
        num_weeks = n(),
        avg_ticket_price = round(mean(avg_ticket_price, na.rm = TRUE), 2),
        total_revenue = scales::comma(round(sum(this_week_gross, na.rm = TRUE), 2)),
        avg_sold_seats = round(mean(seats_sold, na.rm = TRUE), 2),
        start_date = min(week_date),
        end_date = max(week_date),
        .groups = 'drop'
      ) %>%
      rename(
        `Theater Name` = theater,
        `Number of Running Weeks` = num_weeks,
        `Average Ticket Price` = avg_ticket_price,
        `Total Revenue` = total_revenue,
        `Average Weekly Sold Seats` = avg_sold_seats,
        `Start Date` = start_date,
        `End Date` = end_date
      )
    
    datatable(data, options = list(pageLength = 10, autoWidth = TRUE))
  })
  
  
  
  #######################################
  ############## About Me  ##############
  #######################################
  
  output$about <- renderUI({
    HTML("
    <h2>About Me</h2>
    <p><img src='./DSC_6228.jpg' alt='My Picture' style='width:150px; height:150px; border-radius:50%;'></p>
    <p>Hello! My name is Tomer Choresh. I am currently a student in NYC Data Science Academy in New York.</p>
    <p>This Shiny app is part of my portfolio to showcase my skills in data visualization and analysis.</p>
    <p>Feel free to connect with me on LinkedIn or check out my GitHub for more projects:</p>
    <ul>
      <li><a href='https://www.linkedin.com/in/tomer-choresh/' target='_blank'>LinkedIn</a></li>
      <li><a href='https://github.com/ChTomer/' target='_blank'>GitHub</a></li>
    </ul>
  ")
  })

  linkedin_url = a("LinkedIn", href="https://www.linkedin.com/in/tomer-choresh/")
  github_link = a("GitHub", href="https://github.com/ChTomer/")
  blog_link = a("Blog", href="https://nycdatascience.com/blog/author/tomer-choresh/")
  
  output$blog <- renderUI({
    tagList("Read my blog:", blog_link)
  })
  
  output$linkdein <- renderUI({
    tagList("Find me on LinkedIn:", linkedin_url)
  })
  output$github <- renderUI({
    tagList("Check out my GitHub:", github_link)
  })
  
  
})
