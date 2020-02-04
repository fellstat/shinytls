
server_sample_generator <- function(input,output,session){

  get_raw_data <- reactive({
    inFile <- input$file2

    if (is.null(inFile))
      return(NULL)

    dat <- read.csv(inFile$datapath, header = TRUE, stringsAsFactors = FALSE)
    vars <- names(dat)
    for(name in c("locations2", "location_type2","day2","time2", "num_observed"))
      updateSelectizeInput(session, name, choices = c("Choose Variable"="",vars))
    dat
  })

  imputation_model <- reactiveVal(NULL)

  get_sample_frame <- reactive({
    if(is.null(get_raw_data()))
      return(NULL)
    df <- get_raw_data()
    if(is.null(input$locations2) || input$locations2 == ""){
      showNotification("Please select a variable for the study location")
      return(NULL)
    }
    if(is.null(input$day2) || input$day2 == ""){
      showNotification("Please select a variable for the day of the week")
      return(NULL)
    }

    if(is.null(input$time2) || input$time2 == ""){
      showNotification("Please select a variable for the time of day")
      return(NULL)
    }

    if(is.null(input$num_observed) || input$num_observed == ""){
      showNotification("Please select a variable for the number of subjects observed")
      return(NULL)
    }

    #if(input$days == ""){
    #    showNotification("Please select a variable for the days of the week that the venue is open")
    #    return(NULL)
    #}
    #if(input$time == ""){
    #    showNotification("Please select a variable for the times of the day that the venue is open")
    #    return(NULL)
    #}
    location <- as.factor(df[[input$locations2]])
    day_of_week <- as.factor(df[[input$day2]])
    if(is.null(input$location_type2) || input$location_type2 != "")
      location_type2 <- as.factor(df[[input$location_type2]])
    else
      location_type2 <- as.factor("none")
    time_of_day <- as.factor(df[[input$time2]])
    subject_count <- as.numeric(df[[input$num_observed]])
    df2 <- data.frame(
      location = location,
      location_type2 = location_type2,
      time_of_day = time_of_day,
      day_of_week = day_of_week,
      subject_count = subject_count
    )
    if(any(is.na(df2[1:4]))){
      showNotification("Missing values are only allowed in the subject count variable.")
      return(NULL)
    }
    df_obs <- na.omit(df2)
    mod <- glmer(subject_count ~ 1 +
                   (1 | location) +
                   (1 | time_of_day) +
                   (1 | day_of_week) +
                   (1 | location_type2),
                 data=df_obs,
                 family = poisson(),
                 nAGQ = 0)

    try({
      mod2 <- glmer(subject_count ~ 1 +
                     (1 | location) +
                     (1 | time_of_day) +
                     (1 | day_of_week) +
                     (1 | location_type2),
                   data=df_obs,
                   family = poisson(),
                   nAGQ = 0)
      if(AIC(mod2) < AIC(mod)){
        mod <- mod2
      }
    })

    try({
      mod2 <- glmer(subject_count ~ 1 +
                      (1 | location) +
                      (1 | day_of_week / time_of_day) +
                      (1 | location_type2),
                    data=df_obs,
                    family = poisson(),
                    nAGQ = 0)
      if(AIC(mod2) < AIC(mod)){
        mod <- mod2
      }
    })

    try({
      mod2 <- glmer(subject_count ~ 1 +
                      (1 | location) +
                      (1 | location_type2 / day_of_week / time_of_day),
                    data=df_obs,
                    family = poisson(),
                    nAGQ = 0)
      if(AIC(mod2) < AIC(mod)){
        mod <- mod2
      }
    })
    df2$expected_count <- predict(mod,
                                  newdata=df2,
                                  allow.new.levels=TRUE,
                                  type="response")
    sampling_strata <- rep("_", nrow(df2))
    if(input$strat_type){
      sampling_strata <- paste0(sampling_strata, df2$location_type2,sep="_")
    }
    if(input$strat_dow){
      sampling_strata <- paste0(sampling_strata, df2$day_of_week,sep="_")
    }
    if(input$strat_time){
      sampling_strata <- paste0(sampling_strata, df2$time_of_day,sep="_")
    }
    sampling_strata <- as.factor(sampling_strata)
    tot_by_group <- table(sampling_strata)
    nsamp_by_group <- rep(floor(input$nsamp * 1 / length(tot_by_group)), length(tot_by_group))
    if(sum(nsamp_by_group) < input$nsamp){
      add_one_group <- sample.int(length(nsamp_by_group), size=1)
      nsamp_by_group[add_one_group] <- nsamp_by_group[add_one_group] + 1
    }
    #browser()
    df2$sample <- FALSE
    df2$sampling_strata <- sampling_strata
    df2$venue_time_within_strata_selection_prob <- NA
    df2$strata_selection_prob <- NA
    for(i in 1:length(nsamp_by_group)){
      lv <- names(tot_by_group)[i]
      val <- as.numeric(nsamp_by_group[i])
      sel_prob <- df2$expected_count[sampling_strata == lv] / pmin(input$maxsamp, df2$expected_count[sampling_strata == lv])
      samp_ids <- sample.int(
        n=sum(sampling_strata == lv),
        size = val,
        prob = sel_prob)
      df2[sampling_strata == lv, ][samp_ids,"sample"] <- TRUE
      df2$venue_time_within_strata_selection_prob[sampling_strata == lv] <- sel_prob / sum(sel_prob)
      df2$strata_selection_prob[sampling_strata == lv] <- val / sum(nsamp_by_group)
    }
    df2$n_to_recruit_at_site <- paste("as many as are at the venue with a maximum of", input$maxsamp)
    df2$selection_probability <- input$nsamp *
      df2$venue_time_within_strata_selection_prob *
      df2$strata_selection_prob
    df2$venue_time_within_strata_selection_prob <- NULL
    df2_samp <- df2[df2$sample,]
    df2_samp$sample <- NULL
    df2_samp$sampling_week <- sample.int(input$nweeks, size=nrow(df2_samp), replace=TRUE)
    imputation_model(mod)
    df2_samp
  })

  output$table2 <- renderTable({
    if(is.null(get_raw_data()))
      return(NULL)
    get_raw_data()
  })

  output$imputation_model_output <- renderPrint({
    print(summary(imputation_model()))
  })

  output$sampletable2 <- renderTable({
    if(is.null(get_sample_frame()))
      return(NULL)
    get_sample_frame()
  })

  output$download2 <- downloadHandler(
    filename = function() {
      paste('tls-sample-', Sys.Date(), '.csv', sep='')
    },
    content = function(con) {
      dat <- get_sample_frame()
      if(is.null(dat))
        return()
      write.csv(dat, con, row.names = FALSE)
    }
  )

  get_numeric <- function(name){
    dat <- get_raw_data()
    if(is.null(dat) || input[[name]] == "")
      return(NULL)
    as.numeric(dat[[input[[name]]]])
  }

  get_categorical <- function(name){
    dat <- get_raw_data()
    if(is.null(dat) || input[[name]] == "")
      return(NULL)
    as.factor(dat[[input[[name]]]])
  }

  get_logical <- function(name){
    dat <- get_raw_data()
    if(is.null(dat) || input[[name]] == "")
      return(NULL)
    variable <- dat[[input[[name]]]]
    if(is.logical(variable))
      return(variable)
    if(is.numeric(variable))
      return(variable == max(variable, na.rm=TRUE))
    variable <- as.factor(variable)
    variable == max(levels(variable))
  }

  render_raw_table <- function(name){
    renderTable({
      dat <- get_raw_data()
      if(is.null(dat))
        return(NULL)
      v <- dat[[input[[name]]]]
      table(v, useNA = "always", dnn=name)
    })
  }

  render_table <- function(name){
    renderTable({
      v <- eval(parse(text=paste0("get_", name)))()
      table(v, useNA = "always", dnn=name)
    })
  }


}

