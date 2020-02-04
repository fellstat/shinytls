
ui_frame_generator <- function(){
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
            tabPanel("Population Frame",
                     br(),
                     br(),
                     br(),
                     downloadButton("download","Download Population Frame"),
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
}
