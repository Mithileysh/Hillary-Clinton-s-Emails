library(DBI)
library(RSQLite)

setwd("D:\\BIA\\FE550Data Visualization\\Final Project_Individual\\Hillary Clinton's Emails")
db <- dbConnect(dbDriver("SQLite"), "database.sqlite")

library(dplyr)
library(ggplot2)
library(DBI)
library(topicmodels)
library(NLP)
library(tm)
library(RColorBrewer)
library(wordcloud)

#senders
commonSenders <- dbGetQuery(db, "SELECT p.Name, COUNT(p.Name) as NumEmailsSent
FROM Emails e INNER JOIN Persons p ON e.SenderPersonId=p.Id
GROUP BY p.Name ORDER BY COUNT(p.Name) DESC LIMIT 10")

ggplot(commonSenders, aes(x=reorder(Name, NumEmailsSent), y=NumEmailsSent)) +
  geom_bar(stat="identity",fill="#0072B2") +
  coord_flip() + 
  theme_light(base_size=16) +
  xlab("") +
  ylab("Number of Emails Sent") + 
  theme(plot.title=element_text(size=14))

#recipients
commonRecipients <- dbGetQuery(db, "SELECT p.Name, COUNT(p.Name) as NumEmailsReceived
FROM Emails e INNER JOIN EmailReceivers r ON r.EmailId=e.Id
INNER JOIN Persons p ON r.PersonId=p.Id
GROUP BY p.Name ORDER BY COUNT(p.Name) DESC LIMIT 10")

ggplot(commonRecipients, aes(x=reorder(Name, NumEmailsReceived), y=NumEmailsReceived)) +
  geom_bar(stat="identity", fill="#CC79A7") +
  coord_flip() + 
  theme_light(base_size=16) +
  xlab("") + 
  ylab("Number of Emails Received") + 
  theme(plot.title=element_text(size=14))

#wordcloud
emailsFromHillary <- dbGetQuery(db, "SELECT p.Name as Sender, ExtractedBodyText as EmailBody
FROM Emails e INNER JOIN Persons p ON e.SenderPersonId=P.Id
WHERE p.Name='Hillary Clinton' AND e.ExtractedBodyText != '' ORDER BY RANDOM()")

emailsAboutTerror <- dbGetQuery(db, "SELECT p.Name as Sender, ExtractedBodyText as EmailBody,MetadataDateSent as Date
FROM Emails e INNER JOIN Persons p ON e.SenderPersonId=P.Id
WHERE e.ExtractedBodyText LIKE '%terror%' ORDER BY RANDOM()")

                
corpus = Corpus(VectorSource(tolower(emailsAboutTerror)))
corpus = tm_map(corpus,PlainTextDocument)
corpus = tm_map(corpus, removePunctuation)
corpus = tm_map(corpus, removeNumbers)
corpus = tm_map(corpus, removeWords,c(stopwords("english")))
dropwords=c("the","and","can","call","thx","thanks","see",
"will","pls","hillary","clinton","FW","Re","huma","abedin","cheryl","jake","mills","sullivan",
"lauren","jiloty","sid","blumenthal","sidney","lona","valmoro","philippe","annemaria","slaughter",
"fyi")
corpus=tm_map(corpus,removeWords,dropwords)
#corpus = tm_map(corpus, stemDocument)

  
frequencies = DocumentTermMatrix(corpus)

word_frequencies = as.data.frame(as.matrix(frequencies))
  
words <- colnames(word_frequencies)
freq <- colSums(word_frequencies)

wordcloud(words, freq,min.freq=80,scale = c(2, 0.2),random.order=FALSE,
          colors=brewer.pal(8, "Dark2"),random.color=TRUE)  


##common terms
findFreqTerms(frequencies, lowfreq=100)
termFreq  = colSums(as.matrix(frequencies))
termFreq  = subset(termFreq, termFreq>=150)
df= data.frame(term=names(termFreq), freq=termFreq)

ggplot(df, aes(x=reorder(term, freq, max), y=freq)) +
  geom_bar(stat="identity") +
  ggtitle("Most Common Terms") +
  xlab("Terms") +
  ylab("Frequency") +
  coord_flip()


#Associated terms


cor_terms=findAssocs(frequencies, "terrorist", 0.8) # specifying a correlation limit of 0.98   
cor_terms


#topic models
"""
ldaText= LDA(frequencies[1:3,], k=10) # 25 topics
topicTerms= terms(ldaText, 5)  # first 5 terms for each topic
topicTerms= apply(topicTerms, MARGIN=2, paste, collapse=", ")
topicsText= topics(ldaText, 1)
topic= as.factor(topicsText)
print(topicsText)
"""
"""
topicsSeries = data.frame(date=as.Date(News$PubDate), topic=topicsText, terms=topicTerms[topicsText])

ggplot(topicsSeries, aes(x=date)) +
  geom_density(aes(y=..count.., fill=terms), position="stack") +
  ggtitle("Evolution of the Distribution of Topics") +
  xlab("Publication Date") +
  ylab("Frequency") 
"""
