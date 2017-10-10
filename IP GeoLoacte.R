##created by Raleigh Burrell on Oct 2 2017 
##WD
setwd('~/Documents/GitHub/RaleighInfo3300Repo/BuildAlamosa/')
##

#function to use rjson to get ip info
freegeoip <- function(ip, format = ifelse(length(ip)==1,'list','dataframe'))
{
  if (1 == length(ip))
  {
    # a single IP address
    require(rjson)
    url <- paste(c("http://freegeoip.net/json/", ip), collapse='')
    ret <- fromJSON(readLines(url, warn=FALSE))
    if (format == 'dataframe')
      ret <- data.frame(t(unlist(ret)))
    return(ret)
  } else {
    ret <- data.frame()
    for (i in 1:length(ip))
    {
      r <- freegeoip(ip[i], format="dataframe")
      ret <- rbind(ret, r)
    }
    return(ret)
  }
}  

#needed packages
library(rjson)
library(dplyr)
library(iptools)

#how to build new table
test <- freegeoip('68.206.15.30')

UrlClick <- read.csv('UrlClick.csv')
ips <- mutate(select(UrlClick, ip), ip = as.character(ip))
test2 <- data.frame(freegeoip(ips[2,1]))
nrow(ips)

#writing data
geolocation <- data.frame(ip = character(n), 
                          country_code = factor(n), 
                          country_name = character(n), 
                          region_code = factor(n),
                          region_name = character(n),
                          city = character(n),
                          zip_code = factor(n),
                          time_zone = factor(n),
                          latitude = numeric(n),
                          longitude = numeric(n),
                          metro_code = numeric(n))
for (i in 1:nrow(ips)) {
  if (is_valid(ips[i,1])) {
    geolocation <- rbind(geolocation, data.frame(freegeoip(ips[i,1])))
  }
}

nlevels(as.factor(geolocation$ip))
write.csv(x = geolocation, file = 'GeoLocation.csv')


#foreign key errors
urlclick <- read.csv('UrlClick.csv', header = F) ##compare against sub ids
subscriber <- read.csv('Subscriber.csv', header = F)

urlclick <- mutate(urlclick, missing = 'True')
##test false id
###urlclick$V4[1] <- 1

###oldmethod
for (i in 1:nrow(urlclick)) {
  if (match(x = urlclick$V4[i], table = subscriber$V1, nomatch = 0) == 0) {
    urlclick$missing[i] <- 'False'
  }
}
table(urlclick$missing)

### sexty method
matches <- data.frame(locations = match(x = urlclick$V4, table = subscriber$V1))
summarize(matches, missing = sum(is.na(locations)))
