library(rjson)
library(plyr)
library(tidyverse)
load("~/EMA/output/EMA_data.RData")
setwd("/Users/ljs/Desktop/Hidden Markov/dataset/dataset/EMA")
a <- fromJSON(file = dir()[1])
b <- c()
data_define <- data.frame()
for (i in 1:length(a)){
        b <- a[[i]]
        type <- b[[1]]
        l <- length(b$questions)
        # print(l)
        for (col in 1:l){
                data_i <- data.frame(b$questions[[col]], data_type = type)
                data_define <- rbind.fill(data_define, data_i)
        }
}
data_define <- data_define[order(as.character(data_define$data_type)), ]

setwd("~/EMA/output")
save(data_define, file = "EMA_define.RData")
write.csv(data_define, file = "EMA_define.csv")

# k = c(NULL)
# data_type <- levels(md_when$data_type)
# for (i in data_type){
#         l = length(which(md_when$data_type == i))
#         m = length(which(data_define$data_type == i)) -
#                 length(which(data_define$data_type == i
#                              & data_define$question_id == "location"))
#         k = c(k, rep(m, l))
# }
# k = data.frame(q_num = k)