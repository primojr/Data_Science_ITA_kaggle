
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
df %>%  DataExplorer::plot_bar()

# Correlação
df %>% 
  select_if(., is.numeric) %>% 
  na.omit() %>% 
  DataExplorer::plot_correlation(title = "Correlação")


# Fazer tratamento dos dados 
