library(tidyverse)
library(survey)

server_weight_calculator <- function(input, output, session){

  get_raw_data <- reactive({
    inFile <- input$file_wt

    if (is.null(inFile))
      return(NULL)

    dat <- read.csv(inFile$datapath, header = TRUE, stringsAsFactors = FALSE)
    vars <- names(dat)
    for(name in c("samp_prob_wt", "strata_wt","locations_wt","day_wt", "time_wt", "num_observed_wt"))
      updateSelectizeInput(session, name, choices = c("Choose Variable"="",vars))
    dat
  })

  get_sample_weights <- reactive({
    dat <- get_raw_data()
    if(is.null(dat))
      return (NULL)
    if(is.null(input$samp_prob_wt) || input$samp_prob_wt == ""){
      showNotification("Please select a variable for the venue-time sampling probability")
      return(NULL)
    }
    if(is.null(input$locations_wt) || input$locations_wt == ""){
      showNotification("Please select a variable for the venue")
      return(NULL)
    }
    if(is.null(input$time_wt) || input$time_wt == ""){
      showNotification("Please select a variable for the time of day")
      return(NULL)
    }
    if(is.null(input$day_wt) || input$day_wt == ""){
      showNotification("Please select a variable for the day of the week")
      return(NULL)
    }
    if(is.null(input$num_observed_wt) || input$num_observed_wt == ""){
      showNotification("Please select a variable for the numbr of individuals observed at the location during the time of sampling")
      return(NULL)
    }

    strata <- if(is.null(input$strata_wt) || input$strata_wt == "") "_" else as.character(dat[[input$strata_wt]])
    df <- data.frame(
      location = as.character(dat[[input$locations_wt]]),
      day_of_week = as.character(dat[[input$day_wt]]),
      time_of_day = as.character(dat[[input$time_wt]]),
      sampling_strata = strata,
      selection_probability = as.numeric(dat[[input$samp_prob_wt]]),
      subjects_observed = as.numeric(dat[[input$num_observed_wt]])
    )
    tmp <- df %>% group_by(location, day_of_week, time_of_day) %>% summarise(n_sampled=n())
    df <- merge(df,tmp)
    df$analysis_weights <- df$subjects_observed / (df$selection_probability * df$n_sampled)
    df$obs_id <- 1:nrow(df)
    df$cluster_id <- paste0(df$location,df$day_of_week,df$time_of_day,sep="_")
    dsn <- svydesign(id=~cluster_id + obs_id, weights=~analysis_weights, data=df, strata = ~sampling_strata)
    rep_dsn <- as.svrepdesign(dsn,type="bootstrap", replicates=input$n_rep_wts)
    rep_wts <- weights(rep_dsn)
    rep_wts <- as.data.frame(sweep(rep_wts, 1, df$analysis_weights, FUN = "*"))
    names(rep_wts) <- paste0("rep_weights_", 1:ncol(rep_wts))
    #df <- cbind(df,rep_wts)
    dat_wt <- cbind(dat, df[c("cluster_id","obs_id","analysis_weights")], rep_wts)
    dat_wt
  })

  output$table_wt <- renderTable({
    if(is.null(get_raw_data()))
      return(NULL)
    get_raw_data()
  })

  output$result_table_wt <- renderTable({
    if(is.null(get_raw_data()))
      return(NULL)
    get_sample_weights()
  })

  output$download_wt <- downloadHandler(
    filename = function() {
      paste('tls-data-with-weights-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      dat <- get_sample_weights()
      if(is.null(dat))
        return()
      write.csv(dat, con, row.names = FALSE)
    }
  )


}
