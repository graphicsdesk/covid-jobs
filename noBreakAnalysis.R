
 
library(tidyverse) # We need ggplot (for viz) and dplyr (for data wrangling)
library(dplyr) 
library(mongolite) # Simple MongoDB client
library(zoo) # Provides a rolling mean function we will use in the viz


# Connect to MongoDB
conn <- mongo(
  collection = 'postings',
  db = 'aggregate',
  url = 'mongodb+srv://jason:jason@lionshare-7nhlo.mongodb.net/test?retryWrites=true&w=majority',
  verbose = TRUE
)

# Verify connection by counting the number of records (should be ~66,000)
conn$count('{}')

# Get all postings; convert date strings into date objects
postings <- conn$find('{}') %>% 
  mutate(
    apply_start = as.Date(apply_start),
    expiration_date = as.Date(expiration_date)
  )

 
 
postings %>% 
  # Filter postings to when the scraper has run
  filter(apply_start > "2019-09-06" & apply_start < "2020-04-19") %>% 
  
  # Aggregate by apply_start
  count(apply_start) %>% 
  
  
  # x-value is the date; y-value is the # of postings with that start date
  ggplot(aes(apply_start, n)) + 
  
  # Add a column for every date with length `n`
  geom_col(alpha = 0.3) +
  
  # Add a line to represent the rolling mean on `n`
  geom_line(aes(y = rollmean(n, 7, na.pad = TRUE), color = 'black')) +
  
  # 1 month breaks on x-axis
  scale_x_date(date_breaks = "1 month", date_labels = "%b %Y", expand = c(0, 0)) +
  
  # A hacky way to label and color the rolling mean line
  scale_color_manual(name = '', values = c('black' = 'black'), labels = c('7-day rolling mean')) +
  
  # Label the y-axis
  ylab("Number of postings per day")
 


tab_sum2 = postings %>% group_by(apply_start) %>%
  filter(remote, apply_start > "2019-09-06" & apply_start < "2020-04-19" ) %>%
  summarise(trues = n()) 

ggplot(tab_sum2, aes(apply_start, trues)) + 
  geom_col(alpha = 0.3) +  geom_line(aes(y = rollmean(trues, 7, na.pad = TRUE), color = 'black'))

 
tab_sum = postings %>% group_by(apply_start) %>%
  filter(apply_start > "2019-09-06" & apply_start < "2020-04-19" ) %>%
  summarise(totals = n()) 

tab_sum3 = merge(tab_sum2, tab_sum, by= c("apply_start","apply_start" ))

tab_percent = tab_sum3 %>% group_by(apply_start) %>%
  summarise(percent_remote = ((trues/totals)*100))


ggplot(tab_percent, aes(apply_start, percent_remote)) + 
  geom_col(alpha = 0.3) +  geom_line(aes(y = rollmean(percent_remote, 7, na.pad = TRUE), color = 'black'))


 


 
indus <- postings %>% select(employer_industry_name)
indus <- unique(indus)
indus_avector <- indus[['employer_industry_name']]
indus_avector <- indus_avector[!is.na(indus_avector)]

class(indus_avector)

library(gridExtra)

print(indus_avector)

 
 
temp = postings %>% group_by(apply_start) %>%
  filter((employer_industry_name == indus_avector[1]) & (apply_start > "2019-09-06" & apply_start < "2020-04-19") ) %>%
  summarise(count = n()) 

print(temp)

industry <- indus_avector[1]

ggplot(temp, aes(apply_start, count)) + 
  geom_col(alpha = 0.3) +  geom_line(aes(y = rollmean(count, 7, na.pad = TRUE), color = 'black')) +
  ylab(paste("Number of postings per day in ", indus_avector[1]))

 
 
p <- list()


