# libraries
library(shiny)
library(tidyverse)
library(caret)

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
                    c("Scatterplot" = "scatterplot", 
                      "Line Chart" = "line", 
                      "Box Plot" = "box")), 
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
        conditionalPanel(condition = "input.pltType == 'line'", 
          selectInput("lineVar", "Variable for Line Chart", 
                      c("Fairway %" = "fairwayPct", 
                        "Driver Distance" = "avgDistance", 
                        "Greens in Regulation %" = "gir", 
                        "Putts" = "avgPutts", 
                        "Scrambling" = "avgScrambling", 
                        "Score" = "avgScore", 
                        "Shots Gained: Off the Tee" = "sgOTT", 
                        "Shots Gained: Approach" = "sgAPR", 
                        "Shots Gained: Around the Green" = "sgARG"))),
        conditionalPanel(condition = "input.pltType == 'box'", 
          selectInput("boxVar", "Variable for Box Plot", 
                      c("Points" = "points",
                        "Fairway %" = "fairwayPct", 
                        "Driver Distance" = "avgDistance", 
                        "Greens in Regulation %" = "gir", 
                        "Putts" = "avgPutts", 
                        "Scrambling" = "avgScrambling", 
                        "Score" = "avgScore", 
                        "Shots Gained: Off the Tee" = "sgOTT", 
                        "Shots Gained: Approach" = "sgAPR", 
                        "Shots Gained: Around the Green" = "sgARG"))),
        br(), 
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
  ), 
  
  # Modeling UI 
  tabPanel("Model Fitting", 
      titlePanel("Enter all Model Information -- Press 'Submit' to Create Models"), 
      sidebarLayout( 
        sidebarPanel(
          h3("Details for all models:"),
          numericInput("trainProp", "Proportion of Data used in Training Set", 
                       value = 0.8, min = 0.5, max = 0.9, step = 0.05), 
          br(), 
          h3("Details for MLR:"), 
          checkboxGroupInput("mlrVars", "Variables for use in MLR", 
                             c("Rounds" = "rounds", 
                               "Fairway %" = "fairwayPct", 
                               "Driver Distance" = "avgDistance", 
                               "Greens in Regulation %" = "gir", 
                               "Putts" = "avgPutts", 
                               "Scrambling" = "avgScrambling", 
                               "Score" = "avgScore", 
                               "Avg. Shots Gained: Putts" = "avgSgPutts", 
                               "Avg. Shots Gained: Total" = "avgSgTotal",
                               "Shots Gained: Off the Tee" = "sgOTT", 
                               "Shots Gained: Approach" = "sgAPR", 
                               "Shots Gained: Around the Green" = "sgARG")), 
          br(), 
          h3("Details for Regression Tree:"), 
          checkboxGroupInput("treeVars", "Variables for use in Regression Tree", 
                             c("Rounds" = "rounds", 
                               "Fairway %" = "fairwayPct", 
                               "Driver Distance" = "avgDistance", 
                               "Greens in Regulation %" = "gir", 
                               "Putts" = "avgPutts", 
                               "Scrambling" = "avgScrambling", 
                               "Score" = "avgScore", 
                               "Avg. Shots Gained: Putts" = "avgSgPutts", 
                               "Avg. Shots Gained: Total" = "avgSgTotal",
                               "Shots Gained: Off the Tee" = "sgOTT", 
                               "Shots Gained: Approach" = "sgAPR", 
                               "Shots Gained: Around the Green" = "sgARG")), 
          numericInput("treeCP", "CP for Tree Model (Between 0 and 0.1)", 
                       value = 0.05, min = 0, max = 0.1, step = 0.001),
          br(), 
          h3("Details for Random Forest Model:"),
          checkboxGroupInput("rfVars", "Variables for use in Random Forest Model", 
                             c("Rounds" = "rounds", 
                               "Fairway %" = "fairwayPct", 
                               "Driver Distance" = "avgDistance", 
                               "Greens in Regulation %" = "gir", 
                               "Putts" = "avgPutts", 
                               "Scrambling" = "avgScrambling", 
                               "Score" = "avgScore", 
                               "Avg. Shots Gained: Putts" = "avgSgPutts", 
                               "Avg. Shots Gained: Total" = "avgSgTotal",
                               "Shots Gained: Off the Tee" = "sgOTT", 
                               "Shots Gained: Approach" = "sgAPR", 
                               "Shots Gained: Around the Green" = "sgARG")), 
          numericInput("rfmtry", "Number of Variables to Use in Each Model (mtry)", 
                       value = 4, min = 1, max = 12, step = 1),
          br(), 
          actionButton("submit", "Submit")
        ), 
        mainPanel( 
          h3("Training RMSE for Each Model"), 
          dataTableOutput("rmse"), 
          br(), 
          h3("MLR Model Summary"), 
          verbatimTextOutput("mlrSumm"), 
          br(), 
          h3("Tree Model Summary"),
          verbatimTextOutput("treeSumm"), 
          br(), 
          h3("Variable Importance Plot - RF Model"), 
          plotOutput("rfPlot")
        )
      )
  ), 
  
  tabPanel("Prediction", 
    titlePanel("Select Model & Input Variable Values to Predict Points"), 
    sidebarLayout( 
      sidebarPanel( 
        radioButtons("predModel", "Model Used for Predictions", 
                     c("MLR Model" = "mlr", 
                       "Tree Model" = "tree", 
                       "Random Forest Model" = "rf")),  
        numericInput("rounds", "Rounds", value = 80, min = 0, step = 1), 
        numericInput("fairwayPct", "Fairway %", 
                     value = 0.6, min = 0, max = 1, step = 0.01), 
        numericInput("avgDistance", "Driver Distance", 
                     value = 290, min = 1, step = 1), 
        numericInput("gir", "Greens in Regulation %", 
                     value = 0.65, min = 0, max = 1, step = 0.01), 
        numericInput("avgPutts", "Putts", value = 30, min = 0), 
        numericInput("avgScrambling", "Scrambling", 
                     value = 0.6, min = 0, max = 1, step = 0.01), 
        numericInput("avgScore", "Score", value = 72, min = 1), 
        numericInput("avgSgPutts", "Avg. Shots Gained: Putts", 
                     value = 0, step = 0.01), 
        numericInput("avgSgTotal", "Avg. Shots Gained: Total", 
                     value = 0, step = 0.01), 
        numericInput("sgOTT", "Shots Gained: Off the Tee", 
                     value = 0, step = 0.01), 
        numericInput("sgAPR", "Shots Gained: Approach", 
                     value = 0, step = 0.01), 
        numericInput("sgARG", "Shots Gained: Around the Green", 
                     value = 0, step = 0.01),
        actionButton("submitPreds", "Submit")
      ), 
      mainPanel( 
        h3("Predicted Points:"), 
        verbatimTextOutput("prediction")
      )
    )
  ), 
  
  tabPanel("Data", 
    titlePanel("Full Data Set"), 
    sidebarLayout(
      sidebarPanel( 
        checkboxGroupInput("dataVars", "Variables to Display:", 
                           choices = 
                             c("Name" = "name",
                               "Rounds" = "rounds", 
                               "Fairway %" = "fairwayPct", 
                               "Year" = "year",
                               "Driver Distance" = "avgDistance", 
                               "Greens in Regulation %" = "gir", 
                               "Putts" = "avgPutts", 
                               "Scrambling" = "avgScrambling", 
                               "Score" = "avgScore", 
                               "Points" = "points",
                               "Avg. Shots Gained: Putts" = "avgSgPutts", 
                               "Avg. Shots Gained: Total" = "avgSgTotal",
                               "Shots Gained: Off the Tee" = "sgOTT", 
                               "Shots Gained: Approach" = "sgAPR", 
                               "Shots Gained: Around the Green" = "sgARG"), 
                           selected = c("name", "rounds", "fairwayPct", 
                                        "year", "avgDistance", "gir", 
                                        "avgPutts", "avgScrambling", "avgScore", 
                                        "points", "avgSgPutts", "avgSgTotal", 
                                        "sgOTT", "sgAPR", "sgARG")), 
        actionButton("save", "Save Data")
      ),
      mainPanel(
        dataTableOutput("dt")
      )
    )
  )
  
))

#shiny::runGitHub("ST-558-Project-3", "cmknezev", subdir = "PGA-Tour-Project")