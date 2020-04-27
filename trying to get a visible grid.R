
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
do.call("grid.arrange", c(p, ncol=nCol))