for(i in indus_avector){
  temp = postings %>% group_by(apply_start) %>%
    filter((employer_industry_name == i) & (apply_start > "2019-09-06" & apply_start < "2020-04-19") ) %>%
    summarise(count = n()) 
  
  p[[i]] <- ggplot(temp, aes(apply_start, count)) + 
    geom_col(alpha = 0.3) +  
    geom_line(aes(y = rollmean(count, 7, na.pad = TRUE), color = 'black')) +
    ylab(paste("Number of postings per day in ", i))
  
  
}

names(p)
 
 
n <- length(p)
nCol <- floor(sqrt(n))
#do.call("grid.arrange", c(p, ncol=3))
 
 
#p


 

 
dates <- postings %>% 
  filter(apply_start > "2019-09-06" & apply_start < "2020-04-19") %>% 
  select(apply_start)
dates <- unique(dates)


for(i in indus_avector){
  temp <- postings %>% group_by(apply_start) %>%
    filter((employer_industry_name == i) & (apply_start > "2019-09-06" & apply_start < "2020-04-19") ) %>%
    summarise(j = n()) 
  
  names(temp)[2] <- as.character(i)
  
  dates <- merge(dates, temp, by= c("apply_start","apply_start" ), all=TRUE)
  
}

dates[is.na(dates)] <- 0
print(dates)

 

 
datesTall <- dates %>% gather(key=industry, value = count, `Movies, TV, Music`:`Forestry`)


rainbow <- ggplot(datesTall, aes(x = apply_start, y= count, fill=industry))+
  geom_bar(position="stack", stat="identity")
rainbow <- rainbow + 
  guides(shape = guide_legend(override.aes = list(size = 0.5))) + 
  guides(color = guide_legend(override.aes = list(size = 0.5))) + 
  theme(legend.title = element_text(size = 3), legend.text = element_text(size = 3))
rainbow


full_rainbow <-  ggplot(datesTall, aes(x = apply_start, y= count, fill=industry))+
  geom_bar(position="fill", stat="identity") + 
  guides(shape = guide_legend(override.aes = list(size = 0.5))) + 
  guides(color = guide_legend(override.aes = list(size = 0.5))) + 
  theme(legend.title = element_text(size = 3), legend.text = element_text(size = 3))
full_rainbow 


line_rainbow <-  ggplot(datesTall, aes(x = apply_start) )+
  geom_line(aes(y = rollmean(count, 7, na.pad = TRUE), color = industry, linetype = industry)) + 
  guides(shape = guide_legend(override.aes = list(size = 0.5))) + 
  guides(color = guide_legend(override.aes = list(size = 0.5))) + 
  theme(legend.title = element_text(size = 3), legend.text = element_text(size = 3)) +
  coord_cartesian(ylim=c(0,15))
line_rainbow 

pop_idus <- postings %>% 
  group_by(employer_industry_name) %>%
  summarize(n=n()) 
pop_idus <- pop_idus %>% arrange(desc(n))

pop_idus_before <- postings %>% 
  filter(apply_start > "2019-09-06" & apply_start < "2020-3-1") %>%
  group_by(employer_industry_name) %>%
  summarize(n_before=n(), avg_before = n()/177) 
pop_idus_before <- pop_idus_before %>% arrange(desc(n))

pop_idus_after <- postings %>% 
  filter(apply_start > "2020-3-1" & apply_start < "2020-4-19") %>%
  group_by(employer_industry_name) %>%
  summarize(n_after=n(), avg_after = n()/49) 
pop_idus_after <- pop_idus_after %>% arrange(desc(n))

before_after <- merge(pop_idus_before, pop_idus_after, by= c("employer_industry_name","employer_industry_name" ), all=TRUE)

before_after <- before_after %>% mutate(avg_change = avg_after-avg_before)

before_after <- before_after %>% arrange(desc(avg_change))

before_after_plot <- ggplot(before_after, aes(x=employer_industry_name, y=avg_change)) +
  geom_col()

before_after_plot <- before_after_plot +  theme(axis.text.x = element_text(angle = 90))


#TO DO: should  change the avg cahng graph to a % change 


