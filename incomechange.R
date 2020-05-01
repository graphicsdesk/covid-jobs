library(readr)
cleansc <- read_csv("cleanscorecarddata.csv", 
                    col_types = cols(X1 = col_character()))

library(tidyverse)

cleanscTight <- cleansc %>% gather(key="grad_year", value="mean_income", `2007`:`2013`)

ggplot(cleanscTight, aes(fill=grad_year, y=mean_income, x=X1)) +
  geom_bar(position="dodge", stat="identity") 

cleanscTight$X1 <- gsub('MN_EARN_WNE_P', '', cleanscTight$X1)  
cleanscTight$X1 <- as.numeric(as.character(cleanscTight$X1))
