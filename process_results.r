#######################################
#           CLEAN WORKSPACE           #
#######################################
rm(list = ls())
cat("\014")
# dev.off(dev.list()["RStudioGD"])


#######################################
#               IMPORTS               #
#######################################
library(ggplot2)


#######################################
#           SETUP & INPUTS            #
#######################################
setwd("C:/Users/rogus/Desktop/Master-Thesis/Jmeter_skrypty")
warmup            <- 7    # [s]
measurement_time  <- 5    # [s]
max_response_time <- 200  # [ms]


#######################################
#              FUNCTIONS              #
#######################################
getBenchmarkDF <- function(df, warmup, measurement_time) {
  df$responceTimeStamp <- df$timeStamp + df$elapsed # when the last chunk of the response has been received
  estimated_benchmark_start <- min(df$timeStamp) + warmup * 1000
  tmp <- df[df$responceTimeStamp>estimated_benchmark_start, 'responceTimeStamp']
  benchmark_start <- min(tmp)
  benchmark_end <- benchmark_start + measurement_time * 1000
  return( df[df$responceTimeStamp>=benchmark_start & df$responceTimeStamp<=benchmark_end,] )
}

getStat <- function(df, total_time, max_latency=200, drop_unsuccessful=TRUE) {
  all_requests <- nrow(df)
  if(drop_unsuccessful) df <- df[df$responseCode==200,]
  successful_requests <- nrow(df)
  error_rates <- (all_requests-successful_requests) / all_requests
  median_latency <- median(df$Latency)
  q90_latency <- quantile(df$Latency, probs=c(0.9))
  if(max_latency>0) df <- df[df$Latency<=max_latency,]
  throughput <- nrow(df) / total_time
  result <- list(Throughput=throughput, Median_latency=median_latency, Q90_latency=q90_latency, Error_rates=error_rates)
  return(result)
}


#######################################
#             COLLECT DATA            #
#######################################
columns = c("Iteration","Users","Throughput","Median_latency", "Q90_latency", "Error_rates") 
statsDF = data.frame(matrix(nrow = 0, ncol = length(columns))) 
colnames(statsDF) = columns

iterationDirectories <- list.dirs(full.names=FALSE)[-1]

for(iterationDirectory in iterationDirectories) {
  iteration <- strtoi(iterationDirectory)
  csvFiles <- list.files(path=iterationDirectory, pattern="*.csv", full.names=FALSE)
  
  for(csvFile in csvFiles) {
    users_at_iteration <- strtoi(substr(csvFile, 0, nchar(csvFile)-4))
    data <- read.csv(file.path(iterationDirectory, csvFile))
    data <- getBenchmarkDF(data, warmup, measurement_time)
    
    statsDF[nrow(statsDF) + 1,] <- c(iteration, users_at_iteration, getStat(data, measurement_time))
  }
}


#######################################
#                 PLOT                #
#######################################
# p1 <- 
# png(file=paste("throughput.png", sep = ""), width = 1000, height= 800, res = 190)
# print(p1)
# dev.off()

ggplot(statsDF, aes(x=Users, y=Throughput)) +
  geom_point() +
  facet_wrap(~Iteration)

df <- aggregate(cbind(Throughput, Median_latency, Q90_latency, Error_rates) ~ Users, statsDF, FUN = median)

ggplot(df, aes(x=Users, y=Throughput)) + geom_point()
