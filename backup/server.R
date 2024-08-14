library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(scales)

function(input, output, session) {
  
  # Populate selectize inputs with server-side processing
  updateSelectizeInput(session, "first_show", choices = unique(broadway$show), server = TRUE)
  updateSelectizeInput(session, "second_show", choices = unique(broadway$show), server = TRUE)
  updateSelectizeInput(session, "selected_shows", choices = unique(broadway$show), server = TRUE)
  updateSelectizeInput(session, "selected_show", choices = unique(broadway$show), server = TRUE)
  updateSelectizeInput(session, "selected_show", choices = unique(show_summaries$show), server = TRUE)

  
  # Reactive for show descriptions
  selected_description <- reactive({
    show_summaries %>%
      filter(show == input$selected_show) %>%
      select(description) %>%
      pull()
  })
  
  output$show_description <- renderUI({
    req(input$selected_show)
    HTML(selected_description())
  })
  
  
  filtered_data <- reactive({
    broadway %>%
      filter(show %in% c(input$first_show, input$second_show)) %>%
      filter(week_date >= input$date_range[1] & week_date <= input$date_range[2])
  })
  
  output$comparison_plot <- renderPlot({
    data <- filtered_data()
    
    if (input$comparison_type == "Revenue Difference") {
      data <- data %>%
        group_by(show, week_date) %>%
        summarise(total_gross = sum(gross), .groups = 'drop')
      
      ggplot(data, aes(x = week_date, y = total_gross, color = show)) +
        geom_line() +
        geom_point() +
        theme_minimal() +
        labs(title = "Revenue Difference", x = "Week Date", y = "Total Gross")
      
    } else if (input$comparison_type == "Length of Show") {
      data <- data %>%
        group_by(show) %>%
        summarise(length_of_run = n_distinct(week_date), .groups = 'drop')
      
      ggplot(data, aes(x = show, y = length_of_run, fill = show)) +
        geom_bar(stat = "identity") +
        theme_minimal() +
        labs(title = "Length of Show", x = "Show", y = "Number of Weeks")
      
    } else if (input$comparison_type == "Seats Sold Each Week") {
      data <- data %>%
        group_by(show, week_date) %>%
        summarise(total_seats = sum(seats_sold), .groups = 'drop')
      
      ggplot(data, aes(x = week_date, y = total_seats, color = show)) +
        geom_line() +
        geom_point() +
        theme_minimal() +
        labs(title = "Seats Sold Each Week", x = "Week Date", y = "Total Seats Sold")
      
    } else if (input$comparison_type == "Average Ticket Price") {
      data <- data %>%
        group_by(show, week_date) %>%
        summarise(avg_ticket_price = mean(avg_ticket_price), .groups = 'drop')
      
      ggplot(data, aes(x = week_date, y = avg_ticket_price, color = show)) +
        geom_line() +
        geom_point() +
        theme_minimal() +
        labs(title = "Average Ticket Price", x = "Week Date", y = "Average Ticket Price")
    }
  })
  
  output$top_20_revenue <- renderPlot({
    data <- broadway %>%
      group_by(show) %>%
      summarise(total_gross = sum(gross), .groups = 'drop') %>%
      top_n(20, total_gross) %>%
      arrange(desc(total_gross))
    
    ggplot(data, aes(x = reorder(show, total_gross), y = total_gross, fill = show)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      theme_minimal() +
      scale_y_continuous(labels = comma) +  # Format y-axis labels
      labs(title = "Top 20 Shows by Revenue", x = "Show", y = "Total Gross Revenue") +
      theme(legend.position = "none", 
            plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
            axis.title.x = element_text(size = 12),
            axis.title.y = element_text(size = 12),
            axis.text = element_text(size = 10))
  })
  
  output$top_20_avg_revenue <- renderPlot({
    data <- broadway %>%
      group_by(show) %>%
      summarise(avg_weekly_gross = mean(gross), .groups = 'drop') %>%
      top_n(20, avg_weekly_gross) %>%
      arrange(desc(avg_weekly_gross))
    
    ggplot(data, aes(x = reorder(show, avg_weekly_gross), y = avg_weekly_gross, fill = show)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      theme_minimal() +
      labs(title = "Top 20 Shows by Average Weekly Revenue", x = "Show", y = "Average Weekly Revenue") +
      theme(legend.position = "none", 
            plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
            axis.title.x = element_text(size = 12),
            axis.title.y = element_text(size = 12),
            axis.text = element_text(size = 10))
  })
  
  output$top_20_length <- renderPlot({
    data <- broadway %>%
      group_by(show) %>%
      summarise(length_of_run = n_distinct(week_date), .groups = 'drop') %>%
      top_n(20, length_of_run) %>%
      arrange(desc(length_of_run))
    
    ggplot(data, aes(x = reorder(show, length_of_run), y = length_of_run, fill = show)) +
      geom_bar(stat = "identity", alpha = 0.7) +
      coord_flip() +
      theme_minimal() +
      labs(title = "Top 20 Shows by Length of Running", x = "Show", y = "Number of Weeks") +
      theme(legend.position = "none", 
            plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
            axis.title.x = element_text(size = 12),
            axis.title.y = element_text(size = 12),
            axis.text = element_text(size = 10))
  })
  
  output$total_revenue_plot <- renderPlotly({
    validate(
      need(input$selected_shows, "Please select at least one show."),
      need(!is.null(input$selected_year), "Please select a year.")
    )
    
    data <- broadway %>%
      filter(format(week_date, "%Y") == input$selected_year) %>%
      filter(show %in% input$selected_shows) %>%
      filter(week_date >= input$selected_date_range[1] & week_date <= input$selected_date_range[2]) %>%
      group_by(week_date) %>%
      summarise(total_gross = sum(gross), .groups = 'drop')
    
    if (nrow(data) == 0) {
      return(plotly::plot_ly() %>% 
               plotly::add_text(
                 text = paste("The selected show(s) did not perform in the year", input$selected_year),
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
    p <- ggplot(data, aes(x = week_date, y = total_gross)) +
      geom_line(color = "blue", size = 1) +
      geom_point(color = "blue") +
      theme_minimal() +
      labs(title = paste("Total Revenue by Week in", input$selected_year), 
           x = "Week Date", 
           y = "Total Gross Revenue")
    
    ggplotly(p, tooltip = "y")
  })
  
  # Regression Analysis
  regression_data <- reactive({
    broadway %>%
      filter(!is.na(avg_ticket_price) & !is.na(gross) & !is.na(seats_sold)) %>%
      select(avg_ticket_price, gross, seats_sold)
  })
  
  output$regression_summary <- renderPrint({
    data <- regression_data()
    model <- lm(gross ~ avg_ticket_price + seats_sold, data = data)
    summary(model)
  })
  
  output$regression_plot <- renderPlot({
    data <- regression_data()
    model <- lm(gross ~ avg_ticket_price + seats_sold, data = data)
    
    ggplot(data, aes(x = avg_ticket_price, y = gross)) +
      geom_point() +
      geom_smooth(method = "lm", se = FALSE, color = "blue") +
      theme_minimal() +
      labs(title = "Regression of Gross Revenue on Average Ticket Price and Seats Sold",
           x = "Average Ticket Price",
           y = "Gross Revenue")
  })
}
