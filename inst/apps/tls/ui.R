library(shiny)
library(shinyWidgets)
# Define UI for application that draws a histogram
shinyUI(navbarPage(
    'Time Location Sampling - Frame Generator',
    #tag$script(HTML("updateFirstMultiInput = function(x){ var event = new Event('input'); $('.multi-wrapper .search-input').get(0).dispatchEvent(event);};Shiny.addCustomMessageHandler('updateFirstMultiInput', updateFirstMultiInput);")),
    tabPanel(
        'Introduction',
        #includeScript("updateMulti.js"),
        h4('Welcome to The Time Location Sampling Frame Generator'),
        br(),
        p(
            "The purpose of this tool is to create a data frame containing all possible combinations of locations and times. Input data with venue information should be provided in comma separated format containing the following columns with column headers:"
        ),
        p(
            "Venue - This column is the names of the venues available to sample from"
        ),
        p(
            "Venue type - This column is optional and represents the type of venue (e.g. bar, health facility, ...)"
        ),
        p(
            "Days of Week Open - This column contains the days of the week the venue is open. days should be separated by a single space. For example \"monday tuesday thursday\""
        ),
        p(
            "Times Open - This column contains the times (separated by a single space) that the venue is open. These may be time ranges, or descriptors like 'morning' or 'evening'."
        ),
        br()
    ),
    tabPanel(
        'Generate Frame',
        fluidPage(
            # Application title
            titlePanel("Raw Data"),

            # Sidebar with a slider input for number of bins
            sidebarLayout(sidebarPanel(
                fileInput(
                    "file1",
                    "Choose CSV File",
                    accept = c("text/csv",
                               "text/comma-separated-values,text/plain",
                               ".csv")
                ),
                conditionalPanel(
                    "output.table != null",
                    selectizeInput("locations", "Venue:",
                                   c("")),
                    selectizeInput("location_type", "Venue type (optional):",
                                   c("")),
                    selectizeInput("days_open", "Days of week venue is open:",
                                   c("")),
                    selectizeInput("times_open", "Times venue is open:",
                                   c(""))
                ),
                width = 5),
                mainPanel(

                    tabsetPanel(
                        tabPanel("Raw Data",
                             br(),
                             br(),
                             br(),
                            tableOutput("table")
                        ),
                        tabPanel("Sample Frame",
                                 br(),
                                 br(),
                                 br(),
                            downloadButton("download","Download Sample Frame"),
                            br(),
                            br(),
                            br(),
                            tableOutput("sampletable")
                        )
                    ),
                      width = 7)
            )
        )
    )
))
