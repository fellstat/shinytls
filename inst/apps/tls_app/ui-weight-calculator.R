
ui_weight_calculator <- function(){

  tabPanel(
    'Generate Frame',
    fluidPage(
      # Application title
      titlePanel("Raw Data"),

      # Sidebar with a slider input for number of bins
      sidebarLayout(sidebarPanel(
        fileInput(
          "file_wt",
          "Choose CSV File",
          accept = c("text/csv",
                     "text/comma-separated-values,text/plain",
                     ".csv")
        ),
        conditionalPanel(
          "output.table_wt != null",
          selectizeInput("samp_prob_wt", "Venue/Time Sampling Probability:",
                         c("")),
          selectizeInput("strata_wt", "Sampling Strata (optional):",
                         c("")),
          selectizeInput("locations_wt", "Venue:",
                         c("")),
          selectizeInput("day_wt", "Day of week:",
                         c("")),
          selectizeInput("time_wt", "Time:",
                         c("")),
          selectizeInput("num_observed_wt", "# of individuals observed:",
                         c(""))
        ),
        numericInput("n_rep_wts","Number of Bootstrap Replicate Weights", value =100, min=2, step=1, max=10000),
        width = 5),
        mainPanel(

          tabsetPanel(
            tabPanel("Raw Data",
                     br(),
                     br(),
                     br(),
                     tableOutput("table_wt")
            ),
            tabPanel("Sample Weights",
                     br(),
                     br(),
                     br(),
                     downloadButton("download_wt","Download Data with Weights"),
                     br(),
                     br(),
                     br(),
                     tableOutput("result_table_wt")
            )
          ),
          width = 7)
      )
    )
  )
}
