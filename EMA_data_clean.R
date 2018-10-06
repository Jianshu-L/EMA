library(rjson)
library(plyr)
library(tidyverse)
load("~/HMM/output/EMA_data.RData")

# check the value of location
a <- data.frame(unique(data$location))
location_value <- data.frame(a[-grep(",", as.character(a[,1])),])
print(as.character(location_value[,1]))
# [1] NA  "null"  "Unknown"  "3"   

# set the location to NA if they are "null", "Unknown" or "3"
is.na(data$location) <- data$location == "null"
is.na(data$location) <- data$location == "Unknown"
is.na(data$location) <- data$location == "3"

## no response 2237
no_resp <- data[which(apply(data[,(which(colnames(data) == "data_type")+1)
                                 :ncol(data)], 1, function(x)all(is.na(x)))),]
# have response time 1882
time <- filter(no_resp, !is.na(no_resp$resp_time))
# check the value of null
a <- data.frame(unique(time$null))
null_value <- data.frame(a[-grep(",", as.character(a[,1])),])
print(as.character(null_value[,1]))
# null is NA 1
no_null_NA <- filter(time, is.na(time$null))
# null is others, unknown row 1881
no_null_others <- filter(time, !is.na(time$null))

# have no response time 355
no_resptime <- filter(no_resp, is.na(no_resp$resp_time))
# they are equal no_resptime <- filter(data, is.na(data$resp_time))

## have responses 20203
responses <- data[-which(apply(data[,(which(colnames(data) == "data_type")+1)
                                    :ncol(data)], 1, function(x)all(is.na(x)))),]

# check the value of null
a <- data.frame(unique(responses$null))
yes_null <- data.frame(a[-grep(",", as.character(a[,1])),])
print(as.character(yes_null[,1]))
# [1] NA  "5"  "3"  "null"  "Unknown"  "4"  "1"  "2"  "location"   

# when the value of null is NA 19979
null_NA <- filter(responses, is.na(responses$null))

# when the value of null is 1,2,3,4,5 146
null_12345 <- filter(responses, null == "1" | null == "2" | null == "3" | 
                             null == "4" | null == "5")
# when the data_type is Behavior 17
B <- filter(null_12345, data_type == "Behavior")
B <- B[,-which(apply(B, 2, function(x)all(is.na(x))))]
# null means the location
null_loc_12345 <- data[B$num, ]
null_loc_12345$location <- null_loc_12345$null
null_loc_12345$null <- NA

# when the data_type is Study Spaces 129
ss <- filter(null_12345, data_type == "Study Spaces")
ss <- ss[,-which(apply(ss, 2, function(x)all(is.na(x))))]
# null means the noise 
null_noise <- data[ss$num, ]
null_noise[which(null_noise$data_type == "Study Spaces"), "noise"] <- 
        null_noise[which(null_noise$data_type == "Study Spaces"), "null"]
null_noise$null <- NA

# the value of null is "null" and "Unknown". 10
null_loc_others <- filter(responses, null == "null" | null == "Unknown")
B1 <- null_loc_others[,-which(apply(null_loc_others, 2, 
                                    function(x)all(is.na(x))))]
null_loc_others <- data[B1$num, ]
null_loc_others$location <- null_loc_others$null
null_loc_others$null <- NA

# the value of null is "location". 68
null_loc <- responses[grep(",", as.character(responses$null)),]
# as resp_loc equal to filter(resp_loc, is.na(resp_loc$location)), when null is 
# location, all the values of "location" are NA
null_loc$location <- null_loc$null
null_loc$null <- NA

# unknown rows: 1881
unknown <- no_null_others

# whole response is empty: 355
empty_all <- no_resptime

# don't have any questions: Stress u36 only 1
empty_row <- no_null_NA

# responses + null means the "noise" in study spaces + null means the location
# 19979 + 129 + (17 + 10 + 68) = 20203
resp_norm <- rbind(null_NA, null_noise, 
                   null_loc_12345, null_loc_others, null_loc)

setwd("~/HMM/output")
save(unknown, file = "EMA_Unknown.RData")
write.csv(unknown, file = "EMA_Unknown.csv")
save(empty_all, file = "EMA_Empty_all.RData")
write.csv(empty_all, file = "EMA_Empty_all.csv")
save(empty_row, file = "EMA_Empty_row.RData")
write.csv(empty_row, file = "EMA_Empty_row.csv")
save(resp_norm, file = "EMA_Resp_norm.RData")
write.csv(resp_norm, file = "EMA_Resp_norm.csv")
