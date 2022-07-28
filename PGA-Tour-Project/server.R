# libraries
library(shiny)
library(tidyverse)
library(caret)
library(Metrics)
library(randomForest)
library(DT)
library(shinyWidgets)

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
    # boxplot 
    else if(input$pltType == "box"){ 
      if(input$summPlayer){ 
        subDat <- pgaDat %>% filter(name == input$numSummPlayer) 
        var1 <- input$boxVar 
        ggplot(data = subDat, aes_string(x = var1)) + 
          geom_boxplot(color = "darkgreen", outlier.color = "red") + 
          labs(title = paste0(input$numSummPlayer, "'s ", var1))
      }
      else { 
        var1 <- input$boxVar 
        ggplot(data = pgaDat, aes_string(x = var1)) + 
          geom_boxplot(color = "darkgreen", outlier.color = "red") + 
          labs(title = paste0("Boxplot of ", var1))
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
  
  ### modeling ### 
  # observeEvent
  models <- eventReactive(input$submit, { 
    # set seed for reproducibility 
    set.seed(35) 
    # remove na's from dataset to avoid errors in model fitting/prediction
    modelData <- pgaDat %>% drop_na()
    # training/test split 
    train <- sample(1:nrow(modelData), size = nrow(modelData)*input$trainProp) 
    test <- setdiff(1:nrow(modelData), train) 
    pgaTrain <- modelData[train,] 
    pgaTest <- modelData[test,]
    updateProgressBar(session = session, id = "progBar", value = 1, total = 100)
    
    # MLR # 
    mlrDat <- pgaTrain[, c("points", input$mlrVars)] 
    mlrModel <- train(points ~ ., data = mlrDat, method = "lm", 
                      trControl = trainControl(method = "cv", number = 5))
    updateProgressBar(session = session, id = "progBar", value = 25, total = 100)
    
    # Regression Tree # 
    treeDat <- pgaTrain[, c("points", input$treeVars)] 
    treeModel <- train(points ~., data = treeDat, method = "rpart", 
                       trControl = trainControl(method = "cv", number = 5), 
                       tuneGrid = data.frame(cp = input$treeCP))
    updateProgressBar(session = session, id = "progBar", value = 50, total = 100)
    
    # Random Forest # 
    rfDat <- pgaTrain[, c("points", input$rfVars)] 
    if(input$rfmtry > (ncol(rfDat) - 1)){ 
      rfmtry2 <- ncol(rfDat) - 1 
    } 
    else { 
      rfmtry2 <- input$rfmtry 
    } 
    rfModel <- train(points ~ ., data = rfDat, method = "rf", 
                     trControl = trainControl(method = "cv", number = 5), 
                     tuneGrid = data.frame(mtry = rfmtry2)) 
    updateProgressBar(session = session, id = "progBar", value = 75, total = 100)
    
    # model summaries 
    # create predictions for finding training rmse 
    #predict(mlrModel, newdata = pgaTrain)
    # training rmse for all models 
    mlrRMSE <- rmse(predict(mlrModel, newdata = pgaTrain), pgaTrain$points) 
    treeRMSE <- rmse(predict(treeModel, newdata = pgaTrain), pgaTrain$points)
    rfRMSE <- rmse(predict(rfModel, newdata = pgaTrain), pgaTrain$points)
    # creating output 
    output$rmse <- renderDataTable({ 
      data.frame(MLR = mlrRMSE, Tree = treeRMSE, RF = rfRMSE)
    })
    # mlr model summary 
    output$mlrSumm <- renderPrint({ 
      summary(mlrModel)
    })
    # tree model summary 
    output$treeSumm <- renderPrint({ 
      treeModel
    })
    # variable importance - rf model 
    output$rfImp <- renderPrint({ 
      varImp(rfModel, scale = FALSE)
    }) 
    # test rmse for all models 
    mlrTestRMSE <- rmse(predict(mlrModel, newdata = pgaTest), pgaTest$points)
    treeTestRMSE <- rmse(predict(treeModel, newdata = pgaTest), pgaTest$points)
    rfTestRMSE <- rmse(predict(rfModel, newdata = pgaTest), pgaTest$points)
    # creating output 
    output$testrmse <- renderDataTable({ 
      data.frame(MLR = mlrTestRMSE, Tree = treeTestRMSE, RF = rfTestRMSE) 
    })
    updateProgressBar(session = session, id = "progBar", value = 100, total = 100)
    
    # save models as list 
    list(mlrModel, treeModel, rfModel)
  }) 
  
  observe(models())
  
  ### predictions ### 
  
  observeEvent(input$submitPreds, { 
    # create data frame with user-inputted values
    predData <- data.frame(rounds = input$rounds, 
                           fairwayPct = input$fairwayPct, 
                           avgDistance = input$avgDistance, 
                           gir = input$gir, 
                           avgPutts = input$avgPutts, 
                           avgScrambling = input$avgScrambling, 
                           avgScore = input$avgScore, 
                           avgSgPutts = input$avgSgPutts, 
                           avgSgTotal = input$avgSgTotal, 
                           sgOTT = input$sgOTT, 
                           sgAPR = input$sgAPR, 
                           sgARG = input$sgARG)
    
    # create predictions 
    if(input$predModel == "mlr"){ 
      model <- models()[[1]]
      preds <- predict(model, newdata = predData)
    }
    else if(input$predModel == "tree"){ 
      model <- models()[[2]]
      preds <- predict(model, newdata = predData)
    }
    else { 
      model <- models()[[3]]
      preds <- predict(model, newdata = predData)
    }
    
    output$prediction <- renderPrint({ 
      preds 
    }) 
  })
  
  ### data page ### 
  
  dataPage <- reactive({ 
    pgaDat[, c(input$dataVars)] 
  })

  observe({
    output$dt <- DT::renderDataTable({ 
      dataPage()
    })
  })
  
  # save data as .csv 
  observeEvent(input$save, { 
    dataToSave <- dataPage()
    write_csv(dataToSave, "SavedPgaTourData.csv")
  })
  
})