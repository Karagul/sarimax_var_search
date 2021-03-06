source('./R/utils_av.R')
library(ggthemes)

country_name <- "Chile"

# Optional: Estimate (and Save) new Arimax RDS file

# final_forecast_horizon <- c(2020, 12)
# h_max = 8 # last rgdp data is 2017 Q4
# number_of_cv = 8
# train_span = 16
# arima_res2 <- get_arima_results(country_name = country_name, h_max = 8,
#                                number_of_cv = 8, train_span = 16,
#                                final_ext_horizon = final_forecast_horizon)

# Run Saved ARimax RDS File
arima_res <- get_arima_results(country_name = country_name, read_results = TRUE)

extended_x_data_ts <- arima_res$mdata_ext_ts
rgdp_ts_in_arima <- arima_res$rgdp_ts_in_arima

########################## IMPORT ARIMAX AND VAR FILES #############################
# Automatically imports the data matching the country_name
path_models_and_accu <- paste("./data/", country_name, "_by_step_12345.rds", sep = "")
path_cv_objects <- paste("./data/", country_name, "_by_step_12345_cv_objects.rds", sep = "")
path_VAR_data <- paste("./data/VAR_data_", country_name, ".rds", sep = "")
models_and_accu <- readRDS(path_models_and_accu)
cv_objects <- readRDS(path_cv_objects)
VAR_data <- readRDS(path_VAR_data)

h_max <- 8


# Get the table with all models from both the VARs and ARIMAX
models_tbl <- make_models_tbl(
  arima_res = arima_res, var_models_and_rmse = models_and_accu, 
  VAR_data = VAR_data, h_max = h_max)

models_tbl <- models_tbl %>%
  mutate(short_name = map2_chr(variables, lags,
                           ~ make_model_name(variables = .x, lags = .y)),
         long_name = pmap_chr(list(variables, lags, model_function),
                          ~ make_model_name(variables = ..1, lags = ..2,
                                            model_function = ..3)),
         short_name = as_factor(unlist(short_name)),
         long_name = as_factor(unlist(long_name))
  ) 

# ssel stands for "stata_selection" and what it does it to imitate stata-style selection 
models_tbl_ssel <- make_models_tbl(
  arima_res, var_models_and_rmse = models_and_accu, VAR_data = VAR_data,
  h_max = h_max, ave_rmse_sel = TRUE)

models_tbl_ssel <- models_tbl_ssel %>%
  mutate(short_name = map2_chr(variables, lags,
                           ~ make_model_name(variables = .x, lags = .y)),
         long_name = pmap_chr(list(variables, lags, model_function),
                          ~ make_model_name(variables = ..1, lags = ..2,
                                            model_function = ..3))
  ) 



