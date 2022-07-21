# libraries
library(shiny)
library(tidyverse)

shinyServer(function(input, output){ 
  
  ### read in & clean data ###
  # read in 
  pgaDat <- read_csv("../pgaTourData.csv")
  
})