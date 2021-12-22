
## EDA

# O objetivo é prever a variância nos preços entre diferentes permissões dependendo do cenário simulado.

# Carregar pacotes
library(tidyverse)
library(tidymodels)

drones <- read_csv("dados/warmupv4publictrain.csv") 

drones %>% skimr::skim()

# EDA Base
drones$sd_trans %>% boxplot()

drones %>% DataExplorer::plot_intro()
drones %>% DataExplorer::plot_histogram(nrow = 6, ncol = 4)
drones %>% DataExplorer::plot_bar()
drones %>% DataExplorer::plot_missing()

## Relação Agentes x Variação
boxplot(
  drones$sd_trans ~ drones$agents,
  ylab = 'Variação das transações',
  xlab = 'Agentes',
  col = '#40E0D0'
)

# Correlação
drones %>% 
  select_if(., is.numeric) %>% 
  na.omit() %>% cor() %>% 
  DataExplorer::plot_correlation(title = "Correlação")

# Pré Processamento 
reg_recipe <- recipe(sd_trans ~ ., data = df_train) %>%
  step_select(-b1,-b2,-b3,-a4,-l1,-l2) %>% 
  step_mutate(altitute = as.factor(altitute),
              agents   = if_else(agents == '50+', 'Ate 50', 'Mais 50') %>% as.factor()) %>%
  step_impute_knn(all_numeric()) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_impute_mode(altitute,agents) %>% 
  step_dummy(altitute,agents) 

drones_pre <- juice(prep(reg_recipe))

# EDA dados transaformados 
drones_pre %>% DataExplorer::plot_histogram(nrow = 6, ncol = 4)
drones_pre %>% DataExplorer::plot_bar()
drones_pre %>% DataExplorer::plot_prcomp()

drones %>%
  ggplot(aes(x = log(a1) , y = log(sd_trans))) +
  geom_point()

#