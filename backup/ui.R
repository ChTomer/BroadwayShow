library(shiny)
library(shinydashboard)
library(plotly)

dashboardPage(
  dashboardHeader(title = "Broadway Shows Comparison"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Top 20 Shows", tabName = "top_20_shows", icon = icon("trophy")),
      menuItem("Compare Shows", tabName = "compare_shows", icon = icon("chart-bar")),
      menuItem("Total Revenue by Week", tabName = "total_revenue_week", icon = icon("calendar-alt")),
      menuItem("Show Summary", tabName = "show_explanation", icon = icon("info-circle")),
      menuItem("Regression Analysis", tabName = "regression_analysis", icon = icon("chart-line"))
    )
  ),
  dashboardBody(
    # Add custom CSS
    tags$style(HTML("
      .custom-description {
        font-size: 16px;
        font-weight: bold;
        color: #333;
        font-family: Arial, sans-serif;
      }
    ")),
    
    tabItems(
      # Top 20 Shows Tab
      tabItem(tabName = "top_20_shows",
              fluidRow(
                box(
                  title = "Top 20 Shows by Revenue",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  plotOutput("top_20_revenue")
                )
              ),
              fluidRow(
                box(
                  title = "Top 20 Shows by Average Weekly Revenue",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  plotOutput("top_20_avg_revenue")
                )
              ),
              fluidRow(
                box(
                  title = "Top 20 Shows by Length of Running",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  plotOutput("top_20_length")
                )
              )
      ),
      # Compare Shows Tab
      tabItem(tabName = "compare_shows",
              fluidRow(
                column(width = 6,
                       selectizeInput(inputId = "first_show",
                                      label = "Show 1:",
                                      choices = NULL,
                                      options = list(maxOptions = 100))
                ),
                column(width = 6,
                       selectizeInput(inputId = "second_show",
                                      label = "Show 2:",
                                      choices = NULL,
                                      options = list(maxOptions = 100))
                )
              ),
              fluidRow(
                column(width = 6,
                       dateRangeInput(inputId = "date_range",
                                      label = "Date Range:",
                                      start = min(broadway$week_date),
                                      end = max(broadway$week_date))
                ),
                column(width = 6,
                       selectInput(inputId = "comparison_type",
                                   label = "Comparison Type:",
                                   choices = c("Revenue Difference", "Length of Show", "Seats Sold Each Week", "Average Ticket Price"))
                )
              ),
              fluidRow(
                box(
                  title = "Comparison Result",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  plotOutput("comparison_plot")
                )
              )
      ),
      # Total Revenue by Week Tab
      tabItem(tabName = "total_revenue_week",
              fluidRow(
                column(width = 4,
                       selectInput(inputId = "selected_year",
                                   label = "Select Year:",
                                   choices = unique(format(broadway$week_date, "%Y")))
                ),
                column(width = 4,
                       selectizeInput(inputId = "selected_shows",
                                      label = "Select Shows:",
                                      choices = NULL,
                                      multiple = TRUE,
                                      options = list(maxOptions = 100))
                ),
                column(width = 4,
                       dateRangeInput(inputId = "selected_date_range",
                                      label = "Select Date Range:",
                                      start = min(broadway$week_date),
                                      end = max(broadway$week_date))
                )
              ),
              fluidRow(
                box(
                  title = "Total Revenue by Week",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  plotlyOutput("total_revenue_plot")
                )
              )
      ),
      # Show Explanation Tab
      tabItem(tabName = "show_explanation",
              fluidRow(
                column(width = 4,
                       selectizeInput(inputId = "selected_show",
                                      label = "Select a Show:",
                                      choices = NULL,
                                      options = list(maxOptions = 100))
                ),
                column(width = 8,
                       htmlOutput("show_description", class = "custom-description")
                )
              )
      ),
      # Regression Analysis Tab
      tabItem(tabName = "regression_analysis",
              fluidRow(
                box(
                  title = "Regression Model Summary",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  verbatimTextOutput("regression_summary")
                )
              ),
              fluidRow(
                box(
                  title = "Regression Plot",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  plotOutput("regression_plot")
                )
              )
      )
      
    )
  )
)