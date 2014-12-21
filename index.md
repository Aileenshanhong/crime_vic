---
title       : Crime Incidents in Victoria, Australia
subtitle    : 
author      : A.L.
job         : 
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
---

## Overview

1. Summary
2. Download Data
3. Clustering
4. Crime Map by Police Station

--- .class #id 
---

## Summary

This web application shows crime incidents recorded in different police stations in Victoria, Australia. The four colours indicate four clusters based on the number of crime incidents. The greener the point in the map, the safer it is in that area. The red colour shows that it is a 'no-go' zone.


---              

## Download Data

```r
 library(RCurl)
  x <- read.csv("http://data.gov.au/storage/f/2013-05-12T201353/tmpZrsaL6PSA-Rates.csv", stringsAsFactors = F)
  
  pcfile <- getURL("https://raw.githubusercontent.com/Aileenshanhong/crime_vic/master/pc_full_lat_long.csv")
  suburbs <- read.csv(text = pcfile, stringsAsFactors = F)
```
---

## Clustering
Clustering is conducted based on the number of different types of crime incidents, such as serious injuries, assault etc.

```r
  crime <- dcast(x, PSA_NAME ~ LABEL, value.var = "CURR")
  colnames(crime) <- tolower(colnames(crime))
  k1 <- clara(crime[,-1], k = 4)
```

---

## Crime Map by Police Station

```r
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
    crime.map$enablePopover(TRUE)
    crime.map$fullScreen(TRUE)
```



