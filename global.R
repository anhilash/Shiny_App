library(shiny)
library(shinydashboard)
library(wordcloud)
library(leaflet)
library(tidyverse)
library(magrittr)
library(tm)
library(tidytext)
library(textrank)
library(kableExtra)
library(plotly)
library(gridExtra)

fillColor = "#e9e2d0"
fillColor2 = "#f0ece2"
fillColor3 = "#add2c9"

data <- readRDS("./data.rds")
biz_dat <- readRDS("./business1.rds")

restaurants<-grep(pattern="Restaurants",biz_dat$categories)
bars<-biz_rest<-biz_dat[restaurants,]

bizrates<-data.frame(biz_rest$business_id, biz_rest$stars,
                     biz_rest$longitude,biz_rest$latitude, 
                     biz_rest$state,biz_rest$name,biz_rest$address,
                     biz_rest$attributes$RestaurantsTakeOut,biz_rest$attributes$RestaurantsReservations,
                     biz_rest$attributes$WiFi,biz_rest$attributes$Caters)


cc<-complete.cases(bizrates)
bizrates<-bizrates[cc,]
write.table(bizrates,"bizrates.dat")
bizrates<-read.table("bizrates.dat")



# Top business ------------------------------------------------------------
city_w_five <- data %>%  filter(business_stars == 5)
cities1 <- levels(factor(city_w_five$business_city))


# Word Cloud --------------------------------------------------------------
cities2 <- levels(factor(data$business_city))[-37]

#Hotspot.................
cities3 <- levels(factor(biz_dat$city))







