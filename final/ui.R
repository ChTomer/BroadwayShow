###################################################
####### broadway_grosses_historical version #######
###################################################

dashboardPage(
  # Title for the project
  dashboardHeader(title = "Broadway Shows"),
  ################################### 
  ########## Tabs / Slider ##########
  ################################### 
  dashboardSidebar( sidebarUserPanel("Tomer Choresh", image = './NYCDSA Background Removed.png'),
    sidebarMenu(
      menuItem("Introduction", tabName = "introduction", icon = icon("info")),
      menuItem("Top 20 Shows", tabName = "top_20_shows", icon = icon("trophy")),
      menuItem("Compare Shows", tabName = "compare_shows", icon = icon("chart-bar")),
      menuItem("Total Revenue by Week", tabName = "total_revenue_week", icon = icon("calendar-alt")),
      menuItem("Theaters", tabName = "theaters", icon = icon("building")),  # New Tab
      menuItem("About", tabName = "about", icon = icon("user"))
      
    )
  ),
  dashboardBody(
    #### Add custom CSS, mostly for the text, box and other relevant layouts
    tags$head(
    tags$style(HTML("
      .custom-description {
        font-size: 16px;
        color: #212121;
        font-family: Lato, sans-serif;
        margin-left: 30px;
        margin-top: 30px;
        margin-bottom: 30px;
        margin-right: 30px;
        
        
      }
      
      /* Custom styles for the box header */
      .box.box-solid.box-primary > .box-header {
        background-color: #7FB3D5;      /*  background color */
        color: #222d32;                 /*  text color */
        border-top-left-radius: 10px; /* Rounded top left corner */
        border-top-right-radius: 10px; /* Rounded top right corner */
        
      }
      
      .box-header .box-tools {
            float: left;
            margin-left: 10px;
            
      }
      
      .box.box-solid.box-primary {
        border: 1px solid transparent; 
        box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.1);
        background-color: #ecf0f5;
        border-radius: 10px;
      }
      .skin-blue .main-header .navbar {
              background-color: #7FB3D5;
      }
      
      
    "))
    ),
    
    tabItems(
      ################################### 
      ######## Introduction Tab #########
      ################################### 
      
      tabItem(tabName = "introduction",
              fluidRow(
                box(
                  # title = "Introduction",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  htmlOutput("project_summary", class = "custom-description")
                ),
              ),
              fluidRow(
                column(width = 12,
                       selectInput("selected_years", "Select Years for Comparison:", 
                                   choices = unique(format(broadway$week_date, "%Y")), 
                                   selected = unique(format(broadway$week_date, "%Y"))[1:4], 
                                   multiple = TRUE)
                )
              ),
              fluidRow(
                box(
                  title = "Total Weekly Revenue Comparison",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  plotlyOutput("revenue_comparison_plot")
                )
              )
              
      ),
      
      
      ################################### 
      ########### Top 20 tab ############
      ################################### 
      tabItem(tabName = "top_20_shows",
              tabsetPanel(
                tabPanel("Top 20 Shows by Revenue",
                         fluidRow(
                           box(
                             title = "Top 20 Shows by Revenue",
                             status = "primary",
                             solidHeader = TRUE,
                             width = 12,
                             plotOutput("top_20_revenue", width = "100%")
                           )
                         )
                ),
                tabPanel("Top 20 Shows by Average Weekly Revenue",
                         fluidRow(
                           box(
                             title = "Top 20 Shows by Average Weekly Revenue",
                             status = "primary",
                             solidHeader = TRUE,
                             width = 12,
                             plotOutput("top_20_avg_weekly_revenue")
                           )
                         )
                ),
                tabPanel("Top 20 Shows by Length of Running",
                         fluidRow(
                           box(
                             title = "Top 20 Shows by Length of Running",
                             status = "primary",
                             solidHeader = TRUE,
                             width = 12,
                             plotOutput("top_20_length")
                           )
                         )
                )
              )
      
      ),
      

      ################################### 
      ######## Compare Shows Tab ########
      ###################################
      tabItem(tabName = "compare_shows",
              fluidRow(
                column(width = 12,
                       box(
                         title = "User Guide - Compare Shows",
                         status = "primary",
                         solidHeader = TRUE,
                         width = 12,
                         collapsible = TRUE,
                         collapsed = FALSE,
                         htmlOutput("compare_shows_guide")
                       )
                )
              ),
              
              # 
              tabsetPanel(
                tabPanel("Compare Two Shows",
                fluidRow(
                  column(width = 6,
                         selectizeInput(inputId = "first_show",
                                        label = "Show 1:",
                                        choices = NULL,
                                        options = list(
                                          maxOptions = 1100,
                                          placeholder = 'Select a show',
                                          onInitialize = I('function() { this.setValue(""); }')
                                        ))
                  ),
                  column(width = 6,
                         selectizeInput(inputId = "second_show",
                                        label = "Show 2:",
                                        choices = NULL,
                                        options = list(
                                          maxOptions = 1100,
                                          placeholder = 'Select a show',
                                          onInitialize = I('function() { this.setValue(""); }')
                                        ))
                  )
                ),
                fluidRow(
                  column(width = 6,
                         sliderInput(inputId = "date_range",
                                     label = "Date Range:",
                                     min = as.integer(format(min(broadway$week_date), "%Y")),
                                     max = as.integer(format(max(broadway$week_date), "%Y")),
                                     value = c(as.integer(format(min(broadway$week_date), "%Y")), 
                                               as.integer(format(max(broadway$week_date), "%Y"))),
                                     step = 1,
                                     sep = "")
                  ),
                  column(width = 6,
                         selectInput(inputId = "comparison_type",
                                     label = "Comparison Type:",
                                     choices = c("Revenue Difference", 
                                                 "Length of Show", 
                                                 "Seats Sold Each Week", 
                                                 "Average Ticket Price"))
                  )
                ),
                fluidRow(
                  box(
                    title = "Comparison Between 2 Shows",
                    status = "primary",
                    solidHeader = TRUE,
                    width = 12,
                    plotlyOutput("comparison_plot")
                  )
                ),
                fluidRow(
                  box(
                    title = "Show 1 Summary",
                    status = "primary",
                    solidHeader = TRUE,
                    width = 6,
                    htmlOutput("first_show_summary")#,
                    # htmlOutput("first_show_detailed_summary")  # Add this line
                  ),
                  box(
                    title = "Show 2 Summary",
                    status = "primary",
                    solidHeader = TRUE,
                    width = 6,
                    htmlOutput("second_show_summary")#,
                    # htmlOutput("second_show_detailed_summary")  # Add this line
                ))
              ),
              
              
              tabPanel("Average Ticket Price Destribution",
                       tabPanel("Compare Shows",
                                fluidRow(
                                  box(
                                    title = "Select Shows",
                                    status = "primary",
                                    solidHeader = TRUE,
                                    width = 12,
                                    selectizeInput("selected_shows", "Select Shows To Compare:", 
                                                choices = NULL, 
                                                selected = unique(broadway$show)[1:2], 
                                                multiple = TRUE)
                                  )
                                ),
                                fluidRow(
                                  box(
                                    title = "Average Ticket Prices (Violin Plot)",
                                    status = "primary",
                                    solidHeader = TRUE,
                                    width = 12,
                                    plotOutput("violin_plot_avg_ticket_prices")
                                  )
                                ),
                                fluidRow(
                                  box(
                                    title = "Yearly Difference in Gross Revenue",
                                    status = "primary",
                                    solidHeader = TRUE,
                                    width = 12,
                                    plotOutput("yearly_difference_gross")
                                  )
                                ),
                                fluidRow(
                                  box(
                                    title = "Summary of Selected Shows",
                                    status = "primary",
                                    solidHeader = TRUE,
                                    width = 12,
                                    DT::dataTableOutput("selected_shows_summary")
                                  )
                                )
                       )
                
              )
              
              )
      ),
      
      # Total revenue by week tab
      tabItem(tabName = "total_revenue_week",
              fluidRow(
                column(width = 12,
                       box(
                         title = "User Guide - Total Revenue by Week",
                         status = "primary",
                         solidHeader = TRUE,
                         width = 12,
                         collapsible = TRUE,
                         collapsed = FALSE,
                         htmlOutput("total_revenue_guide")
                       )
                )
              ),
              fluidRow(
                column(width = 6, height = 200,
                       selectInput(inputId = "selected_year",
                                   label = "Select Year:",
                                   choices = unique(format(broadway$week_date, "%Y")))
                )
              ),
              fluidRow(
                box(
                  title = "Total Revenue by Week",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  height = "800px",
                  style = "height:680px; overflow-y: scroll;",
                  
                  plotlyOutput("heatmap_revenue_plot", height = "800px")
                )
              )
      ),
      
      
      ###################################       
      ########## Theaters Tab ###########
      ################################### 
      
      tabItem(tabName = "theaters",
              tabsetPanel(
                tabPanel("Theaters by Decades",
                         fluidRow(
                           column(width = 4,
                                  selectInput("selected_decade", 
                                              "Select Decade:", 
                                              choices = NULL)
                           )
                         ),
                         fluidRow(
                           box(
                             title = "Number of Shows per Theater",
                             status = "primary",
                             solidHeader = TRUE,
                             width = 12,
                             plotOutput("shows_per_theater", height = "550px")
                           )
                         ),
                         fluidRow(
                           box(
                             title = "Total Revenue per Theater",
                             status = "primary",
                             solidHeader = TRUE,
                             width = 12,
                             plotOutput("total_revenue_per_theater", height = "550px")
                           )
                         ),
                         fluidRow(
                           box(
                             title = "Average Seats in Theater",
                             status = "primary",
                             solidHeader = TRUE,
                             width = 12,
                             plotOutput("total_seats_per_theater", height = "550px")
                           )
                         ),
                         fluidRow(
                           box(
                             title = "Average Ticket Price per Theater",
                             status = "primary",
                             solidHeader = TRUE,
                             width = 12,
                             plotOutput("avg_ticket_price_per_theater", height = "550px")
                           )
                         )
                ),
                tabPanel("Shows by Theaters",
                         fluidRow(
                           column(width = 12,
                                  box(
                                    title = "User Guide - Show by Theater",
                                    status = "primary",
                                    solidHeader = TRUE,
                                    width = 12,
                                    collapsible = TRUE,
                                    collapsed = FALSE,
                                    htmlOutput("show_by_theaters_guide")
                                  ))
                         ),
                         fluidRow(
                           column(width = 4,
                                  selectInput("selected_theater_summary", 
                                              "Select Theater for Summary:", 
                                              choices = NULL)
                           )
                         ),
                         fluidRow(
                           box(
                             title = "Summary of shows in Selected Theater",
                             status = "primary",
                             solidHeader = TRUE,
                             width = 12,
                             dataTableOutput("summary_table")
                           )
                         )
                ),
                
                
                tabPanel("Theaters by Shows",
                         fluidRow(
                           column(width = 12,
                                  box(
                                    title = "User Guide - Theater by Show",
                                    status = "primary",
                                    solidHeader = TRUE,
                                    width = 12,
                                    collapsible = TRUE,
                                    collapsed = FALSE,
                                    htmlOutput("theater_by_show_guide")
                                  ))
                         ),
                         fluidRow(
                           column(width = 4,
                                  selectizeInput("selected_show", 
                                              "Select Show for Theater Details:", 
                                              choices = NULL,
                                              selected = NULL,
                                              multiple = FALSE)
                           )
                         ),
                         fluidRow(
                           box(
                             title = "Theater Details for Selected Show",
                             status = "primary",
                             solidHeader = TRUE,
                             width = 12,
                             dataTableOutput("show_theater_summary")
                           )
                         )
                )
                
              )
      )
      ,
      
      
      ################################### 
      ######## About Myself Tab  ########
      ################################### 
      tabItem(tabName = "about",
              fluidRow(
                box(
                  title = "About Me:",
                  status = "primary",
                  solidHeader = TRUE,
                  width = 12,
                  htmlOutput("about_me"),
                  
                  h4("Hello! My name is Tomer Choresh. I am currently a student in NYC Data Science Academy in New York.", style="text-align:center"),
                  h4("This Shiny app is part of my portfolio to showcase my skills in data visualization and analysis.", style="text-align:center"),
                  h4("Feel free to connect with me on LinkedIn or check out my GitHub or Blog for more projects:", style="text-align:center"),
                  div(img(src="./DSC_6228.png",# height='25%', width='25%'),
                          style = "width: 150px; height: 150px; object-fit: cover; object-position: 50% 20%;"),
                          style="text-align:center"),
                  
                  uiOutput("linkdein"),
                  uiOutput("github"),
                  uiOutput("blog")
                )
              )
      )
      
    )
  )
)