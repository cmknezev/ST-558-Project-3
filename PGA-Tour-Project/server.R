# libraries
library(shiny)
library(tidyverse)

shinyServer(function(input, output, session){ 
  
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
  
  # graph 
  output$graph <- renderPlot({ 
    # scatterplot
    if(input$pltType == "scatterplot"){ 
      if(input$summPlayer){ 
        subDat <- pgaDat %>% filter(name == input$numSummPlayer) 
        var1 <- input$scattVar 
        subDat <- subDat[, c("points", var1)] 
        subDat <- subDat %>% drop_na()
        ggplot(data = subDat, aes_string(x = var1, y = "points")) + 
          geom_point() + 
          geom_smooth(method = lm, color = "blue") + 
          labs(title = paste0("Scatterplot: ", var1, " vs. Points"), 
               y = "Season Points Earned")
      }
      else { 
        var1 <- input$scattVar
        subDat <- pgaDat[, c("points", var1)] 
        subDat <- subDat %>% drop_na() 
        ggplot(data = subDat, aes_string(x = var1, y = "points")) + 
          geom_point() + 
          geom_smooth(method = lm, color = "blue") + 
          labs(title = paste0("Scatterplot: ", var1, " vs. Points"), 
               y = "Season Points Earned") 
      }
    }
    # line chart 
    else if(input$pltType == "line"){ 
      if(input$summPlayer){ 
        subDat <- pgaDat %>% filter(name == input$numSummPlayer) 
        var1 <- input$lineVar 
        subDat <- subDat[, c("year", var1)] 
        subDat <- subDat %>% group_by(year) %>% drop_na() 
        colnames(subDat)[2] <- "lineVar" 
        subDat <- subDat %>% summarise(avg = mean(lineVar)) 
        ggplot(data = subDat, aes(x = year, y = avg)) + 
          geom_line(linetype = "dashed", color = "blue") + 
          geom_point(color = "blue") + 
          labs(title = paste0(input$numSummPlayer, "'s ", var1, " by Year"), 
               x = "Year", y = paste0(var1))
      }
      else { 
        var1 <- input$lineVar
        subDat <- pgaDat[, c("year", var1)]
        subDat <- subDat %>% group_by(year) %>% drop_na() 
        colnames(subDat)[2] <- "lineVar" 
        subDat <- subDat %>% summarise(avg = mean(lineVar))
        ggplot(data = subDat, aes(x = year, y = avg)) + 
          geom_line(linetype = "dashed", color = "darkgreen") + 
          geom_point(color = "darkgreen") + 
          labs(title = paste0("Average ", var1, " by Year"), 
               x = "Year", y = paste0(var1))
      }
    }
  })
  
  # numeric summary
  output$numSumm <- renderPrint({ 
    if(input$summPlayer){ 
      subDat <- pgaDat %>% filter(name == input$numSummPlayer) 
      var <- input$numSummVar 
      summary(subDat[var]) 
    } 
    else { 
      var <- input$numSummVar 
      summary(pgaDat[var])
    }
  })
  
})