cv_from_models_tbl <- function(VAR_data, rgdp_ts_in_arima, tbl_of_models_and_rmse,
                               h, max_rank_h, test_length = NULL, training_span = 20,
                               n_cv = 10) {
  
  if (is.null(test_length)) {
    test_length <- h
  }
  
  cv_errors_list = list()
  

  len_var_data <- nrow(VAR_data)
  len_arima_data <- length(rgdp_ts_in_arima)
  
  max_fixed_span_for_training <- min(len_var_data, len_arima_data) - n_cv - test_length + 1
  
  
  print(paste("Obs in VAR:", len_var_data))
  print(paste("Obs in Arima:", len_arima_data))
  print(paste("Obs in train set:", training_span))
  print(paste("Obs in test set:", test_length))
  print(paste("CV samples:", n_cv))
  print(paste("Max size of fixed training span :", max_fixed_span_for_training))
  
  
  for (i in 1:n_cv) {
    
    print(paste("Starting CV step", i, "of", n_cv))
    print("")

    var_train_end <- len_var_data - test_length - i + 1
    
    if (is.null(training_span)) {
      training_VAR_data <- subset(VAR_data, end = var_train_end)
    } else {
      training_VAR_data <- subset(VAR_data, end = var_train_end, 
                                  start = var_train_end - training_span + 1)

      # print(var_train_end - training_span + 1)
    }
    
    test_VAR_data <- subset(VAR_data, start = var_train_end + 1,
                            end = var_train_end + test_length)

    test_VAR_data <- test_VAR_data[, "rgdp"]
    
    arima_train_end <- len_arima_data - test_length - i + 1

    
    if (is.null(training_span)) {
      training_arima_data <- subset(rgdp_ts_in_arima, end = arima_train_end)
    } else {
      training_arima_data <- subset(rgdp_ts_in_arima, end = arima_train_end,
                                    start = arima_train_end - training_span + 1)
    }
    
    test_arima_data <- subset(rgdp_ts_in_arima, start = arima_train_end + 1,
                              end = arima_train_end + test_length)

    
    separate_fcs <- indiv_weigthed_fcs(tbl_of_models_and_rmse = tbl_of_models_and_rmse,
                                       h = h,
                                       extended_x_data_ts = extended_x_data_ts, 
                                       rgdp_ts_in_arima = training_arima_data, 
                                       max_rank_h = max_rank_h,
                                       var_data = training_VAR_data)
    
    ensemble_fcs <- separate_fcs %>%
      group_by(horizon) %>%
      summarise(sum_one_h = reduce(one_model_w_fc, sum))
    
    ensemble_fcs_ts <- ts(ensemble_fcs$sum_one_h, 
                          start = start(test_VAR_data), 
                          frequency = 4)

    ensemble_cv_errors <-  test_VAR_data - ensemble_fcs_ts 
    
    cv_errors_list[[i]] <- ensemble_cv_errors

  }
  
  # rows are cv trials and columns are forecast horizons
  matrix_of_cv_errors <- reduce(cv_errors_list, rbind)
  dimnames(matrix_of_cv_errors) <- NULL
  # matrix_of_cv_errors
  rmse_all_h <- sqrt(colMeans(matrix_of_cv_errors^2))
  mae_all_h <- colMeans(abs(matrix_of_cv_errors))
  
  return(list(cv_errors_list = cv_errors_list,
              matrix_of_cv_errors = matrix_of_cv_errors,
              rmse_all_h = rmse_all_h,
              mae_all_h = mae_all_h))
  
  
}

foo <- cv_from_models_tbl(VAR_data = VAR_data, rgdp_ts_in_arima = rgdp_ts_in_arima,
                          tbl_of_models_and_rmse = models_tbl,
                          h = h_max, max_rank_h = 20, test_length = NULL, 
                          training_span = 20, n_cv = 16)


foo$rmse_all_h
foo$matrix_of_cv_errors


table_of_models_and_rmse <- models_tbl_ssel
h <-  h_max
test_length <-  8
max_rank_h <-  10
n_cv <- 16

if (is.null(test_length)) {
  test_length <- h
}

cv_errors_list = list()

training_span <- 20

len_var_data <- nrow(VAR_data)
len_arima_data <- length(rgdp_ts_in_arima)

# print("len_arima_data")
# print(len_arima_data)
# print("len_var_data")
# print(len_var_data)


for (i in 1:n_cv) {
  # print(paste("cv set number", i))
  
  var_train_end <- len_var_data - test_length - i + 1
  # print("var_train_end")
  # print(var_train_end)
  
  if (is.null(training_span)) {
    training_VAR_data <- subset(VAR_data, end = var_train_end)
  } else {
    training_VAR_data <- subset(VAR_data, end = var_train_end, 
                                start = var_train_end - training_span + 1)
    # print("var_train_start")
    print(var_train_end - training_span + 1)
  }
  
  test_VAR_data <- subset(VAR_data, start = var_train_end + 1,
                          end = var_train_end + test_length)
  
  # print("nrow(training_VAR_data)")
  # print(nrow(training_VAR_data))
  # 
  # print("nrow(test_VAR_data)")
  # print(nrow(test_VAR_data))
  
  test_VAR_data <- test_VAR_data[, "rgdp"]
  
  arima_train_end <- len_arima_data - test_length - i + 1
  # print("arima_train_end")
  # print(arima_train_end)
  
   
  if (is.null(training_span)) {
    training_arima_data <- subset(rgdp_ts_in_arima, end = arima_train_end)
  } else {
    training_arima_data <- subset(rgdp_ts_in_arima, end = arima_train_end,
                                start = arima_train_end - training_span + 1)
  }
  
  test_arima_data <- subset(rgdp_ts_in_arima, start = arima_train_end + 1,
                            end = arima_train_end + test_length)

  # print("length(training_arima_data)")  
  # print(length(training_arima_data))  
  # 
  # print("length(test_arima_data)")  
  # print(length(test_arima_data))  
  # 
  # print(test_VAR_data)
  # print(test_arima_data)
  
  separate_fcs <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl_ssel, h = h_max,
                            extended_x_data_ts = extended_x_data_ts, 
                            rgdp_ts_in_arima = training_arima_data, 
                            max_rank_h = 20, var_data = training_VAR_data)
  
  ensemble_fcs <- separate_fcs %>%
    group_by(horizon) %>%
    summarise(sum_one_h = reduce(one_model_w_fc, sum))
  
  ensemble_fcs_ts <- ts(ensemble_fcs$sum_one_h, 
     start = start(test_VAR_data), 
     frequency = 4)
  
  # print("ensemble_fcs_ts")
  # print(ensemble_fcs_ts)
  # 
  # print("test_VAR_data")
  # print(test_VAR_data)
  
  
  ensemble_cv_errors <-  test_VAR_data - ensemble_fcs_ts 
  
  cv_errors_list[[i]] <- ensemble_cv_errors

  # 
  # cv_errors <- rgdp_test_data - summ_comb_fcs_ssel_best_20$fcs
  # 
  # cv_errors_list[[i]] <- cv_errors 
  
}

