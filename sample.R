---
title: "R Notebook"
output: html_notebook
---

This is an [R Markdown](http://rmarkdown.rstudio.com) Notebook. When you execute code within the notebook, the results appear beneath the code. 

Try executing this chunk by clicking the *Run* button within the chunk or by placing your cursor inside it and pressing *Ctrl+Shift+Enter*. 

```{r}
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
```
```{r}
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
```

Add a new chunk by clicking the *Insert Chunk* button on the toolbar or by pressing *Ctrl+Alt+I*.

When you save the notebook, an HTML file containing the code and output will be saved alongside it (click the *Preview* button or press *Ctrl+Shift+K* to preview the HTML file).

The preview shows you a rendered HTML copy of the contents of the editor. Consequently, unlike *Knit*, *Preview* does not run any R code chunks. Instead, the output of the chunk when it was last run in the editor is displayed.
```{r}
tab_sum = postings %>% group_by(apply_start) %>%
  filter(remote, apply_start > "2019-09-06" & apply_start < "2020-04-19" ) %>%
  summarise(trues = n()) 

ggplot(tab_sum, aes(apply_start, trues)) + 
  geom_col(alpha = 0.3) +  geom_line(aes(y = rollmean(trues, 7, na.pad = TRUE), color = 'black'))
  
```


```{r}
tab_sum = postings %>% group_by(apply_start) %>%
  filter(apply_start > "2019-09-06" & apply_start < "2020-04-19" ) %>%
  summarise(totals = n()) 
tab_sum2 = tab_sum %>% group_by(apply_start) %>%
  filter(remote) %>%
  summarise(trues = n(), true_percent = (totals/n()*100)) 

ggplot(tab_sum, aes(apply_start, trues)) + 
  geom_col(alpha = 0.3) +  geom_line(aes(y = rollmean(trues, 7, na.pad = TRUE), color = 'black'))
  
```
```

