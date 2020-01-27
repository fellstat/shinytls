library(shiny)
library(promises)
library(future)
library(ipc)
plan(multiprocess)
library(ggplot2)
library(survey)
options(shiny.maxRequestSize=300*1024^2)

shinyServer(function(input, output, session) {

    get_raw_data <- reactive({
        inFile <- input$file1

        if (is.null(inFile))
            return(NULL)

        dat <- read.csv(inFile$datapath, header = TRUE, stringsAsFactors = FALSE)
        vars <- names(dat)

        for(name in c("locations", "location_type","days_open","times_open"))
            updateSelectizeInput(session, name, choices = c("Choose Variable"="",vars))
        dat
    })

    get_sample_frame <- reactive({
        if(is.null(get_raw_data()))
            return(NULL)
        df <- get_raw_data()
        if(input$locations == ""){
            showNotification("Please select a variable for the study locations")
            return(NULL)
        }
        if(input$days_open == ""){
            showNotification("Please select a variable for the days of the week that the venue is open")
            return(NULL)
        }
        if(input$times_open == ""){
            showNotification("Please select a variable for the times of the day that the venue is open")
            return(NULL)
        }
        days <- df[[input$days_open]]
        days <- lapply(strsplit(days," "), tolower)
        alldays <- unique(unlist(days))
        if(!all(alldays %in% c("monday" ,  "tuesday",  "wednsday" ,"thursday" ,"friday",   "saturday" ,"sunday" ))){
            showNotification("Invalid day of the week. Days of the week must be in english and delimited by a single space.")
            return(NULL)
        }
        times <- df[[input$times_open]]
        times <- strsplit(times," ")

        venue <- df[[input$locations]]

        ll <- list()
        for(i in 1:length(venue)){
            d <- expand.grid(venue=venue[i], times=times[[i]], days=days[[i]])
            if(!is.null(input$location_type)){
                d$location_type <- df[i,input$location_type]
            }
            ll[[i]] <- d
        }
        dat <- do.call(rbind, ll)
        dat$subject_count <- ""
        dat
    })

    output$table <- renderTable({
        if(is.null(get_raw_data()))
            return(NULL)
        get_raw_data()
    })

    output$sampletable <- renderTable({
        if(is.null(get_sample_frame()))
            return(NULL)
        get_sample_frame()
    })

    output$download <- downloadHandler(
        filename = function() {
            paste('data-', Sys.Date(), '.csv', sep='')
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


})
