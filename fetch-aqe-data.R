# install.packages('RCurl')
# install.packages("ggplot2")
#install.packages("gridExtra")
library(ggplot2)
library(gridExtra)
library(RCurl)

getData = function(feedId, streamId, startDate, endDate) {

  api_key = 'JehowmsOBe7b2A7qB8JTktZCTB4UdRZAfPKbxwWH0tkDBtZN'
  csvData = ""
  
  while (startDate < endDate) {
    startDate_as_str = format(startDate, format="%Y-%m-%dT%H:%M:00Z")
    nextDate = startDate + (3 * 60 * 60)
    nextDateAsStr = format(nextDate, format="%Y-%m-%dT%H:%M:00Z")
    cosmUrl = paste("http://api.cosm.com/v2/feeds/", feedId, "/datastreams/", streamId, ".csv?start=", startDate_as_str, "&end=", nextDateAsStr,"&interval=0", sep="")    
    print(cosmUrl)
    csvDataForPeriod = getURL(cosmUrl, httpheader = c('X-ApiKey' = api_key) )
    csvData = paste(csvData, csvDataForPeriod, "\n")
    startDate = nextDate
  }

  data = read.table(textConnection(csvData), sep = ",", col.names=c("at", "value"))
  data$timestamp <- strptime(data$at, "%FT%T", tz = "UTC")

  # strip out crazy values
  data = data[which(data$value > 0),]
  return(data)
}

# Brixton
# https://xively.com/feeds/106267
brixtonFeedId = '106267'
brixtonStreamId = 'NO2_00-04-a3-37-cc-cb_0'
# AQE Brinscall Lancashire UK
#https://xively.com/feeds/107106
lancashireFeedId = '107106'
lancashireStreamId = 'NO2_00-04-a3-ad-9c-1d_0'

# Kington Langley Wiltshire UK
#https://xively.com/feeds/102930
wiltshireFeedId = '102930'
wiltshireStreamId = 'NO2_00-04-a3-37-bb-29_0'

brixtonData = getData(brixtonFeedId, brixtonStreamId, as.POSIXct("2013/06/23","GMT"), as.POSIXct("2013/07/20","GMT"))
write.csv(brixtonData, file = "data/brixton.csv")

lancashireData = getData(lancashireId, lancashireStreamId, as.POSIXct("2013/06/23","GMT"), as.POSIXct("2013/07/20","GMT"))
write.csv(lancashireData, file = "data/lancashire.csv")

wiltshireData = getData(wiltshireFeedId, wiltshireStreamId, as.POSIXct("2013/06/17","GMT"), as.POSIXct("2013/07/19","GMT"))
write.csv(wiltshireData, file = "data/wiltshire.csv")

summary(brixtonData$value)
summary(lancashireData$value)
summary(wiltshireData$value)

plot(brixtonData$value)
plot(lancashireData$value)
plot(wiltshireData$value)

#plot(brixtonData[which(brixtonData$value < 20000),]$value)
#plot(lancashireData[which(lancashireData$value < 20000),]$value)
#plot(wiltshireData[which(wiltshireData$value < 20000),]$value)
#ggplot(wiltshireData, aes(wiltshireData$timestamp, wiltshireData$value)) + geom_smooth() + xlab("Time") + ylab("NO2 PPB")