# rows are cv trials and columns are forecast horizons
matrix_of_cv_errors <- reduce(cv_errors_list, rbind)
dimnames(matrix_of_cv_errors) <- NULL
# matrix_of_cv_errors
rmse_all_h <- sqrt(colMeans(matrix_of_cv_errors^2))
mae_all_h <- colMeans(abs(matrix_of_cv_errors))




################################### In Sample Accuracy Comparison ################################

# I feel like, before going into the out of sample performance (i.e the forecasts), we should come up
# with a nice way of presenting the in sample performance of the individual models and the combined models. 
# We should produce a nice table and graphs (maybe the in sample forecasts in levels vis-a-vis realized level values) 
# that show the rmse's (from the cross-validation exercise) of the combined and individual models at each h. 
# Once we have a good idea about the VAR and ARIMAX in sample performance 
# it is time to look at the out of sample performance, i.e. the actual forecasts. 


# VAR_co_1 <- cv_objects[1,]
# td_1 <-  VAR_co_1$cv_test_data

######################################## Forecasts VARs ##########################################
# First have a look at the VAR models
ffall_VAR <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl,
                                h = h_max, extended_x_data_ts = extended_x_data_ts,
                                rgdp_ts_in_arima = rgdp_ts_in_arima,
                                model_type = "VAR", max_rank_h = 30)




summ_all_VAR <- ffall_VAR %>% 
  group_by(horizon) %>%
  summarise(sum_one_h = reduce(one_model_w_fc, sum))

ffall_VAR_10 <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl,
                                   h = h_max, extended_x_data_ts = extended_x_data_ts,
                                   rgdp_ts_in_arima = rgdp_ts_in_arima,
                                   model_type = "VAR", max_rank_h = 10)

summ_all_VAR_10 <- ffall_VAR_10 %>% 
  group_by(horizon) %>%
  summarise(sum_one_h = reduce(one_model_w_fc, sum))

ffall_VAR_5 <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl,
                                  h = h_max, extended_x_data_ts = extended_x_data_ts,
                                  rgdp_ts_in_arima = rgdp_ts_in_arima,
                                  model_type = "VAR", max_rank_h = 5)

summ_all_VAR_5 <- ffall_VAR_5 %>% 
  group_by(horizon) %>%
  summarise(sum_one_h = reduce(one_model_w_fc, sum))

ffall_VAR_15 <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl,
                                   h = h_max, extended_x_data_ts = extended_x_data_ts,
                                   rgdp_ts_in_arima = rgdp_ts_in_arima,
                                   model_type = "VAR", max_rank_h = 15)

summ_all_VAR_15 <- ffall_VAR_15 %>% 
  group_by(horizon) %>%
  summarise(sum_one_h = reduce(one_model_w_fc, sum))

ffall_VAR_20 <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl,
                                   h = h_max, extended_x_data_ts = extended_x_data_ts,
                                   rgdp_ts_in_arima = rgdp_ts_in_arima,
                                   model_type = "VAR", max_rank_h = 20)

summ_all_VAR_20 <- ffall_VAR_20 %>% 
  group_by(horizon) %>%
  summarise(sum_one_h = reduce(one_model_w_fc, sum))

