
library(shiny)
options(shiny.maxRequestSize=300*1024^2)

source("server-frame-generator.R")
source("server-sample-generator.R")
source("server-weight-calculator.R")

shinyServer(function(input, output, session) {
  server_frame_generator(input, output, session)
  server_sample_generator(input, output, session)
  server_weight_calculator(input, output, session)
  observe_helpers()
})
