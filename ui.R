library(shiny); library(ggplot2); library(plotly); library(dplyr)
navbarPage("Menu",
        tabPanel("Summary",
                mainPanel(
                h2(HTML("<b>Summary of Video Game Sale Data</b>")),
                h4("This application summarizes data on lifetime video game sales for
                games selling more than 100,000 copies. The data originates on the 
                VGChartz web site. The dataset
                used here comes from Kaggle, where crtiic and user review data have
                been added. Use the links below to access these resources directly."),
                a(href="http://www.vgchartz.com/","VGChartz Web Site"),
                br(),
                a(href="https://www.kaggle.com/rush4ratio/video-game-sales-with-ratings",
                  "Kaggle Dataset"),
                br(),
                h4("Analysis of the data revals that the top ten selling video games of 
                all time are all published by Nintendo, and many are for the Wii system. 
                The highest-selling game is Wii Sports, which debuted in 2006. 
                It has sold about 82 million copies worldwide as of the end of 2016. 
                Other top selling games include Pokemon Red/Pokemon Blue and Tetris, 
                which were released for the Gameboy system in the 1990's and 1980's, 
                respectively."),
                br(),
                plotOutput("summaryplot")
                )
        ),
        tabPanel("Raw Data",
                mainPanel(
                h4("Use the data table below to explore some of the video game data from 
                which this application is dervied"),
                h4(HTML("<b>Note: Global Sales are in millions of units</b>")),
                br(),
                dataTableOutput("summarydt") 
                )
        ),
        tabPanel("Visualize",
                 sidebarLayout(
                         sidebarPanel(
                                 h4("Use the inputs below to generate visualizations of
                                    the video game sales data"),
                                 br(),
                                 selectInput("graphs","Choose a Graph",choices=c(
                                         "Total Lifetime Sales","Sales by Genre",
                                         "Game Releases by Year and Rating",
                                         "User Review by Platform in 2016"))
                                 ),
                         mainPanel(
                                 h4("These graphs are interactive! Scroll your mouse
                                    over data points for more information."),
                                 br(),
                                 br(),
                                 plotlyOutput("ggplotly"),
                                 br(),
                                 br(),
                                 tableOutput("tableplot")
                         )
                         )
        ),
        tabPanel("Model",
                 sidebarLayout(
                         sidebarPanel(
                                h4("Predict game sales based on critics'
                                   reception (data is from 2016)"),
                                br(),
                                numericInput("pred1","Enter a Critic Score",value=80,
                                min=0,max=100,step=1),
                                br(),
                                br(),
                                textOutput("predtext")
                         ),
                         mainPanel(
                                 plotOutput("predplot")
                         )
                 )
        )
)