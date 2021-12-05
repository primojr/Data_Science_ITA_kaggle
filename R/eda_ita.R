
## EDA

# O objetivo é prever a variância nos preços entre diferentes permissões dependendo do cenário simulado.

# Carregar pacotes
library(tidyverse)
library(tidymodels)

df <- read_csv("dados/warmupv4publictrain.csv")

# Conhecendo os dados
glimpse(df)
skimr::skim(df)

df %>% DataExplorer::plot_histogram(nrow = 6, ncol = 4)

df |> DataExplorer::plot_bar()


df |> DataExplorer::plot_bar(by = "altitute")

df %>% select_if(., is.numeric) %>% 
  DataExplorer::plot_correlation()

# Obs: tratar os NA's

is.na(df) %>% colSums()
