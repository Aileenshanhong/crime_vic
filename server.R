
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
library(RCurl)

shinyServer(function(input, output) {
  x <- read.csv("http://data.gov.au/storage/f/2013-05-12T201353/tmpZrsaL6PSA-Rates.csv", stringsAsFactors = F)
  crime <- dcast(x, PSA_NAME ~ LABEL, value.var = "CURR")
  colnames(crime) <- tolower(colnames(crime))
  k1 <- clara(crime[,-1], k = 4)
  
  pcfile <- getURL("https://raw.githubusercontent.com/Aileenshanhong/crime_vic/master/pc_full_lat_long.csv")
  suburbs <- read.csv(text = pcfile, stringsAsFactors = F)
  rm(pcfile)
  
  suburbs <- filter(suburbs, State == "VIC") %>%
    select(Locality, Pcode, lat = Lat, lon = Long) %>%
    group_by(Locality) %>%
    summarise(postcode = min(Pcode), lat = median(lat), lon = median(lon))
  
  crime <- mutate(crime, cluster = k1$clustering, Locality = toupper(psa_name)) %>%
    left_join(suburbs, by = "Locality")
  
  colorset <- brewer.pal(4, "RdYlGn")
  od <- c(2, 4, 3, 1)
  colors <- data.frame(cluster = c(1:4), color = colorset[od])
  crime <- left_join(crime, colors, by = "cluster")
  crime$popup <- paste0("<p>Police Station: ", crime$psa_name,
                        "<br>Cluster: ", crime$cluster,
                        "<br>Total Crime: ", crime$"05_total crime", "</p>")
  crime$id <- crime$idx <- c(0: (nrow(crime)-1))
  crime <- crime[complete.cases(crime),]
  
  crimelist <- apply(crime, 1, as.list)
  crimelist1 <- lapply(crimelist, function(row1){
    psa_name = row1$"psa_name"
    id = as.integer(row1$id)
    idx = as.integer(row1$idx)
    total_crime = as.numeric(row1$"05_total crime")
    cluster = as.integer(row1$"cluster")
    suburb = row1$Locality
    postcode = row1$"Pcode"
    lat = as.numeric(row1$lat)
    lon = as.numeric(row1$lon)
    color = row1$color
    popup = row1$popup
    return(list(psa_name = psa_name, idx = idx, total_crime = total_crime, cluster = cluster,
                suburb = suburb, postcode = postcode, latitude = lat, longitude = lon, lat = NULL, lng = NULL, 
                id = id, fillColor = color, popup = popup))
  })
  
  crime1 <- group_by(crime[,c(2:5, 7:16)], cluster) %>%
    summarise_each(funs(median))
  
  crime2 <- melt(crime1, id.vars = "cluster", variable.name = "crime_type", value.name = "no_of_incidents")
  
  output$map_container <- renderMap({
    crime.map <- Leaflet$new()
    crime.map$setView(c(-36.758106, 144.283042), zoom = 7)
    crime.map$tileLayer(provider = 'Stamen.TonerLite')
    crime.map$geoJson(toGeoJSON(crimelist1),
                      onEachFeature = '#! function(feature, layer){
                                   layer.bindPopup(feature.properties.popup)
                                   } !#',
                      pointToLayer = "#! function(feature, latlng){
                                 return L.circleMarker(latlng, {
                                 radius: 5,
                                 fillColor: feature.properties.fillColor || 'red', 
                                 color: '#000',
                                 weight: 1,
                                 fillOpacity: 0.8
                                  })
                                 } !#" )
    
    #crime.map$set(width = 1600, height = 800)
    crime.map$enablePopover(TRUE)
    crime.map$fullScreen(TRUE)
    crime.map
  })
  
  
  output$chart1 <- renderChart2({
    plot1 <- rPlot(crime_type ~ no_of_incidents | cluster, data = crime2, type = "point", size = list(const = 2))
    plot1$facet(rows = 2)
    plot1$set(title = "Median Crime Incidents in VIC")
    return(plot1)
  })
  
  ps <- reactive({
    x <- unique(crime$psa_name)
    out <- as.list(x)
    names(out) <- x
    return(out)
  })
  
  output$psa <- renderUI({
    selectInput('ps1', 'Police Station', ps(), "Melbourne")
  })
  output$text1 <- renderText({paste("You have selected", input$ps1)})
  
  chosen2 <- reactive({
    chosen <- filter(crime, psa_name == input$ps1)
    
    out <- melt(chosen[,c(1:5, 7:15)], id.vars = "psa_name", variable.name = "crime_type", value.name = "no_of_incidents")
    return(out)
    })

   
  output$chart2 <- renderChart2({
    
    plot2 <- rPlot(crime_type ~ no_of_incidents, data = chosen2(), type = "point")
    plot2$set(title = paste("Crime Incidents by Type at Police Station", input$ps1))
    return(plot2)
  })

})
