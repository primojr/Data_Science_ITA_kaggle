## 
# Teste com outros algoritimos

library(tidymodels)
library(tidyverse)
library(ranger)


# Ler Base

# 01.Splits
df_train <- read_csv("dados/warmupv4publictrain.csv")
glimpse(df_train)


# 00. EDA Arvore
df_train %>% DataExplorer::plot_histogram(nrow = 6,ncol = 4)


# 02.Pré processamento 
reg_recipe <- recipe(
  classe ~ . ,
  data = br_trainning
) %>% 
  step_impute_knn(all_predictors()) %>% 
  step_dummy(all_nominal_predictors())

# 04. Engine
reg_mod <- rand_forest(trees = tune()) %>% 
  set_engine("ranger")  %>% 
  set_mode("classification")

# 05. Workflow
reg_workflow <- workflow() %>% 
  add_model(reg_mod) %>% 
  add_recipe(reg_recipe)

# 06.Cross validation
val_set <- vfold_cv(br_trainning, v = 4, strata = classe)

# 07.trainning
reg_trained <- reg_workflow %>% 
  tune_grid(
    val_set,
    grid = 5,
    control = control_grid(save_pred = TRUE),
    metrics = metric_set(accuracy)
  )

reg_trained %>% show_best()

# autoplot
ggplot2::autoplot(reg_trained)

# see the magic
reg_best_tune <- select_best(reg_trained, "rmse")
final_reg_model <- reg_mod %>% 
  finalize_model(reg_best_tune)

workflow() %>% 
  add_recipe(reg_recipe) %>% 
  add_model(final_reg_model) %>% 
  last_fit(splits) %>% 
  collect_predictions() %>% 
  select(.row, price, .pred) %>% 
  ggplot() +
  aes(x= price, y = .pred) +
  geom_point()

# save the results
reg_fitted <- workflow() %>% 
  add_recipe(reg_recipe) %>% 
  add_model(final_reg_model) %>% 
  fit(computers)   
