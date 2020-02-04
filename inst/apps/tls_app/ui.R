
library(shiny)
library(shinyhelper)

srhelp <- function(x, ...){
  helper(x, ..., colour="lightgrey")
}

source("ui-frame-generator.R")
source("ui-sample-generator.R")
source("ui-weight-calculator.R")

shinyUI(
  navbarPage(
    p('Time Location Sampling Tool',style="padding-right: 20px;") %>% srhelp(content="main"),
    tabPanel(
      p("Generate Population Frame",style="padding-right: 20px;") %>% srhelp(content="pop_tab"),
      ui_frame_generator()
    ),
    tabPanel(
      p("Generate TLS Sample Frame",style="padding-right: 20px;") %>% srhelp(content="samp_tab"),
      ui_sample_generator()
    ),
    tabPanel(
      p("Calculate TLS Weights",style="padding-right: 20px;") %>% srhelp(content="wts_tab"),
      ui_weight_calculator()
    )
  )
)
