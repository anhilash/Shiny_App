library(shiny)
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
library(maps,quietly=TRUE)


fillColor = "#03ad4f"
fillColor2 = "#03ad4f"

server <- function(input, output) {

  # Top business ------------------------------------------------------------
  output$top_bar <- renderPlotly({
    
    if (input$howtop=="most five stars")
    {
      city_top <- data %>% filter(business_city == input$city) %>% 
        filter(business_stars == 5) %>%
        group_by(business_id) %>%
        summarise(FiveStarCount = n()) %>%
        arrange(desc(FiveStarCount)) %>%
        ungroup() %>%
        head(10)
      
      most5StarsReviews = inner_join(city_top,data)
      
      most5StarsReviews %>%
        mutate(business_name = reorder(business_name,FiveStarCount)) %>%
        ggplot(aes(x = business_name)) +
        geom_bar(stat='count', fill = fillColor) +
        geom_text(aes(x = business_name, y = 1, label = paste0("(",FiveStarCount,")",sep="")),
                  hjust=0, vjust=.5, size = 4, colour = 'black',
                  fontface = 'bold') +
        labs(x = 'Name of the Business', 
             y = 'Count', 
             title = 'Top 10 business with most five star reviews') +
        coord_flip() +
        theme_bw()
    }
    
    else
    {
      city_top <- data %>% filter(business_city == input$city) %>% 
        group_by(business_id) %>%
        summarise(N = n()) %>%
        arrange(desc(N)) %>%
        ungroup() %>%
        head(10)
      
      MostReviews = inner_join(city_top,data)
      
      MostReviews %>%
        mutate(business_name = reorder(business_name,N)) %>%
        ggplot(aes(x = business_name)) +
        geom_bar(stat='count', fill = fillColor2) +
        geom_text(aes(x = business_name, y = 1, label = paste0("(",N,")",sep="")),
                  hjust=0, vjust=.5, size = 4, colour = 'black',
                  fontface = 'bold') +
        labs(x = 'Name of the Business', 
             y = 'Average Stars', 
             title = 'Top 10 business with most reviews') +
        coord_flip() +
        theme_bw()
      
    }
    
  })
  
#Around you..........
  output$around_you <- renderLeaflet({
    
    mymap<-leaflet() %>% 
      addTiles() %>% 
      addTiles(urlTemplate = "http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png")  %>%  
      mapOptions(zoomToLimits="always") %>%  
      addAwesomeMarkers(lat = bizrates$biz_rest.latitude, lng = bizrates$biz_rest.longitude,
                        clusterOptions = markerClusterOptions(),popup = paste("Name:",bizrates$biz_rest.name,"<br>",
                                                                              "Rating:",bizrates$biz_rest.stars,"<br>",
                                                                              "Address:",bizrates$biz_rest.address,"<br>"))
    mymap
    
  })
  
  
  #Business Hotspot................
  
  output$hotspot <- renderLeaflet({
    
    LasvegasCoords = biz_dat %>% filter(city == input$city3)
    
    center_lon = median(LasvegasCoords$longitude,na.rm = TRUE)
    center_lat = median(LasvegasCoords$latitude,na.rm = TRUE)
    
    leaflet(LasvegasCoords) %>% addProviderTiles("Esri.NatGeoWorldMap") %>%
      addCircles(lng = ~longitude, lat = ~latitude,radius = ~sqrt(review_count))  %>%
      
      # controls
      setView(lng=center_lon, lat=center_lat,zoom = 13)
    
  })



  # Word Cloud --------------------------------------------------------------

  
  output$cloud <- renderPlot({
    if(input$cloud_cate=="Top rated")
    {
      if(input$ngram==1)
      {
        tmp <- data %>% 
          select(stars,text,business_city,business_id) %>% 
          filter(stars==5, business_city == input$city2) %>% 
          group_by(business_id) %>% 
          summarise(Cnt=n()) %>% 
          arrange(desc(Cnt)) %>% 
          head(10) 
        sub <- inner_join(tmp,data,by="business_id")
        
        sub %>% 
          select(text) %>% 
          unnest_tokens(word, text) %>% 
          anti_join(stop_words) %>% 
          filter(! word %in% c(1:30)) %>% 
          count(word, sort = TRUE) %>% 
          head(60) %>% 
          with(wordcloud(word, n,scale = c(4,0.5),
                         max.words=300,random.order = F,
                         colors=brewer.pal(8, "Dark2")))
        
      }
      
      else if (input$ngram==2)
      {
        tmp <- data %>% 
          select(stars,text,business_city,business_id) %>% 
          filter(stars==5, business_city == input$city2) %>% 
          group_by(business_id) %>% 
          summarise(Cnt=n()) %>% 
          arrange(desc(Cnt)) %>% 
          head(10) 
        sub <- inner_join(tmp,data,by="business_id")
          
        sub %>% 
          select(text) %>% 
          unnest_tokens(bigram, text, token = "ngrams", n = 2) %>% 
          count(bigram, sort = TRUE) %>% 
          separate(bigram, c("word1", "word2"), sep = " ") %>% 
          filter(!word1 %in% stop_words$word) %>% 
          filter(!word2 %in% stop_words$word) %>% 
          unite(bigram, word1, word2, sep = " ") %>% 
          head(60) %>% 
          with(wordcloud(bigram, n,scale = c(3,0.5),
                         max.words=300,random.order = F,
                         colors=brewer.pal(8, "Dark2")))
        
      }
      
      else
      {
        tmp <- data %>% 
          select(stars,text,business_city,business_id) %>% 
          filter(stars==5, business_city == input$city2) %>% 
          group_by(business_id) %>% 
          summarise(Cnt=n()) %>% 
          arrange(desc(Cnt)) %>% 
          head(10) 
        sub <- inner_join(tmp,data,by="business_id")
        
        sub %>% 
          select(text) %>% 
          unnest_tokens(trigram, text, token = "ngrams", n = 3) %>% 
          count(trigram, sort = TRUE) %>% 
          separate(trigram, c("word1", "word2", "word3"), sep = " ") %>% 
          filter(!word1 %in% stop_words$word) %>% #remove cases where either is a stop-word.
          filter(!word1 == "http") %>%
          filter(!word2 %in% stop_words$word) %>%
          filter(!word3 %in% stop_words$word) %>%
          unite(trigram, word1, word2, word3, sep = " ") %>% 
          head(60) %>% 
          with(wordcloud(trigram, n,scale = c(3,0.5),
                         max.words=300,random.order = F,
                         colors=brewer.pal(8, "Dark2")))
        
      }
    }
    
    
    else
    {
      if(input$ngram==1)
      {
        tmp <- data %>% 
          select(stars,text,business_city,business_id) %>% 
          filter(stars<=2, business_city == input$city2) %>% 
          group_by(business_id) %>% 
          summarise(Cnt=n()) %>% 
          arrange(desc(Cnt)) %>% 
          head(10) 
        sub <- inner_join(tmp,data,by="business_id")
        sub %>% unnest_tokens(word, text) %>% 
          anti_join(stop_words) %>% 
          filter(! word %in% c(1:30)) %>% 
          count(word, sort = TRUE) %>% 
          head(60) %>% 
          with(wordcloud(word, n,scale = c(4,0.5),
                         max.words=300,random.order = F,
                         colors=brewer.pal(8, "Dark2")))
        
      }
      
      else if (input$ngram==2)
      {
        tmp <- data %>% 
          select(stars,text,business_city,business_id) %>% 
          filter(stars<=2, business_city == input$city2) %>% 
          group_by(business_id) %>% 
          summarise(Cnt=n()) %>% 
          arrange(desc(Cnt)) %>% 
          head(10) 
        sub <- inner_join(tmp,data,by="business_id")
        sub %>% unnest_tokens(bigram, text, token = "ngrams", n = 2) %>% 
          count(bigram, sort = TRUE) %>% 
          separate(bigram, c("word1", "word2"), sep = " ") %>% 
          filter(!word1 %in% stop_words$word) %>% 
          filter(!word2 %in% stop_words$word) %>% 
          unite(bigram, word1, word2, sep = " ") %>% 
          head(60) %>% 
          with(wordcloud(bigram, n,scale = c(3,0.5),
                         max.words=300,random.order = F,
                         colors=brewer.pal(8, "Dark2")))
        
      }
      
      else
      {
        tmp <- data %>% 
          select(stars,text,business_city,business_id) %>% 
          filter(stars<=2, business_city == input$city2) %>% 
          group_by(business_id) %>% 
          summarise(Cnt=n()) %>% 
          arrange(desc(Cnt)) %>% 
          head(10) 
        sub <- inner_join(tmp,data,by="business_id")
        sub %>%unnest_tokens(trigram, text, token = "ngrams", n = 3) %>% 
          count(trigram, sort = TRUE) %>% 
          separate(trigram, c("word1", "word2", "word3"), sep = " ") %>% 
          filter(!word1 %in% stop_words$word) %>% #remove cases where either is a stop-word.
          filter(!word1 == "http") %>%
          filter(!word2 %in% stop_words$word) %>%
          filter(!word3 %in% stop_words$word) %>%
          unite(trigram, word1, word2, word3, sep = " ") %>% 
          head(60) %>% 
          with(wordcloud(trigram, n,scale = c(3,0.5),
                         max.words=300,random.order = F,
                         colors=brewer.pal(8, "Dark2")))
        
      }
    }
    
  })
}
