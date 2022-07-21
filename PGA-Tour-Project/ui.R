# libraries
library(shiny)
library(tidyverse)

shinyUI(navbarPage("PGA Tour App", 
       
  # About Page UI                             
  tabPanel("About Page", 
    titlePanel("About this Project"), 
    sidebarLayout(
      sidebarPanel(
        h4("Description")
      ),
      mainPanel("picture")
    ), 
  ),
  
  # Data Exploration UI
  tabPanel("Data Exploration Page", 
    titlePanel("Exploratory Data Analysis"), 
    sidebarLayout(
      textInput("numSummPlayer", "Player for Numeric Summaries", 
                value = "Rory McIlroy"), 
      selectInput("numSummVar", "Variable for Numeric Summaries", 
                  c("Points" = "points", 
                    "Fairway %" = "fairwayPct", 
                    "Driver Distance" = "avgDistance", 
                    "Greens in Regulation %" = "gir", 
                    "Putts" = "avgPutts", 
                    "Scrambling" = "avgScrambling", 
                    "Score" = "avgScore", 
                    "Shots Gained: Off the Tee" = "sgOTT", 
                    "Shots Gained: Approach" = "sgAPR", 
                    "Shots Gained: Around the Green" = "sgARG"))
    ), 
    mainPanel(
      verbatimTextOutput("numSumm")
    )
  )
))

#shiny::runGitHub("ST-558-Project-3", "cmknezev", subdir = "PGA-Tour-Project")