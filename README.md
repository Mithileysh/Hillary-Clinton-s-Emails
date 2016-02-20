# Hillary-Clinton-s-Emails


Overview 
As the United States Secretary of State, Hillary Clinton used personal email accounts to conduct Secretary of State Affairs during her time, which caused a lot of controversy throughout 2015. There have been a number of Freedom of Information lawsuits filed over the State Department's failure to fully release the emails sent and received on Clinton's private accounts. On Monday, August 31, the State Department released nearly 7,000 pages of Clinton's heavily redacted emails. 
My goal was to answer the following questions: 1. Who sent or received most emails? 2. What topics did the State Department care most? 3. Who were the close links to Hillary Clinton regarding email exchanges?


Data Analysis
Data was obtained from a Kaggle competition. There are three main approaches used to analyze the data: 
1.	World Map
Which countries were cared most in her emails?
2.	Text mining 
I processed the email texts, such as removing punctuations, numbers and stop-words, then transformed the texts to a term matrix. Then I filtered the emails with the key word terror, and used R to draw word cloud of highly relevant words. I also employed Latent Dirichlet Allocation method to find the most common topics in the emails.
3.	Social network analysis
I built the social network graph among the email senders and recipients to explore the social links of Hillary Clinton, emails about terror in particular. 


Results
The output includes top 10 email senders and receivers, the wordcloud of terms that are most relevant to terror, the graph of the Hillary Clinton’s email contacts network, and the graph of emails about terrorism. 


Insights
Most of the people exchanging emails with Hillary Clinton were working for her, this have been shown from the frequency bar charts and the network measures. If we expand the range, I could also found her contacts outside the State Department and the topics they were discussing.
Using terror as the key word, I found the people who were talking about it and the most relevant words, like Obama, president, diplomacy, Mcchrystal, security, military and a couple of countries. 

