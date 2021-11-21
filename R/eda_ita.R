
## EDA

# Carregar pacotes
library(tidyverse)

df <- read_csv("dados/warmupv4publictest.csv")

# Conhecendo os dados
glimpse(df)
skimr::skim(df)

df %>% DataExplorer::plot_histogram()
df %>% select_if(., is.numeric) %>% 
  DataExplorer::plot_correlation()

# Obs: tratar os NA's