rgdp_var <- VAR_data[ ,1]
# autoplot(rgdp_var)

start_ts_fcs_var_year <- year(as.yearqtr(last(time(rgdp_var)))) # use year from lubridate. Time gives you the time like 2017.5 etc
# last gives you the last observation. as.yearqtr turns it into 2017 Q3 form and year gives the year
start_ts_fcs_var_qtr <- quarter(as.yearqtr(last(time(rgdp_var)))) # use quarter from lubridate

# add an extra row with horizon = 0 and sum_one_h is the last observation of rgdp_var
summ_all_VAR_5 <- summ_all_VAR_5 %>% add_row(horizon = 0, sum_one_h = last(rgdp_var)) %>% arrange(horizon)
summ_all_VAR_10 <- summ_all_VAR_10 %>% add_row(horizon = 0, sum_one_h = last(rgdp_var)) %>% arrange(horizon)
summ_all_VAR_15 <- summ_all_VAR_15 %>% add_row(horizon = 0, sum_one_h = last(rgdp_var)) %>% arrange(horizon)
summ_all_VAR_20 <- summ_all_VAR_20 %>% add_row(horizon = 0, sum_one_h = last(rgdp_var)) %>% arrange(horizon)

fcs_var_ts_best5 <- ts(data = summ_all_VAR_5$sum_one_h, frequency = 4, start = c(start_ts_fcs_var_year, start_ts_fcs_var_qtr))
fcs_var_ts_best10 <- ts(data = summ_all_VAR_10$sum_one_h, frequency = 4, start = c(start_ts_fcs_var_year, start_ts_fcs_var_qtr))
fcs_var_ts_best15 <- ts(data = summ_all_VAR_15$sum_one_h, frequency = 4, start = c(start_ts_fcs_var_year, start_ts_fcs_var_qtr))
fcs_var_ts_best20 <- ts(data = summ_all_VAR_20$sum_one_h, frequency = 4, start = c(start_ts_fcs_var_year, start_ts_fcs_var_qtr))

rgdp_var_and_fcs <- ts.union(rgdp_var, fcs_var_ts_best5, fcs_var_ts_best10, fcs_var_ts_best15, fcs_var_ts_best20)

plot_vars_title <- paste("GDP Forecasts Best VARs", country_name, sep = " ")
filename_var_plot <- paste(plot_vars_title, "png", sep = ".")
# directory_var_plot <- paste("./Plots", filename_var_plot, sep = "/")
plots_path = paste("./Plots/", country_name, "/", sep = "")

forecast_plot_best_vars <- autoplot(rgdp_var) + 
  autolayer(fcs_var_ts_best5, series="Best 5 VARs") + 
  autolayer(fcs_var_ts_best10, series="Best 10 VARs") +
  autolayer(fcs_var_ts_best15, series="Best 15 VARs") +
  autolayer(fcs_var_ts_best20, series="Best 20 VARs") +
  ggtitle(plot_vars_title) +
  xlab("Year") +
  ylab("Real GDP Growth YoY (%)") +
  guides(colour=guide_legend(title="Time-Series:"))

ggsave(filename = filename_var_plot, path = plots_path)

############################ Forecasts Arimax ##############################
# Second, have a look at the ARIMAX models
# Transform rgdp series from log level to yoy
rgdp_arimax <- make_yoy_ts(exp(rgdp_ts_in_arima))

arimax_fcs_all <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl,
                                  h = h_max, extended_x_data_ts = extended_x_data_ts,
                                  rgdp_ts_in_arima = rgdp_ts_in_arima,
                                  model_type = "Arima")

summ_arimax_fcs_all <- arimax_fcs_all %>%
  group_by(horizon) %>%
  summarise(sum_one_h = reduce(one_model_w_fc, sum))

arimax_fcs_all_ssel <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl_ssel,
                                       h = h_max, extended_x_data_ts = extended_x_data_ts,
                                       rgdp_ts_in_arima = rgdp_ts_in_arima,
                                       model_type = "Arima")

summ_arimax_fcs_all_ssel <- arimax_fcs_all_ssel %>% 
  group_by(horizon) %>%
  summarise(sum_one_h = reduce(one_model_w_fc, sum))

# I leave arimax_best_20 out because somehow horizon 5 drops out and i do not know why

