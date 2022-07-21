# libraries
library(shiny)

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
  )
  
  # Data Exploration UI
))

#shiny::runGitHub("ST-558-Project-3", "cmknezev", subdir = "PGA-Tour-Project")