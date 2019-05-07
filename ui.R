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

dashboardPage(
  skin = "green",
  dashboardHeader(title = "Yelp Dashboard"),
  
  dashboardSidebar(
    #Create the sidebar menu tabs
    sidebarMenu(
      menuItem("Yelp IT", tabName = "Aroundyou", icon = icon("map")),
      menuItem(
        "Top Business",
        tabName = "top",
        icon = icon("area-chart")
      ),
      menuItem("Word Clouds", tabName = "cloud", icon = icon("cloud")),
      menuItem(
        "Business Hotspots",
        tabName = "hotspot",
        icon = icon("book")
      ),
      menuItem("Write Up",
               tabName = "writeup",
               icon = icon("book"))
      
    )
  ),
  
  #Create the body
  dashboardBody(
    tags$style(
      HTML(
        "
        
        
        .box.box-solid.box-primary>.box-header {
        color:#fff;
        background:#666666
        }
        
        .box.box-solid.box-primary{
        border-bottom-color:#666666;
        border-left-color:#666666;
        border-right-color:#666666;
        border-top-color:#666666;
        }
        
        "
      )
      ),
    tabItems(
      # Top business ------------------------------------------------------------
      tabItem(tabName = "top",
              fluidRow(
                column(4,
                       selectInput('city', 'City:',
                                   cities1, "Phoenix")),
                column(8,
                       selectInput(
                         'howtop',
                         'How to rank:',
                         c("most five stars", "most reviews"),
                         "most five stars"
                       ))
                
              ),
              fluidRow(column(
                width = 12,
                box(
                  title = "Top 10 business",
                  width = 12,
                  solidHeader = TRUE,
                  status = "primary",
                  collapsible  = T,
                  plotlyOutput("top_bar")
                )
                
              ))),
      
      #Around You............................
      tabItem(tabName = "Aroundyou",
              
              fluidRow(column(
                width = 12,
                box(
                  title = "Explore with Yelp",
                  width = 12,
                  solidHeader = TRUE,
                  status = "primary",
                  collapsible  = T,
                  leafletOutput("around_you", height = 600)
                )
                
              ))),
      
      
      # Word Cloud --------------------------------------------------------------
      tabItem(
        tabName = "cloud",
        fluidRow(
          column(
            3,
            selectInput(
              'city2',
              label = 'City:',
              choices = cities2,
              selected = "Phoenix"
            )
          ),
          column(
            6,
            selectInput(
              'cloud_cate',
              label = 'Popularity',
              choices = c("Top rated", "Least Rated"),
              selected = "Top rated"
            )
          ),
          column(
            9,
            selectInput(
              'ngram',
              label = 'How many words as a token:',
              choices = c(1, 2, 3),
              selected = 1
              
            )
          )
          
        ),
        fluidRow(column(
          width = 12,
          box(
            title = "Word CLouds based on rating",
            width = 12,
            solidHeader = TRUE,
            status = "primary",
            collapsible  = T,
            plotOutput("cloud")
          )
          
        ))
        
      ),
      
      #reviews.....................................
      tabItem(tabName = "hotspot",
              
              fluidRow(column(
                3,
                selectInput(
                  'city3',
                  label = 'City:',
                  choices = cities3,
                  selected = "Phoenix"
                )
              )),
              fluidRow(column(
                width = 12,
                box(
                  title = "Business Hotspot",
                  width = 12,
                  solidHeader = TRUE,
                  status = "primary",
                  collapsible  = T,
                  leafletOutput("hotspot", height = 600)
                )
                
              ))),
      
      
      # Write up.........................................
      tabItem(tabName = "writeup",
              
              fluidRow(column(
                width = 12,
                box(
                  title = "Write Up",
                  width = 12,
                  solidHeader = TRUE,
                  status = "primary",
                  collapsible  = T,
                  h3("Why Bother with Shiny?"),
                  print("We all know about the power of R for solving analytic challenges. It is, without a doubt, one of the most powerful analytic tools available to us as data scientists, providing the ability to solve modelling challenges using a range of traditional and modern analytic approaches. Shiny could be as simple as displaying some graphics and tables, to a fully interactive dashboard. The important part is that it is all done with R; there are no requirements for web developers to get involved."),
                  h4(""),
                  h3("Implementation"),
                  print(
                    "Development phase:
                    The basic shiny app consists of Ui.R, Server.R and data preparation. 
                    Yelp dataset which is very huge in size needs data prep and data cleansing done by one of my teammate. 
                    We have four tabs in this shiny dashboard which were shared among other two of the team members
                    We spent something around 150 man hours for development and deployment.
                    "
                  ),
                  h4(""),
                  h3("Difficulties"),
                  print(
                    "1) Huge size of dataset and extracting data from json files."),
                  br(),
                  print("2) Difficulty in coding of server.r"),
                  br(),
                  print("3) Deploying on webserver")
                
                    
                  
                  
                  
                  
                )
                
              )))
      
    )
    
      )
  )
