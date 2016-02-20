
install.packages('dplyr')
install.packages('stringr')
install.packages('igraph')


library(dplyr)
library(igraph)
library(stringr)

library(DBI)
library(RSQLite)

setwd("D:\\BIA\\FE550Data Visualization\\Final Project_Individual\\Hillary Clinton's Emails")
#emails = read.csv("Emails.csv", stringsAsFactors = F)
emails=dbGetQuery(db, "SELECT Id,SenderPersonId, ExtractedBodyText as EmailBody, MetadataDateSent as Date, 
MetadataSubject as Subject FROM Emails")
emails_terror=dbGetQuery(db, "SELECT Id,SenderPersonId, ExtractedBodyText as EmailBody, MetadataDateSent as Date, 
MetadataSubject as Subject FROM Emails WHERE ExtractedBodyText LIKE '%terror%' ORDER BY RANDOM()")
persons = read.csv("Persons.csv", stringsAsFactors = F)
receivers = read.csv("EmailReceivers.csv", stringsAsFactors = F)
# rename the Personid variable in receivers dataset as ReceiverID
receivers = rename(receivers,  ReceiverId = PersonId)

# merge with the original email dataset (you can also use sqldf)
emails_joined = left_join(emails, receivers, by = c("Id" = "EmailId"))
#emails_joined = left_join(emails_terror, receivers, by = c("Id" = "EmailId"))


# create the edge list
emails_joined[,1] = NULL
emails_edge_list = select(emails_joined, SenderPersonId, ReceiverId)
emails_edge_list = emails_edge_list[complete.cases(emails_edge_list),]

email_graph = graph.data.frame(emails_edge_list,directed=FALSE)
V(email_graph)$id = V(email_graph)$name
V(email_graph)$name = persons$Name[match(V(email_graph)$name, as.character(persons$Id))]
V(email_graph)$name
V(email_graph)$id
# visualization
plot(email_graph,main="Email Graph about Terror",
     vertex.size=5, vertex.color='red', edge.color='grey',vertex.label.cex=0.9,
     vertex.label.dist=0.4,edge.arrow.size=.4)

# descriptive stats
vcount(email_graph)
sort(degree(email_graph), decreasing = T)[1:10]
cliques(email_graph, min = 6)
maximal.cliques(email_graph, min = 6)


# President Clinton's 2-degree egocentric network
bill_egocentric = graph.neighborhood(email_graph, order = 2,
                    nodes = which(V(email_graph)$name == "Bill Clinton"))[[1]]
plot(bill_egocentric)

# remove Hillary from the network
hillary_egocentric = delete.vertices(email_graph,
                                     which(V(email_graph)$name == "Hillary Clinton"))
vcount(hillary_egocentric)
plot(hillary_egocentric, layout=layout.fruchterman.reingold(email_graph),
     vertex.size=2,
     vertex.label=NA, edge.arrow.size=.2)
sort(degree(hillary_egocentric), decreasing = T)[1:10]

######### Closeness Centrality and Election-related Email ###########
# create a new variable "election_related" if election is mentioned in subject or text
emails_joined$china_related =
  str_detect(tolower(emails_joined$EmailBody), "china") |
  str_detect(tolower(emails_joined$Subject), "china")
emails_china=emails_joined[which(emails_joined$china_related==TRUE),]



# tag a node's election attribute as TRUE if it is involved in election discussion
china_nodes =unique(unlist(filter(emails_joined, china_related == TRUE) %>% select(ReceiverId, SenderPersonId)))
china_names = persons$Name[match(china_nodes, as.character(persons$Id))]

V(hillary_egocentric)$china = V(hillary_egocentric)$name %in% china_names
V(hillary_egocentric)[V(hillary_egocentric)$china == TRUE]$color = "red"
plot(hillary_egocentric, layout=layout.fruchterman.reingold(hillary_egocentric),
     vertex.size=2,
     vertex.label=NA, edge.arrow.size=.2)

closeness_centrality = closeness(hillary_egocentric, normalized = TRUE)


