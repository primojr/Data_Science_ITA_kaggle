## 
# Teste com outros algoritimos

library(tidymodels)
library(tidyverse)
library(ranger)


# Ler Base

# 01.Splits
df_train <- read_csv("dados/warmupv4publictrain.csv")
glimpse(df_train)

df_train %>% skimr::skim()

# 00. EDA Base
df_train$sd_trans %>% boxplot()

df_train %>% DataExplorer::plot_intro()
df_train %>% DataExplorer::plot_histogram(nrow = 6,ncol = 4)
df_train %>% DataExplorer::plot_bar()
df_train %>% DataExplorer::plot_missing()

## 01. Relação Agentes x Variação
boxplot(df_train$sd_trans ~ df_train$agents
        ,ylab = 'Variação das transações'
        ,xlab = 'Agentes'
        ,col = '#40E0D0')


# 01 Pré Processamento
reg_recipe <- recipe(sd_trans ~ ., data = df_train) %>%
  step_select(-b1,-b2,-b3,-a4,-l1,-l2) %>% 
  step_mutate(altitute = as.factor(altitute),
              agents   = if_else(agents == '50+', 'Ate 50', 'Mais 50') %>% as.factor()) %>%
  step_impute_knn(all_numeric()) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_dummy(altitute,agents)
#step_corr(all_numeric_predictors(), threshold = .8, method = "pearson")
#juice(prep(reg_recipe)) 

# 04. Engine
reg_mod <- linear_reg(penalty = tune(), mixture = tune()) %>% 
  set_engine("glmnet") %>% 
  set_mode("regression")

# 05. Workflow
reg_workflow <- workflow() %>% 
  add_model(reg_mod) %>% 
  add_recipe(reg_recipe)

# 06.Cross validation
val_set <- vfold_cv(df_train, v = 4, strata = sd_trans)

# 07.trainning
reg_trained <- reg_workflow %>% 
  tune_grid(
    val_set,
    grid = 5,
    control = control_grid(save_pred = TRUE),
    metrics = metric_set(rmse)
  )

reg_trained %>% show_best()

# autoplot
ggplot2::autoplot(reg_trained)

 # selecaop
reg_best_tune <- select_best(reg_trained, "rmse")
final_reg_model <- reg_mod %>%
finalize_model(reg_best_tune)


final_reg_model$eng_args

workflow() %>%
  add_recipe(reg_recipe) %>%
  add_model(final_reg_model) %>%
  collect_predictions() %>%
  select(.row, price, .pred) %>%
  ggplot() +
  aes(x= price, y = .pred) +
  geom_point()

# # save the results
# reg_fitted <- workflow() %>% 
#   add_recipe(reg_recipe) %>% 
#   add_model(final_reg_model) %>% 
#   fit(NOME)   
