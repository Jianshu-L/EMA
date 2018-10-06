library(rjson)
library(plyr)
library(tidyverse)

data <- data.frame()
setwd("/Users/ljs/Desktop/Hidden Markov/dataset/dataset/EMA/response")
for (f in 1:length(dir())){
        # 遍历所有data_type
        setwd("/Users/ljs/Desktop/Hidden Markov/dataset/dataset/EMA/response")
        type = dir()[f]
        setwd(type)
        for (i in 1:length(dir())){
                # 遍历所有subject
                file <- fromJSON(file = dir()[i])
                l = length(file)
                # 删掉后缀
                s = unlist(strsplit(dir()[i], split = "\\."))[1]
                # 删掉文件名中的data_type，只留下u00
                s = unlist(strsplit(s, split = "\\_"))[2]
                if (l > 0){
                        for (col in 1:l){
                                data_i <- data.frame(c(file[[col]]), subject = s, 
                                                     data_type = type)
                                data <- rbind.fill(data, data_i)
                        }
                }else{
                        data_i <- data.frame(subject = s, data_type = type)
                        data <- rbind.fill(data, data_i)
                }
                
        }
}
data <- data[,c(colnames(data[1:5]), colnames(data[10]), 
                colnames(data[6:9]), colnames(data[11:72]))]

data$unix <- data$resp_time
Sys.setenv(TZ="Europe/London")
data$resp_time <- as.POSIXct(as.numeric(data$resp_time), 
                             origin = '1970-01-01', tz = 'EST')
data$Hour <- as.POSIXlt(data$resp_time)[[3]]
data$hour <- data$Hour
data$day <- weekdays(data$resp_time)
data <- data[,c(colnames(data[1:3]), colnames(data[c(73,75,65)]), 
                colnames(data[c(4:64,66:72,74)]))]
data$day[which(data$day == 0)] <- "Monday"
data$day[which(data$day == 1)] <- "Tuesday"
data$day[which(data$day == 2)] <- "Wednesday"
data$day[which(data$day == 3)] <- "Thursday"
data$day[which(data$day == 4)] <- "Friday"
data$day[which(data$day == 5)] <- "Saturday"
data$day[which(data$day == 6)] <- "Sunday"
data$day[which(data$day == 0)] <- "Monday"

data$hour[which(data$Hour >= 9 & data$Hour < 18)] <- "day"
data$hour[which(data$Hour >= 0 & data$Hour < 9)] <- "night"
data$hour[which(data$Hour >= 18 & data$Hour <= 23)] <- "evening"
data <- select(data, Social2:noise)
data <- data[,c(colnames(data[1:2]), colnames(data[c(9)]), 
                colnames(data[c(3:8,10:74)]))]
data <- mutate(data, num = 1:nrow(data))
data <- data[,c("num", colnames(data[1:74]))]

setwd("~/EMA/output")
save(data, file = "EMA_data.RData")
write.csv(data, file = "EMA_data.csv")
