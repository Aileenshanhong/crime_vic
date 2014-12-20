
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(reshape2)
library(cluster)
library(dplyr)
library(rCharts)
library(RColorBrewer)

shinyServer(function(input, output) {
  x <- read.csv("http://data.gov.au/storage/f/2013-05-12T201353/tmpZrsaL6PSA-Rates.csv", stringsAsFactors = F)
  crime <- dcast(x, PSA_NAME ~ LABEL, value.var = "CURR")
  colnames(crime) <- tolower(colnames(crime))
  k1 <- clara(crime[,-1], k = 4)
  
  
  
  
  output$distPlot <- renderPlot({

    # generate bins based on input$bins from ui.R
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    # draw the histogram with the specified number of bins
    hist(x, breaks = bins, col = 'darkgray', border = 'white')

  })

})
