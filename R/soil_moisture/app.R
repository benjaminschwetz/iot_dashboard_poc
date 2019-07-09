library(shiny)
library(tidyverse)
library(lubridate)
library(shinydashboard)
db_sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem(
            "Status", tabName = "status", icon = icon("bell")
        ),
        menuItem(
            "Time series", tabName = "timeseries", icon = icon("chart-line")
        )
    )
)
db_header <-  dashboardHeader(title = "Soil Moisture")
db_body <- dashboardBody(
    tabItems(
        tabItem("status",
                fluidRow(
                 uiOutput("status_boxes")   
                )),
        tabItem("timeseries",
                fluidRow(
                    box(
                        plotOutput("graph")
                    )
                ))
    )
)

ui <- dashboardPage(db_header, db_sidebar, db_body)
server <- function(input, output) {
    # fetching data ----
    get_raw <- function () {
        data <- read_csv(
            url("https://script.google.com/macros/s/AKfycbw4WXszMLC2SJ77qrxnUBGKnjb_SB-1mL0LAl0zt8WJfMShu2Q2/exec?sheet=raw")
        ) %>% 
            mutate(timestamp = mdy_hms(timestamp))
        data
    }
    df <- reactive({
        invalidateLater(180000)
        get_raw()
    })
    observeEvent(df,{
        # timeseries tab ----
        output$graph <- renderPlot(
            df() %>% 
                ggplot() +
                aes(x = timestamp,
                    y = value) +
                geom_line()+
                facet_wrap(~sensor,
                           ncol = 1,
                           scales = "free_y")
        )
        # status tab ----
        battery <- function(x, max = 1000){
            load <- c("empty", "quarter", "half", "three-quarters", "full")
            index <- 1 + (x*4)/max
            icon(paste0("battery-", load[index]))
        }
        latest <- df() %>% 
            group_by(sensor) %>% 
            filter(timestamp == max(timestamp)) %>% 
            select(sensor, value) %>% 
            deframe()
        output$status_boxes <- renderUI({
            tagList(
                valueBox(latest["basil"], "Basil", icon = battery(latest["basil"])),
                valueBox(latest["temp"], "Temperature", icon = icon("thermometer-quarter"))
                
            )
        })
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
