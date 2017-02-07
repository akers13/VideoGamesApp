library(shiny); library(ggplot2);library(plotly); library(dplyr)
games<-read.csv("./Video_Games_Sales_as_at_22_Dec_2016.csv",stringsAsFactors=FALSE)
plotdata<-games[1:10,]
reg<-games %>% filter(is.na(Critic_Score)==FALSE,
        Year_of_Release==2016)   
fit<-lm(log(Global_Sales)~I(Critic_Score^4),data=reg)
shinyServer(
        function(input,output){
                ## Summary bar chart
                output$summaryplot<-renderPlot(
                        barplot(plotdata$Global_Sales,names.arg=LETTERS[1:10],
                                main="Top Ten Video Games by Lifetime Global Sales",
                                ylab="Sales (millions of units)",
                                legend.text=sapply(1:10,function(x){paste(LETTERS[x],
                                "-",plotdata$Name[x])})),
                                )
                ## Data table of raw data
                output$summarydt<-renderDataTable(games[,c(1:5,10,11,13,16)])
                ## Interactive plot on Visualize tab
                output$ggplotly<-renderPlotly({
                        if(input$graphs=="Total Lifetime Sales"){
                                ggplotly(ggplot(games[1:10,],aes(x=Name,y=Global_Sales,
                                text=LETTERS[10:1]))+
                                geom_bar(stat="identity",fill="dark green")+
                                scale_x_discrete(limits=games$Name[10:1],
                                labels=LETTERS[10:1])+
                                ggtitle("Total Lifetime Sales")+xlab("")+
                                ylab("Global Sales (millions of units)")+coord_flip())
                        }
                        else if(input$graphs=="Sales by Genre"){
                                games<-games[-which(games$Genre==""),]
                                ggplotly(ggplot(games,aes(x=log(Global_Sales),
                                fill=Genre))+geom_histogram()+
                                facet_wrap(~Genre)+ylab("# of Games")+
                                ggtitle("Distribution of Game Sales by Genre (log scale)"))
                        }
                        else if(input$graphs=="Game Releases by Year and Rating"){
                                years<-games %>% filter(Rating!="") %>%
                                        group_by(Year_of_Release,Rating) %>% 
                                        summarise(Count=n()) %>% as.data.frame()
                                years$Year_of_Release<-as.numeric(years$Year_of_Release)
                                ggplotly(ggplot(years,aes(x=Year_of_Release,y=Count,
                                color=Rating))+ylab("Number of Game Releases")+
                                geom_line(size=1.2)+
                                ggtitle("Number of Game Releases by Year and Rating"))
                        }
                        else {
                                year<-games %>% filter (Year_of_Release==2016,
                                        is.na(User_Score)==FALSE,User_Score!="",
                                        User_Score!="tbd") %>% 
                                        transform(User_Score=as.numeric(User_Score))
                                ggplotly(ggplot(year,aes(x=Platform,y=User_Score,
                                fill=Platform))+geom_boxplot()+
                                ggtitle("User Review Scores by Platform (2016)"))
                        }
                })
                ## Extra information for plots
                output$tableplot<-renderTable({
                        if(input$graphs=="Total Lifetime Sales"){
                                data.frame(Value=LETTERS[1:10],Game=plotdata$Name[1:10])
                        }
                        else if (input$graphs=="Sales by Genre"){
                                return()
                        }
                        else if (input$graphs=="Game Releases by Year and Rating"){
                                years<-games %>% filter(Rating!="") %>%
                                        group_by(Year_of_Release,Rating) %>% 
                                        summarise(Count=n()) %>% as.data.frame()
                                data.frame(Rating=unique(years$Rating),
                                Key=c("Teen","Everyone 10+","Mature","Everyone",
                                      "Kids to Adults","Adults Only","
                                      Early Childhood","Rating Pending"))
                        }
                        else {
                                year<-games %>% filter (Year_of_Release==2016,
                                        is.na(User_Score)==FALSE,User_Score!="",
                                        User_Score!="tbd") %>% 
                                        transform(User_Score=as.numeric(User_Score))  
                                data.frame(Platform=unique(year$Platform),
                                Key=c("Playstation 4","Xbox One","Wii U",
                                      "Nintendo 3DS","Playstation 3",
                                      "Personal Computer","Xbox 360",
                                      "Playstation Vita"))
                        }
                },spacing="xs")
                ## Plot on which regression predictions are based
                output$predplot<-renderPlot({
                ggplot(reg,aes(x=Critic_Score,y=log(Global_Sales)))+
                geom_point()+geom_smooth(method="lm",formula=y~I(x^4))+
                ggtitle("Critic Score versus Global Sales for 2016 Games")})  
                ## Text on predictions generated by the model
                output$predtext<-renderText({
                        pred<-unname(round(exp(predict(fit,
                        newdata=data.frame(Critic_Score=input$pred1))),2))
                        paste("Based on the data, this model predicts that a game with a
                              critic score of",input$pred1,"will sell",pred,
                              "million units in a year.")
                })
        }
)