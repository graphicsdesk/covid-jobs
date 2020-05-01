library(readr)
status <- read_csv("Company Internship Data - Data_as_of 4-28.csv")


library(waffle)
library(tidyverse)

parts <- status %>% group_by(Status)%>% summarise(n = n())

waffle(parts, rows = 20, colors = c("#e41a1c", "#4daf4a", "white") )


storms %>% 
  filter(year >= 2010) %>% 
  count(year, status) -> storms_df

ggplot(storms_df, aes(fill = status, values = n)) +
  geom_waffle(color = "white", size = .25, n_rows = 10, flip = TRUE) +
  facet_wrap(~year, nrow = 1, strip.position = "bottom") +
  scale_x_discrete() + 
  scale_y_continuous(labels = function(x) x * 10, # make this multiplyer the same as n_rows
                     expand = c(0,0)) +

  coord_equal() +
  labs(
    title = "Faceted Waffle Bar Chart",
    subtitle = "{dplyr} storms data",
    x = "Year",
    y = "Count"
  ) +
  theme_minimal(base_family = "Roboto Condensed") +
  theme(panel.grid = element_blank(), axis.ticks.y = element_line()) +
  guides(fill = guide_legend(reverse = TRUE))


bar_status <- status %>% group_by(Status, Industry) %>% summarize(n = n()) 

bar_status_small <- bar_status %>% filter(n>4)

ggplot(bar_status_small, aes(fill = Status, values = n)) +
  geom_waffle(color = "white", size = .25, n_rows = 10, flip = TRUE) +
  facet_wrap(vars(Industry), nrow = 1, strip.position = "bottom") +
  scale_x_discrete() + 
  scale_y_continuous(labels = function(x) x * 10, # make this multiplyer the same as n_rows
                     expand = c(0,0)) +
  
  coord_equal() +
  labs(
    title = "Industry Breakdown",
    subtitle = "Hiring Status data",
    x = "Year",
    y = "Count"
  ) +
  theme_minimal(base_family = "Roboto Condensed") +
  theme(panel.grid = element_blank(), axis.ticks.y = element_line(), axis.text.x = element_text(angle = 90, hjust=1, vjust=0.5)) +
  guides(fill = guide_legend(reverse = TRUE)) 