# arimax_fcs_best_20 <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl,
#                                               h = h_max, extended_x_data_ts = extended_x_data_ts,
#                                               rgdp_ts_in_arima = rgdp_ts_in_arima,
#                                               model_type = "Arima", max_rank_h = 20)
# 
# summ_arimax_fcs_best_20 <- arimax_fcs_best_20 %>% 
#   group_by(horizon) %>%
#   summarise(sum_one_h = reduce(one_model_w_fc, sum))
# 
# arimax_fcs_ssel_best_20 <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl_ssel,
#                                        h = h_max, extended_x_data_ts = extended_x_data_ts,
#                                        rgdp_ts_in_arima = rgdp_ts_in_arima,
#                                        model_type = "Arima", max_rank_h = 20)
# 
# summ_arimax_fcs_ssel_best_20 <- arimax_fcs_ssel_best_20 %>% 
#   group_by(horizon) %>%
#   summarise(sum_one_h = reduce(one_model_w_fc, sum))

# select similar start date for rgdp_arimax as for rgdp_var so that graph is comparable
# first_year_var_ts is used to set the start of arimax series equal to the var series. Besides that we do not use it
first_year_var_ts <- year(as.yearqtr(first(time(rgdp_var))))
first_qtr_var_ts <- quarter(as.yearqtr(first(time(rgdp_var))))
# rgdp_arimax <- window(rgdp_arimax, start = c(first_year_var_ts, first_qtr_var_ts))

start_ts_fcs_arimax_year <- year(as.yearqtr(last(time(rgdp_arimax)))) 
start_ts_fcs_arimax_qtr <- quarter(as.yearqtr(last(time(rgdp_arimax))))

# summ_all_20 add an extra row with horizon = 0 and sum_one_h is the last observation of rgdp_arimax
summ_arimax_fcs_all <- summ_arimax_fcs_all %>% add_row(horizon = 0, sum_one_h = last(rgdp_arimax)) %>% arrange(horizon)
# summ_arimax_fcs_best_20 <- summ_arimax_fcs_best_20 %>% add_row(horizon = 0, sum_one_h = last(rgdp_arimax)) %>% arrange(horizon)
summ_arimax_fcs_all_ssel <- summ_arimax_fcs_all_ssel %>% add_row(horizon = 0, sum_one_h = last(rgdp_arimax)) %>% arrange(horizon)
# summ_arimax_fcs_ssel_best_20 <- summ_arimax_fcs_ssel_best_20 %>% add_row(horizon = 0, sum_one_h = last(rgdp_arimax)) %>% arrange(horizon)

fcs_all_arimax_ts <- ts(data = summ_arimax_fcs_all$sum_one_h, frequency = 4, start = c(start_ts_fcs_arimax_year, start_ts_fcs_arimax_qtr))
# fcs_best_20_arimax_ts <- ts(data = summ_arimax_fcs_best_20$sum_one_h, frequency = 4, start = c(start_ts_fcs_arimax_year, start_ts_fcs_arimax_qtr))
fcs_all_arimax_ssel_ts <- ts(data = summ_arimax_fcs_all_ssel$sum_one_h, frequency = 4, start = c(start_ts_fcs_arimax_year, start_ts_fcs_arimax_qtr))
# fcs_best_20_arimax_ssel_ts <- ts(data = summ_arimax_fcs_ssel_best_20$sum_one_h, frequency = 4, start = c(start_ts_fcs_arimax_year, start_ts_fcs_arimax_qtr))

end_ts_fcs_var_year <- year(as.yearqtr(last(time(fcs_all_arimax_ts)))) 
end_ts_fcs_var_qtr <- quarter(as.yearqtr(last(time(fcs_all_arimax_ts)))) 

# Two ways to combine the time-series. 1) Use autolayer, which adds a layer to an existing plot, or 2) ts.union the time-series and then plot them
plot_arimax_title <- paste("GDP Forecasts Best ARIMAX", country_name, sep = " ")
filename_arimax_plot <- paste(plot_arimax_title, "png", sep = ".")

