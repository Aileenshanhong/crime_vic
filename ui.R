
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#


library(shiny)
require(rCharts)
shinyUI(navbarPage("VIC Crime Incidents", 
  tabPanel("Interactive Map",
           div(class = "outer",
               tags$head(includeCSS("styles.css")),
           chartOutput("map_container", 'leaflet')        
           )),
           
    tabPanel("Graph",
             
             sidebarPanel(
                helpText("This web application shows crime incidents recorded in different police stations in Victoria, Australia. The four colours indicate four clusters based on the number of crime incidents. The greener the point in the map, the safer it is in that area. The red colour shows that it is a 'no-go' zone."),
                uiOutput("psa")
               ),
             mainPanel(
               
                showOutput("chart1", "polycharts"),
                showOutput("chart2", "polycharts")
               )
             
              )
    
))