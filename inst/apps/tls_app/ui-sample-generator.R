library(shiny)
library(shinyWidgets)

ui_sample_generator <- function(){
  tabPanel(
    'Generate Frame',
    fluidPage(
      # Application title
      titlePanel("Raw Data"),

      # Sidebar with a slider input for number of bins
      sidebarLayout(sidebarPanel(
        fileInput(
          "file2",
          "Choose CSV File",
          accept = c("text/csv",
                     "text/comma-separated-values,text/plain",
                     ".csv")
        ),
        conditionalPanel(
          "output.table2 != null",
          selectizeInput("locations2", "Venue:",
                         c("")),
          selectizeInput("location_type2", "Venue type (optional):",
                         c("")),
          selectizeInput("day2", "Day of week:",
                         c("")),
          selectizeInput("time2", "Time:",
                         c("")),
          selectizeInput("num_observed", "# of individuals observed:",
                         c(""))
        ),
        numericInput("nsamp","Venue visit sample size", value =100, min=2, step=1, max=100000000),
        numericInput("nweeks","Survey length (weeks)", value =1, min=2, step=1, max=100000000),
        numericInput("maxsamp","Maximum number of individuals sampled per visit", value =20, min=1, step=1, max=100000000),
        checkboxInput("strat_type", "Stratify by venue type", value=FALSE),
        checkboxInput("strat_dow", "Stratify by day of week", value=FALSE),
        checkboxInput("strat_time", "Stratify by time", value=FALSE),
        width = 5),
        mainPanel(

          tabsetPanel(
            tabPanel("Raw Data",
                     br(),
                     br(),
                     br(),
                     tableOutput("table2")
            ),
            tabPanel("Sample Frame",
                     br(),
                     br(),
                     br(),
                     downloadButton("download2","Download Sample Frame"),
                     br(),
                     br(),
                     br(),
                     tableOutput("sampletable2")
            ),
            tabPanel("Diagnostics",
                     br(),
                     br(),
                     h2("Imputation Model"),
                     verbatimTextOutput("imputation_model_output")
            )
          ),
          width = 7)
      )
    )
  )
}
