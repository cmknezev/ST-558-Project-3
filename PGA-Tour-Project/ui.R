# libraries
library(shiny)
library(tidyverse)
library(caret)
library(shinyWidgets)

shinyUI(navbarPage("PGA Tour App", 
       
  # About Page UI                             
  tabPanel("About Page", 
    titlePanel("About this Project"), 
    sidebarLayout(
      sidebarPanel(
        #uiOutput("img")
        #img(src = "fedexcup.jpg")
      ),
      mainPanel(
        span("In this app, we will be exploring and analyzing data from the PGA 
             Tour. Specifically, this dataset contains data with metrics for 
             how well each player performed in each season from 2010 to 2018, as 
             well as how many points they earned in the FedEx Cup. Players earn 
             points in the FedEx Cup based on their performance in tournaments 
             over the course of a season. The metrics that detail player 
             performance include ways to measure performance in different 
             aspects of a player's game (driving, putting, etc.), and a player's 
             overall scoring. This app will allow users to explore a number of 
             visualizations for this data, and users can create these 
             visualizations for a specific player. Users can also train models 
             in order to predict the number of FedEx Cup points a player will 
             earn based on a number of selected variables."), 
        br(), 
        span("The data was sourced from ", a("Kaggle", 
              href = "https://www.kaggle.com/datasets/jmpark746/pga-tour-data-2010-2018"), 
             ", and this data was scraped from ", a("The PGA Tour Website.", 
              href = "https://www.pgatour.com/stats.html")), 
        br(), 
        span("There are a number of different tabs in this app. First, the Data 
             Exploration tab will show visualizations and summaries of the data. 
             The Modeling Info tab will provide some information on the 
             different types of models that this app will fit, and the Model 
             Fitting tab will allow users to fit these models. The Prediction 
             tab allows users to use the models created to predict the number 
             of points based on the values the user inputs. Finally, the Data 
             tab allows users to view the full dataset and to save the data."),
        br(), 
        uiOutput("img")
      )
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
  
  # Model Info UI 
  tabPanel("Modeling Info", 
    titlePanel("Modeling Info"), 
    sidebarLayout( 
      sidebarPanel( 
        
      ),
      mainPanel(
        h3("Multiple Linear Regression:"),
        span("The goal of linear regression is to create an equation that models 
             the relationship between a response variable and a set of 
             explanatory variables. This is done by creating an equation with 
             a common intercept and slopes corresponding to each explanatory 
             variable. For example, a linear regression model with two 
             explanatory variables may look like this:"), 
        uiOutput("mathJax1"), 
        span("You can also account for polynomial terms, interaction terms 
             between two variables, and categorical variables with this method. 
             The advantages of using linear regression are that it is generally 
             easy to fit the model, and the model is easy to interpret. A 
             disadvantage is that these models generally do not perform as well 
             as some ensemble methods in predicting."), 
        br(), 
        h3("Tree Model:"), 
        span("A tree model will create numerous different 'branches' based on 
             the values of different explanatory variables. Then, at the end of 
             each branch, the model will assign a prediction for the response 
             variable to these observations. In our case we have a continuous 
             response variable - the tree model will typically use the mean of 
             all observations in the branch as the prediction. Tree models are 
             fit using a greedy algorithm, and are generally 'pruned back' in 
             order to not overfit to the data. Some advantages of using tree 
             models are that they are very easy to understand, and fitting the 
             model does not require any statistical assumptions. A disadvantage 
             is that these models are prone to changes in the data."), 
        br(), 
        h3("Random Forest Model:"), 
        span("Random forest models utilize bootstrap aggregation, in which we 
             re-sample from the data (with replacement) many times, create tree 
             models based on these samples, create predictions using these 
             models, and finally average these predictions as our final result. 
             Additionally, random forest models will choose a random selection 
             of explanatory variables for each tree model it fits. An advantage 
             to using random forest models is that these models are very good 
             for prediction. A disadvantage is that these models are more 
             difficult to interpret.")
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
          actionButton("submit", "Submit"), 
          progressBar("progBar", value = 0, total = 100)
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
          h3("Variable Importance - RF Model"), 
          verbatimTextOutput("rfImp"), 
          br(),
          h3("Test RMSE for Each Model"), 
          dataTableOutput("testrmse")
        )
      )
  ), 
  
  # Prediction UI 
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
  
  # Data UI
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