forecast_plot_best_arimax <- autoplot(window(rgdp_arimax, start = c(first_year_var_ts, first_qtr_var_ts), end = c(end_ts_fcs_var_year, end_ts_fcs_var_qtr))) + 
  autolayer(fcs_all_arimax_ts, series="Best 30 ARIMAX") +
  # autolayer(fcs_best_20_arimax_ts, series="Best 20 ARIMAX") +
  autolayer(fcs_all_arimax_ssel_ts, series="Best 30 ARIMAX Stata Selection") +
  # autolayer(fcs_best_20_arimax_ssel_ts, series="Best 20 ARIMAX Stata Selection") + 
  ggtitle(plot_arimax_title) +
  xlab("Year") +
  ylab("Real GDP Growth YoY (%)") +
  guides(colour=guide_legend(title="Time-Series:"))

ggsave(filename = filename_arimax_plot, path = plots_path)

# forecast_plot_best_arimax

rgdp_arimax_and_fcs <- ts.union(rgdp_arimax, fcs_all_arimax_ts, fcs_all_arimax_ssel_ts)
# rgdp_arimax_and_fcs <- ts.union(rgdp_arimax, fcs_all_arimax_ts, fcs_best_20_arimax_ts, fcs_all_arimax_ssel_ts, fcs_best_20_arimax_ssel_ts)
rgdp_var_and_arimax_fcs <- ts.union(rgdp_var_and_fcs, rgdp_arimax_and_fcs)

plot_vars_arimax_title <- paste("GDP Forecasts Best VARs and ARIMAX", country_name, sep = " ")
filename_vars_arimax_plot <- paste(plot_vars_arimax_title, "png", sep = ".")

# png(filename = directory_var_arimax_plot)

#find a way to make this generic for all countries. Use paste function. "GDP Forecast Best VARs and ARIMAX: Chile"
forecast_plot_best_vars_arimax <- autoplot(window(rgdp_arimax, start = c(first_year_var_ts, first_qtr_var_ts), end = c(end_ts_fcs_var_year, end_ts_fcs_var_qtr))) + 
  autolayer(fcs_all_arimax_ts, series="Best 30 ARIMAX") + 
  autolayer(fcs_all_arimax_ssel_ts, series="Best 30 ARIMAX Stata Selection") +
  autolayer(fcs_var_ts_best20, series="Forecasts Best 20 VARs") +
  autolayer(fcs_var_ts_best5, series="Forecasts Best 5 VARs") +
  ggtitle(plot_vars_arimax_title) +
  xlab("Year") +
  ylab("Real GDP Growth YoY (%)") +
  guides(colour=guide_legend(title="Time-Series:"))

ggsave(filename = filename_vars_arimax_plot, path = plots_path)

##################################### FORECASTS OF VARs AND ARIMAX COMBINED ##################################

# Get the best Forecasts out of all Models: all VARs and all ARIMAX
comb_fcs_all <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl,
                            h = h_max, extended_x_data_ts = extended_x_data_ts,
                            rgdp_ts_in_arima = rgdp_ts_in_arima,
                            max_rank_h = 30)



number_of_models_per_h <- comb_fcs_all %>% group_by(horizon) %>% 
  summarise(n_models = n(), 
            n_VAR = sum(model_function == "VAR"),
            n_ARIMA = sum(model_function == "Arima")
  )

number_of_models_per_h

rmse_plot_all_h <- single_plot_rmse_all_h(comb_fcs_all)
print(rmse_plot_all_h)

facet_rmse_plot_all_h <- facet_rmse_all_h(comb_fcs_all)
print(facet_rmse_plot_all_h)

rmse_plots_list <- list_of_rmse_plots(comb_fcs_all)
walk(rmse_plots_list, print)




# Average Forecasts of all models (all models are the best 30 at each h)
summ_comb_fcs_all <- comb_fcs_all %>% 
  group_by(horizon) %>%
  summarise(sum_one_h = reduce(one_model_w_fc, sum))

comb_fcs_all_ssel <- indiv_weigthed_fcs(tbl_of_models_and_rmse = models_tbl_ssel,
                                 h = h_max, extended_x_data_ts = extended_x_data_ts,
                                 rgdp_ts_in_arima = rgdp_ts_in_arima,
                                 max_rank_h = 30)

number_of_models_per_h_ssel <- comb_fcs_all_ssel %>% group_by(horizon) %>% 
  summarise(n_models = n(), 
            n_VAR = sum(model_function == "VAR"),
            n_ARIMA = sum(model_function == "Arima")
  )

number_of_models_per_h_ssel

summ_comb_fcs_all_ssel <- comb_fcs_all_ssel %>% 
  group_by(horizon) %>%
  summarise(sum_one_h = reduce(one_model_w_fc, sum))

