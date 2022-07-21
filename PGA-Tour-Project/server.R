# libraries
library(shiny)
library(tidyverse)

shinyServer(function(input, output){ 
  
  ### read in & clean data ###
  
  # read in 
  pgaDat <- read_csv("../pgaTourData.csv")
  # removing extraneous variables 
  pgaDat <- pgaDat[, -c(11, 12, 18)]
  # renaming columns to more friendly names 
  colnames(pgaDat) <- c("name", "rounds", "fairwayPct", "year", "avgDistance", 
                        "gir", "avgPutts", "avgScrambling", "avgScore", 
                        "points", "avgSgPutts", "avgSgTotal", "sgOTT", 
                        "sgAPR", "sgARG")
  # changing Percentage-type variables to decimal format 
  pgaDat["fairwayPct"] <- pgaDat["fairwayPct"]/100
  pgaDat["gir"] <- pgaDat["gir"]/100 
  pgaDat["avgScrambling"] <- pgaDat["avgScrambling"]/100
  # remove NA's from points variable 
  pgaDat$points <- ifelse(is.na(pgaDat$points), 0, pgaDat$points)
  
  ### data exploration ### 
  
  # numeric summary
  output$numSumm <- renderPrint({ 
    subDat <- pgaDat %>% filter(name == input$numSummPlayer)
    var <- input$numSummVar 
    summary(subDat[var])
  })
  
})