install.packages("countrycode")
install.packages("rworldmap")
install.packages("qdapDictionaries")
install.packages("RSQLite")


library(countrycode)
library(rworldmap)
library(DBI)
library(RSQLite)
library(qdapDictionaries)

data(countrycode_data)
count.occurences<-function(needle,haystack){
  sapply(regmatches(haystack,gregexpr(needle,haystack,ignore.case=T,perl=T)),length)
}
countrycode_data_without_atf<- countrycode_data[-83,]

countries<- countrycode_data_without_atf[, c("country.name","regex","iso2c","iso3c")]

countries$other<- NA
countries[countries$country.name=="United Kingdom",]$other<-"UK"

db<-dbConnect(dbDriver("SQLite"), "D:\\BIA\\FE550Data Visualization\\Final Project_Individual\\Hillary Clinton's Emails\\database.sqlite")
dbListTables(db)

emailsFromHillary<-data.frame(dbGetQuery(db,"SELECT ExtractedBodyText EmailBody
  FROM Emails e INNER JOIN Persons p ON e.SenderPersonId=P.ID 
  WHERE p.Name='Hillary Clinton' AND e.ExtractedBodyText !='' ORDER BY RANDOM()"))


all_hillary_emails<-paste(emailsFromHillary$EmailBody,collapse="//")

country_occurrences<-data.frame(country=countrycode_data_without_atf$country.name,
                                continent=countrycode_data_without_atf$continent,
                                region=countrycode_data_without_atf$region,
                                ISO3C=countrycode_data_without_atf$iso3c)

country_occurrences$occurences<-NA

words_to_remove<-rbind(DICTIONARY[nchar(DICTIONARY$word)==2,],DICTIONARY[nchar(DICTIONARY$word)==3,])
words_to_be_removed <- toupper(c(words_to_remove$word, "RE", "FM", "TV", "LA", "AL", "BEN", "AQ"))

for(i in 1:nrow(countries))
{  
  n_occurences <- 0
  if(!is.na(countries[i, "regex"]))
 {
   tmp <- count.occurences(countries[i, "regex"], all_hillary_emails)
   n_occurences <- n_occurences + tmp
   
   if(tmp > 0)
     print(paste(tmp, countries[i, "regex"]))
  }
 
 
 #remove words that are ISO2 country codes
 if( (! (countries[i, "iso2c"] %in% words_to_be_removed) ) && (!is.na(countries[i, "iso2c"]))  )
 {
   iso_boundary <- paste0("\\s", countries[i, "iso2c"], "\\s")
   
   tmp <- count.occurences(iso_boundary, all_hillary_emails)
   
   n_occurences <- n_occurences + tmp
   
   if(tmp >0)
     print(paste(tmp, countries[i, "iso2c"]))
 }
 
 
 #remove words that are ISO3 country codes
 if( (! (countries[i, "iso3c"] %in% words_to_be_removed) ) && (!is.na(countries[i, "iso3c"]))  )
 {
   iso_boundary <- paste0("\\s", countries[i, "iso3c"],"\\s")
   
   tmp <- count.occurences(iso_boundary, all_hillary_emails)
   
   n_occurences <- n_occurences + tmp
   
   if(tmp >0)
     print(paste(tmp, countries[i, "iso3c"]))
 }
 
 #remove words that are other country codes
 if( (! (countries[i, "other"] %in% words_to_be_removed) ) && (!is.na(countries[i, "other"]))  )
 {
   iso_boundary <- paste0("\\s", countries[i, "other"],"\\s")
   
   tmp <- count.occurences(iso_boundary, all_hillary_emails)
   
   n_occurences <- n_occurences + tmp
   
   if(tmp >0)
     print(paste(tmp, countries[i, "other"]))
 } 
 else if(tmp <= 0) {
   
   tmp <- count.occurences(countries[i,1], all_hillary_emails)
   
   n_occurences <- n_occurences + tmp
   
 }
 
 country_occurrences[i,]$occurences <- n_occurences
 
}
country_occurrences <- na.omit(country_occurrences)
country_occurrences <- country_occurrences[country_occurrences$occurences>0,]
country_occurrences <- country_occurrences[with(country_occurrences, order(-occurences)),]

par(mai=c(0,0,0.2,0),xaxs="i",yaxs="i")

mapByRegion( country_occurrences
             , nameDataColumn="occurences"
             , joinCode="ISO3"
             , nameJoinColumn="ISO3C"
             , mapTitle="US Foreign Policy Country Map through Hillary Clinton's emails"
             , regionType="IMAGE24"
             , oceanCol="lightblue"
             ,missingCountryCol="white"
             , FUN="sum" )





