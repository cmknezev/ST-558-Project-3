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
      sidebarPanel(
        checkboxInput("summPlayer", strong("Summarize for Specific Player?", 
                                           style = "color:blue")),
        conditionalPanel(condition = "input.summPlayer", 
                         textInput("numSummPlayer", "Player for Plot/Summaries", 
                                   value = "Rory McIlroy")),
        br(),
        selectInput("pltType", "Type of Graph", 
                    c("Scatterplot" = "scatterplot")), 
        conditionalPanel(condition = "input.pltType == 'scatterplot'", 
          selectInput("scattVar", "Variable for Scatterplot (along w/ Points)", 
                      c("Fairway %" = "fairwayPct", 
                        "Driver Distance" = "avgDistance", 
                        "Greens in Regulation %" = "gir", 
                        "Putts" = "avgPutts", 
                        "Scrambling" = "avgScrambling", 
                        "Score" = "avgScore", 
                        "Shots Gained: Off the Tee" = "sgOTT", 
                        "Shots Gained: Approach" = "sgAPR", 
                        "Shots Gained: Around the Green" = "sgARG"))),
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
        plotOutput("graph"), 
        verbatimTextOutput("numSumm")
      )
    )
  )
))

#shiny::runGitHub("ST-558-Project-3", "cmknezev", subdir = "PGA-Tour-Project")