# for consistency with stata i focus on ssel method


# summ_all_20 add an extra row with horizon = 0 and sum_one_h is the last observation of rgdp_var
summ_comb_fcs_all_ssel <- summ_comb_fcs_all_ssel %>% add_row(horizon = 0, sum_one_h = last(rgdp_var)) %>% arrange(horizon)
summ_comb_fcs_ssel_best_20  <- summ_comb_fcs_ssel_best_20  %>% add_row(horizon = 0, sum_one_h = last(rgdp_var)) %>% arrange(horizon)


# note that i usee the arimax summary now, i should replace that for VAR
fcs_combined_models <- ts(data = summ_comb_fcs_all_ssel$sum_one_h, frequency = 4, start = c(start_ts_fcs_var_year, start_ts_fcs_var_qtr))
fcs_combined_models_best_20 <- ts(data = summ_comb_fcs_ssel_best_20$sum_one_h, frequency = 4, start = c(start_ts_fcs_var_year, start_ts_fcs_var_qtr))
# rgdp_and_combined_fcs <- ts.union(rgdp_var, fcs_var_ts_best5, fcs_var_ts_best10, fcs_var_ts_best15, fcs_var_ts_best20)

# IMPORTANT:
# We have to insert here the way of combining negatively correlated models with the best models
# then we can graph how this way of combining models performs

plot_combined_models_title <- paste("GDP Forecasts Combined Models", country_name, sep = " ")
filename_combined_models_plot <- paste(plot_combined_models_title, "png", sep = ".")

forecast_plot_best_vars <- autoplot(rgdp_var) + 
  autolayer(fcs_var_ts_best5, series="Best 5 VARs") + 
  autolayer(fcs_all_arimax_ssel_ts, series="Best 30 ARIMAX Stata Selection") +
  autolayer(fcs_combined_models, series="Best 30 Combined Models Stata Selection") +
  autolayer(fcs_combined_models_best_20, series="Best 20 Combined Models Stata Selection") +
  autolayer(fcs_var_ts_best20, series="Best 20 VARs") +
  ggtitle(plot_combined_models_title) +
  xlab("Year") +
  ylab("Real GDP Growth YoY (%)") +
  guides(colour=guide_legend(title="Time-Series:"))

ggsave(filename = filename_combined_models_plot, path = plots_path)


################################### Forecasts Tables #####################################
# We have to create a nice table or graph with the different forecasts produced
# What I have here could be a decent starting point
all_fcs <- ts.union(fcs_var_ts_best5, fcs_var_ts_best10, fcs_var_ts_best15, 
                    fcs_var_ts_best20, fcs_all_arimax_ts, fcs_all_arimax_ssel_ts, fcs_combined_models,
                    fcs_combined_models_best_20)

Economic_Growth_2018_best_5_vars <- mean(all_fcs[2:5, 1]); Economic_Growth_2018_best_5_vars
Economic_Growth_2018_best_10_vars <- mean(all_fcs[2:5, 2]); Economic_Growth_2018_best_10_vars
Economic_Growth_2018_best_15_vars <- mean(all_fcs[2:5, 3]); Economic_Growth_2018_best_15_vars
Economic_Growth_2018_best_20_vars <- mean(all_fcs[2:5, 4]); Economic_Growth_2018_best_20_vars
Economic_Growth_2018_best_30_arimax <- mean(all_fcs[2:5, 5]); Economic_Growth_2018_best_30_arimax
Economic_Growth_2018_best_30_arimax_ssel <- mean(all_fcs[2:5, 6]); Economic_Growth_2018_best_30_arimax_ssel
Economic_Growth_2018_best_30_combined_models <- mean(all_fcs[2:5, 7]); Economic_Growth_2018_best_30_combined_models
Economic_Growth_2018_best_20_combined_models <- mean(all_fcs[2:5, 8]); Economic_Growth_2018_best_20_combined_models

Economic_growth_2018_tibble <- tibble(Economic_Growth_2018_best_5_vars, Economic_Growth_2018_best_10_vars, 
                               Economic_Growth_2018_best_15_vars, Economic_Growth_2018_best_20_vars,
                               Economic_Growth_2018_best_30_arimax, Economic_Growth_2018_best_30_arimax_ssel,
                               Economic_Growth_2018_best_20_combined_models, Economic_Growth_2018_best_30_combined_models)

