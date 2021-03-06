source('./R/utils_av.R')

tic()
# preliminaries -----------------------------------------------------------

final_forecast_horizon <- c(2019, 12)
h_max = 8 # last rgdp data is 2017 Q4
number_of_cv = 8
train_span = 16

data_path <- "./data/excel/Chile.xlsx"

gdp_and_dates <- get_rgdp_and_dates(data_path)

monthly_data <- get_monthly_variables(data_path = data_path)
monthly_ts <- make_monthly_ts(monthly_data)
monthly_ts  <- log(monthly_ts)
# full_monthly_ts  <- monthly_ts
monthly_names <- colnames(monthly_ts)
# monthly_data <- get_monthly_variables(data_path = data_path)


external_data_path <- "./data/external/external.xlsx"
external_monthly_data <- get_monthly_variables(data_path = external_data_path)
external_monthly_ts <- make_monthly_ts(external_monthly_data)
external_monthly_ts  <- log(external_monthly_ts)
external_monthly_names <- colnames(external_monthly_ts)


rgdp_ts <- ts(data = gdp_and_dates[["gdp_data"]], 
              start = gdp_and_dates[["gdp_start"]], frequency = 4)
log_rgdp_ts <- log(rgdp_ts)


# rgdp_ts_cv <- cutback_ts(single_ts = rgdp_ts, nrows_to_cut = 3)
# ts.union(rgdp_ts, rgdp_ts_cv)
# 
# # funciona!!! pero debe volver a ser ts
# monthly_data_cv <- apply(monthly_ts, MARGIN = 2, FUN = cutback_ts, nrows_to_cut = 2)
# 
# monthly_ts_cv <- ts(monthly_data_cv, 
#                     start = stats::start(monthly_ts),
#                     frequency = 12)

demetra_output <- get_demetra_params(data_path)
demetra_output_external <- get_demetra_params(external_data_path)


fit_arima_rgdp_list_dem <- fit_arimas(
  y_ts = log_rgdp_ts, order_list = demetra_output[["rgdp_order_list"]],
  this_arima_names = "rgdp")


rgdp_uncond_fc <- forecast(fit_arima_rgdp_list_dem[["rgdp"]], h = h_max)
rgdp_uncond_fc_mean <- rgdp_uncond_fc$mean


force_constant <-  TRUE
fit_arima_monthly_list_dem <- fit_arimas(
  y_ts = monthly_ts, order_list = demetra_output[["monthly_order_list"]],
  this_arima_names = monthly_names,  force_constant = force_constant, freq = 12)


fit_arima_external_monthly_list_dem <- fit_arimas(
  y_ts = external_monthly_ts, order_list = demetra_output_external[["monthly_order_list"]],
  this_arima_names = external_monthly_names,  force_constant = force_constant, freq = 12)



tic()
fit_arima_monthly_list_auto <- fit_arimas(
  y_ts = monthly_ts, auto = TRUE, do_stepwise = TRUE, do_approximation = TRUE,
  this_arima_names = monthly_names)
toc()

<<<<<<< HEAD
# 
=======

# 5.34 sec elapsed
>>>>>>> 88b2c6e018954eba3ae4caafefeb9896b9e639ed
tic()
fit_arima_external_monthly_list_auto <- fit_arimas(
  y_ts = external_monthly_ts, auto = TRUE, do_stepwise = TRUE, do_approximation = TRUE,
  this_arima_names = external_monthly_names)
toc()


# 1962.98 sec elapsed
tic()
fit_arima_monthly_list_auto_slow <- fit_arimas(
  y_ts = monthly_ts, auto = TRUE, do_stepwise = FALSE, do_approximation = FALSE,
  this_arima_names = monthly_names)
toc()

# 185.01 sec elapsed
tic()
fit_arima_external_monthly_list_auto_slow <- fit_arimas(
  y_ts = external_monthly_ts, auto = TRUE, do_stepwise = FALSE, do_approximation = FALSE,
  this_arima_names = external_monthly_names)
toc()


# 183.24 sec elapsed
tic()
fit_arima_monthly_list_auto_noapp <- fit_arimas(
  y_ts = monthly_ts, auto = TRUE, do_stepwise = FALSE, do_approximation = TRUE,
  this_arima_names = monthly_names)
toc()

# 5.34 sec elapsed
tic()
fit_arima_external_monthly_list_auto_noapp <- fit_arimas(
  y_ts = external_monthly_ts, auto = TRUE, do_stepwise = FALSE, do_approximation = TRUE,
  this_arima_names = external_monthly_names)
toc()





tic()
fit_arima_log_monthly_list_auto <- fit_arimas(
  y_ts = log(monthly_ts), auto = TRUE, do_stepwise = TRUE, do_approximation = TRUE,
  this_arima_names = monthly_names)
toc()


# 5.34 sec elapsed
tic()
fit_arima_log_external_monthly_list_auto <- fit_arimas(
  y_ts = log(external_monthly_ts), auto = TRUE, do_stepwise = TRUE, do_approximation = TRUE,
  this_arima_names = external_monthly_names)
toc()


# # 1962.98 sec elapsed
# tic()
# fit_arima_log_monthly_list_auto_slow <- fit_arimas(
#   y_ts = log(monthly_ts), auto = TRUE, do_stepwise = FALSE, do_approximation = FALSE,
#   this_arima_names = monthly_names)
# toc()
# 
# # 185.01 sec elapsed
# tic()
# fit_arima_log_external_monthly_list_auto_slow <- fit_arimas(
#   y_ts = log(external_monthly_ts), auto = TRUE, do_stepwise = FALSE, do_approximation = FALSE,
#   this_arima_names = external_monthly_names)
# toc()


<<<<<<< HEAD

# 320.51 sec elapsedsec elapsed
tic()
fit_arima_monthly_list_auto_noapp <- fit_arimas(
  y_ts = monthly_ts, auto = TRUE, do_stepwise = FALSE, do_approximation = TRUE,
  this_arima_names = monthly_names, parallel)
=======
# 183.24 sec elapsed
tic()
fit_arima_log_monthly_list_auto_noapp <- fit_arimas(
  y_ts = log(monthly_ts), auto = TRUE, do_stepwise = FALSE, do_approximation = TRUE,
  this_arima_names = monthly_names)
>>>>>>> 88b2c6e018954eba3ae4caafefeb9896b9e639ed
toc()

# 5.34 sec elapsed
tic()
fit_arima_log_external_monthly_list_auto_noapp <- fit_arimas(
  y_ts = log(external_monthly_ts), auto = TRUE, do_stepwise = FALSE, do_approximation = TRUE,
  this_arima_names = external_monthly_names)
toc()



fit_arima_monthly_list_auto_slow$imacec
fit_arima_monthly_list_auto_noapp$imacec
fit_arima_monthly_list_auto$imacec

fit_arima_log_monthly_list_auto_slow$imacec
fit_arima_log_monthly_list_auto_noapp$imacec
fit_arima_log_monthly_list_auto$imacec

fit_arima_monthly_list_auto$imacec


gdp_order <- get_order_from_arima(fit_arima_rgdp_list_dem)[[1]]

monthly_order <- get_order_from_arima(fit_arima_monthly_list_dem, 
                                         suffix = "dm",
                                         this_arima_names = monthly_names)

mdata_ext <- extend_and_qtr(data_mts = monthly_ts, 
                                 final_horizon_date = final_forecast_horizon , 
                                 vec_of_names = monthly_names, 
                                 fitted_arima_list = fit_arima_monthly_list_dem,
                                 start_date_gdp = gdp_and_dates[["gdp_start"]])


external_mdata_ext <- extend_and_qtr(data_mts = external_monthly_ts, 
                            final_horizon_date = final_forecast_horizon , 
                            vec_of_names = external_monthly_names, 
                            fitted_arima_list = fit_arima_external_monthly_list_dem,
                            start_date_gdp = gdp_and_dates[["gdp_start"]])


# doox <- mdata_ext[["series_xts"]]
internal_mdata_ext_ts <- mdata_ext[["series_ts"]]
internal_yoy_mdata_ext_ts <- diff(internal_mdata_ext_ts, lag = 4)
internal_monthly_names <- monthly_names

external_mdata_ext_ts <- external_mdata_ext[["series_ts"]]
external_yoy_mdata_ext_ts <- diff(external_mdata_ext_ts, lag = 4)

rgdp_order <-  gdp_order[c("p", "d", "q")]
rgdp_seasonal <-  gdp_order[c("P", "D", "Q")]

mdata_ext_ts <- ts.union(internal_mdata_ext_ts, external_mdata_ext_ts)
monthly_names <- c(internal_monthly_names, external_monthly_names)
colnames(mdata_ext_ts) <- monthly_names

name_x_for_test <- "imacec"
x_for_test_monthly_ts <- na.omit(monthly_ts[, name_x_for_test])
x_for_test_monthly_ts

# saveRDS(object = x_for_test_monthly_ts, file = "./data/imacec_monthly.rds")

x_for_test_uncond_fit <- fit_arima_monthly_list_dem[[name_x_for_test]]
print(x_for_test_uncond_fit)


order_list_x_for_test <-  demetra_output[["monthly_order_list"]][[name_x_for_test]]
order_x_for_test <- order_list_x_for_test[["order"]]
seasonal_x_for_test <- order_list_x_for_test[["seasonal"]]
x_for_test_uncond_fit <- Arima(y = x_for_test_monthly_ts, order = order_x_for_test,
                               seasonal = seasonal_x_for_test, include.constant = TRUE)

x_for_test_uncond_fit2 <- Arima(y = x_for_test_monthly_ts, order = c(0, 0, 1),
                               seasonal = c(0, 1, 1), include.constant = TRUE)

x_for_test_uncond_autofit <-auto.arima(x_for_test_monthly_ts)
x_for_test_uncond_autofit_s <-auto.arima(x_for_test_monthly_ts, stepwise = FALSE, approximation = FALSE)


x_for_test_ufc <- forecast(x_for_test_uncond_fit, h = 23)
x_for_test_ufc_mean <- x_for_test_ufc$mean
x_for_test_monthly_and_fc_ts <- ts(data = c(x_for_test_monthly_ts, 
                                            x_for_test_ufc_mean), frequency = 12,
                                   start = stats::start(x_for_test_monthly_ts))

x_for_test_ufc2 <- forecast(x_for_test_uncond_fit2, h = 23)
x_for_test_ufc_mean2 <- x_for_test_ufc2$mean
x_for_test_monthly_and_fc_ts2 <- ts(data = c(x_for_test_monthly_ts, 
                                             x_for_test_ufc_mean2), frequency = 12,
                                   start = stats::start(x_for_test_monthly_ts))

x_for_test_uautofc <- forecast(x_for_test_uncond_autofit, h = 23)
x_for_test_uautofc_mean <- x_for_test_uautofc$mean
x_for_test_monthly_and_autofc_ts <- ts(data = c(x_for_test_monthly_ts, 
                                            x_for_test_uautofc_mean), frequency = 12,
                                   start = stats::start(x_for_test_monthly_ts))

x_for_test_uauto_s_fc <- forecast(x_for_test_uncond_autofit_s, h = 23)
x_for_test_uauto_s_fc_mean <- x_for_test_uauto_s_fc$mean
x_for_test_monthly_and_auto_s_fc_ts <- ts(data = c(x_for_test_monthly_ts, 
                                                x_for_test_uauto_s_fc_mean), frequency = 12,
                                       start = stats::start(x_for_test_monthly_ts))

ts.union(x_for_test_monthly_and_fc_ts, x_for_test_monthly_and_autofc_ts, x_for_test_monthly_and_auto_s_fc_ts)


x_for_test_monthly_and_fc_ts
difflog_x_for_test_monthly_and_fc_ts <- diff(x_for_test_monthly_and_fc_ts, lag = 12)
difflog_x_for_test_monthly_and_fc_ts
x_for_test_monthly_and_fc_xts <- tk_xts(tk_tbl(x_for_test_monthly_and_fc_ts)) 
x_for_test_monthly_and_fc_xts
x_for_test_quarterly_and_fc_xts <- apply.quarterly(x_for_test_monthly_and_fc_xts , 
                                                   mean, na.rm = TRUE)
x_for_test_yearly_and_fc_xts <- apply.yearly(x_for_test_quarterly_and_fc_xts , 
                                                   mean, na.rm = TRUE)
x_for_test_quarterly_and_fc_ts <- tk_ts(x_for_test_quarterly_and_fc_xts, frequency = 4,
                                        start = c(year(start(x_for_test_monthly_and_fc_xts)),
                                                  quarter(start(x_for_test_monthly_and_fc_xts))
                                        ))

x_for_test_monthly_and_fc_ts2
difflog_x_for_test_monthly_and_fc_ts2 <- diff(x_for_test_monthly_and_fc_ts2, lag = 12)
difflog_x_for_test_monthly_and_fc_ts2
x_for_test_monthly_and_fc_xts2 <- tk_xts(tk_tbl(x_for_test_monthly_and_fc_ts2)) 
x_for_test_monthly_and_fc_xts2
x_for_test_quarterly_and_fc_xts2 <- apply.quarterly(x_for_test_monthly_and_fc_xts2 , 
                                                   mean, na.rm = TRUE)
x_for_test_yearly_and_fc_xts2 <- apply.yearly(x_for_test_quarterly_and_fc_xts2 , 
                                             mean, na.rm = TRUE)
x_for_test_quarterly_and_fc_ts2 <- tk_ts(x_for_test_quarterly_and_fc_xts2, frequency = 4,
                                        start = c(year(start(x_for_test_monthly_and_fc_xts)),
                                                  quarter(start(x_for_test_monthly_and_fc_xts))
                                        ))



difflog_x_for_test_monthly_and_auto_s_fc_ts <- diff(x_for_test_monthly_and_auto_s_fc_ts, lag = 12)
difflog_x_for_test_monthly_and_auto_s_fc_ts
x_for_test_monthly_and_auto_s_fc_xts <- tk_xts(tk_tbl(x_for_test_monthly_and_auto_s_fc_ts)) 
x_for_test_monthly_and_auto_s_fc_xts
x_for_test_quarterly_and_auto_s_fc_xts <- apply.quarterly(x_for_test_monthly_and_auto_s_fc_xts , 
                                                   mean, na.rm = TRUE)
x_for_test_yearly_and_auto_s_fc_xts <- apply.yearly(x_for_test_quarterly_and_auto_s_fc_xts , 
                                             mean, na.rm = TRUE)
x_for_test_quarterly_and_auto_s_fc_ts <- tk_ts(x_for_test_quarterly_and_auto_s_fc_xts, frequency = 4,
                                        start = c(year(start(x_for_test_monthly_and_auto_s_fc_xts)),
                                                  quarter(start(x_for_test_monthly_and_auto_s_fc_xts))
                                        ))


difflog_x_for_test_monthly_and_autofc_ts <- diff(x_for_test_monthly_and_autofc_ts, lag = 12)
difflog_x_for_test_monthly_and_autofc_ts
x_for_test_monthly_and_autofc_xts <- tk_xts(tk_tbl(x_for_test_monthly_and_autofc_ts)) 
x_for_test_monthly_and_autofc_xts
x_for_test_quarterly_and_autofc_xts <- apply.quarterly(x_for_test_monthly_and_autofc_xts , 
                                                       mean, na.rm = TRUE)
x_for_test_yearly_and_autofc_xts <- apply.yearly(x_for_test_quarterly_and_autofc_xts , 
                                                 mean, na.rm = TRUE)
x_for_test_quarterly_and_autofc_ts <- tk_ts(x_for_test_quarterly_and_autofc_xts, frequency = 4,
                                            start = c(year(start(x_for_test_monthly_and_autofc_xts)),
                                                      quarter(start(x_for_test_monthly_and_autofc_xts))
                                            ))


difflog_x_for_test_quarterly_and_fc_ts2 <- diff(x_for_test_quarterly_and_fc_ts2, lag = 4)
difflog_x_for_test_quarterly_and_fc_ts <- diff(x_for_test_quarterly_and_fc_ts, lag = 4)
difflog_x_for_test_quarterly_and_autofc_ts <- diff(x_for_test_quarterly_and_autofc_ts, lag = 4)
difflog_x_for_test_quarterly_and_auto_s_fc_ts <- diff(x_for_test_quarterly_and_auto_s_fc_ts, lag = 4)

foo <- ts.union(difflog_x_for_test_quarterly_and_fc_ts, 
                difflog_x_for_test_quarterly_and_autofc_ts,
                difflog_x_for_test_quarterly_and_auto_s_fc_ts)

foo


x_for_test_quarterly_and_fc_ts

test_x_plot_ufc <- autoplot(x_for_test_monthly_ts) + 
  autolayer(x_for_test_ufc)


print(test_x_plot_ufc)



# verifying quarterly average from monthly values: OK for imacec
# (4.679791+ 4.730206 + 4.674217)/3
# 4.694738
# 
# (4.747647 + 4.785572 + 4.826040)/3
# 4.786420


testing_x_ext_ts <- mdata_ext_ts[, name_x_for_test]

ts.union(x_for_test_quarterly_and_fc_ts, testing_x_ext_ts, x_for_test_quarterly_and_fc_ts - testing_x_ext_ts )

testing_x_noext_ts  <- ts(mdata_ext_ts[, x_for_test],  start = stats::start(rgdp_ts),
                                    end = stats::end(rgdp_ts), frequency = 4)

yoy_testing_x_ext_ts <- make_yoy_ts(exp(mdata_ext_ts[, x_for_test]))
diffoflog_testing_x_ext_ts <- diff(testing_x_ext_ts, lag = 4)


ts.union(yoy_testing_x_ext_ts, diffoflog_testing_x_ext_ts)


# emae_ts <- ts(mdata_ext_ts[, "emae"], , start = stats::start(rgdp_ts),
#               end = stats::end(rgdp_ts), frequency = 4)

# one_arimax_fp <- auto.arima(y = rgdp_ts, xreg = emae_ts)
# two_arimax_fp <- auto.arima(y = rgdp_ts)
# 
# mod_arimax_fp <- Arima(y = rgdp_ts, xreg = emae_ts, order = rgdp_order,
#                        seasonal = rgdp_seasonal)
# 
# foo <- cbind(emae_ts, xts::lag.xts(emae_ts, k = 1), lag.xts(emae_ts, k = 2))
# colnames(foo) <- paste0("xlag_", 0:2)
# foo
# 
# xlagmat <- c()
# 
# for (i in 0:2) {
#   xlagmat <- cbind(xlagmat, lag.xts(emae_ts, k = i))
# }
# 
# colnames(xlagmat) <- paste0("xlag_", 0:2)

# emae_ts_yoy <- diff(emae_ts, lag = 4)
# length(emae_ts)
# train_emae <- subset(emae_ts, end = 49)
# length(train_emae)
# test_emae <- subset(emae_ts, start = 50)
# length(test_emae)
# emae_train_arima <- auto.arima(train_emae)
# fc_train_emae <- forecast(emae_train_arima, h = 8)
# fc_train_emae
# emae_train_and_fc <- ts(c(train_emae, fc_train_emae$mean), start = stats::start(train_emae), frequency = 4)
# emae_train_and_fc_yoy <- diff(emae_train_and_fc, lag = 4)
# emae_fc_yoy <- subset(emae_train_and_fc_yoy, start = 50)
# emae_error_yoy <- emae_test_yoy - emae_fc_yoy
# emae_level_error <- test_emae - fc_train_emae$mean




# my_emaeip <- mdata_ext_ts[, c("emae", "ip")]


tic()
# using contemporary xregs (k = 0)
cv0_e_i <- cv_arimax(y_ts = log_rgdp_ts, xreg_ts = internal_mdata_ext_ts,  h_max =  h_max, n_cv = number_of_cv,
                   training_length = train_span,  y_order = rgdp_order, 
                   y_seasonal = rgdp_seasonal, vec_of_names = internal_monthly_names,
                   method = "ML", s4xreg = FALSE)

cv0_e_e <- cv_arimax(y_ts = log_rgdp_ts, xreg_ts = external_mdata_ext_ts, 
                     h_max =  h_max, n_cv = number_of_cv,
                     training_length = train_span,  y_order = rgdp_order, 
                     y_seasonal = rgdp_seasonal, 
                     vec_of_names = external_monthly_names,
                     method = "ML", s4xreg = FALSE)

cv0_e <- list(cv_errors_all_pairs_yx = c(cv0_e_i$cv_errors_all_pairs_yx,
                                         cv0_e_e$cv_errors_all_pairs_yx),
              cv_yoy_errors_all_pairs_yx = c(cv0_e_i$cv_yoy_errors_all_pairs_yx,
                                         cv0_e_e$cv_yoy_errors_all_pairs_yx)
              )
              

# cv0_e <- cv_arimax(y_ts = log_rgdp_ts, xreg_ts = mdata_ext_ts,  h_max =  h_max, n_cv = number_of_cv,
#                      training_length = train_span,  y_order = rgdp_order, 
#                      y_seasonal = rgdp_seasonal, vec_of_names = monthly_names,
#                      method = "CSS", s4xreg = FALSE)


cv1_e_i <- cv_arimax(y_ts = log_rgdp_ts, xreg_ts = internal_mdata_ext_ts,  h_max = h_max,
                   n_cv = number_of_cv, training_length = train_span,  y_order = rgdp_order, 
                   y_seasonal = rgdp_seasonal, vec_of_names = internal_monthly_names,
                   method = "ML", s4xreg = FALSE, xreg_lags = 0:1)

cv1_e_e <- cv_arimax(y_ts = log_rgdp_ts, xreg_ts = external_mdata_ext_ts,  h_max = h_max,
                     n_cv = number_of_cv, training_length = train_span,  y_order = rgdp_order, 
                     y_seasonal = rgdp_seasonal, vec_of_names = external_monthly_names,
                     method = "ML", s4xreg = FALSE, xreg_lags = 0:1)

cv1_e <- list(cv_errors_all_pairs_yx = c(cv1_e_i$cv_errors_all_pairs_yx,
                                         cv1_e_e$cv_errors_all_pairs_yx),
              cv_yoy_errors_all_pairs_yx = c(cv1_e_i$cv_yoy_errors_all_pairs_yx,
                                             cv1_e_e$cv_yoy_errors_all_pairs_yx)
)

# using two-lags xregs (k = 2)
cv2_e_i <- cv_arimax(y_ts = log_rgdp_ts, xreg_ts = internal_mdata_ext_ts,  h_max = h_max,
                      n_cv = number_of_cv, training_length = train_span,  y_order = rgdp_order, 
                      y_seasonal = rgdp_seasonal, vec_of_names = internal_monthly_names,
                      method = "ML", s4xreg = FALSE, xreg_lags = 0:2)

cv2_e_e <- cv_arimax(y_ts = log_rgdp_ts, xreg_ts = external_mdata_ext_ts,  h_max = h_max,
                     n_cv = number_of_cv, training_length = train_span,  y_order = rgdp_order, 
                     y_seasonal = rgdp_seasonal, vec_of_names = external_monthly_names,
                     method = "ML", s4xreg = FALSE, xreg_lags = 0:2)

cv2_e <- list(cv_errors_all_pairs_yx = c(cv2_e_i$cv_errors_all_pairs_yx,
                                         cv2_e_e$cv_errors_all_pairs_yx),
              cv_yoy_errors_all_pairs_yx = c(cv2_e_i$cv_yoy_errors_all_pairs_yx,
                                             cv2_e_e$cv_yoy_errors_all_pairs_yx)
)


cv_rgdp_e <- cv_arima(y_ts = log_rgdp_ts, h_max = h_max, n_cv = number_of_cv,
                        training_length = train_span,  y_order = rgdp_order, 
                        y_seasonal = rgdp_seasonal,
                        method = "ML")

cv0_e_yoy <- cv0_e[["cv_yoy_errors_all_pairs_yx"]]
cv1_e_yoy <- cv1_e[["cv_yoy_errors_all_pairs_yx"]]
cv2_e_yoy <- cv2_e[["cv_yoy_errors_all_pairs_yx"]]

cv0_e <- cv0_e[["cv_errors_all_pairs_yx"]]
cv1_e <- cv1_e[["cv_errors_all_pairs_yx"]]
cv2_e <- cv2_e[["cv_errors_all_pairs_yx"]]

cv_rgdp_e_yoy <- cv_rgdp_e[["cv_yoy_errors"]]
cv_rgdp_e <- cv_rgdp_e[["cv_errors"]]

toc()

# example with weights_vec set to default
cv0_rmse_list <- map(cv0_e, compute_rmse, h_max = h_max, n_cv = number_of_cv)
cv1_rmse_list <- map(cv1_e, compute_rmse, h_max = h_max, n_cv = number_of_cv)
cv2_rmse_list <- map(cv2_e, compute_rmse, h_max = h_max, n_cv = number_of_cv)

cv0_rmse_list_yoy <- map(cv0_e_yoy, compute_rmse, h_max = h_max, n_cv = number_of_cv)
cv1_rmse_list_yoy <- map(cv1_e_yoy, compute_rmse, h_max = h_max, n_cv = number_of_cv)
cv2_rmse_list_yoy <- map(cv2_e_yoy, compute_rmse, h_max = h_max, n_cv = number_of_cv)

cv_rdgp_rmse <- compute_rmse(cv_rgdp_e, h_max = h_max, n_cv = number_of_cv)
cv_rdgp_rmse_yoy <- compute_rmse(cv_rgdp_e_yoy, h_max = h_max, n_cv = number_of_cv)

cv0_rmse_each_h <- map(cv0_rmse_list, "same_h_rmse") %>% reduce(., rbind) %>% 
  mutate(variable = monthly_names, lag = 0)
cv1_rmse_each_h <- map(cv1_rmse_list, "same_h_rmse") %>% reduce(., rbind) %>% 
  mutate(variable = monthly_names, lag = 1)
cv2_rmse_each_h <- map(cv2_rmse_list, "same_h_rmse") %>% reduce(., rbind) %>% 
  mutate(variable = monthly_names, lag = 2)
cv_rmse_each_h_rgdp <- cv_rdgp_rmse[["same_h_rmse"]] %>% 
  mutate(variable = "rgdp", lag = 0)

cv_all_x_rmse_each_h <- rbind(cv0_rmse_each_h,
                            cv1_rmse_each_h, cv2_rmse_each_h)

cv0_rmse_each_h_yoy <- map(cv0_rmse_list_yoy, "same_h_rmse") %>% reduce(., rbind) %>% 
  mutate(variable = monthly_names, lag = 0)
cv1_rmse_each_h_yoy <- map(cv1_rmse_list_yoy, "same_h_rmse") %>% reduce(., rbind) %>% 
  mutate(variable = monthly_names, lag = 1)
cv2_rmse_each_h_yoy <- map(cv2_rmse_list_yoy, "same_h_rmse") %>% reduce(., rbind) %>% 
  mutate(variable = monthly_names, lag = 2)
cv_rmse_each_h_rgdp_yoy <- cv_rdgp_rmse_yoy[["same_h_rmse"]] %>% 
  mutate(variable = "rgdp", lag = 0)


cv_all_x_rmse_each_h_yoy <- rbind(cv0_rmse_each_h_yoy,
                            cv1_rmse_each_h_yoy, cv2_rmse_each_h_yoy)


all_arimax_0 <- my_arimax(y_ts = log_rgdp_ts, xreg_ts = mdata_ext_ts,  y_order = rgdp_order, 
                        y_seasonal = rgdp_seasonal, vec_of_names = monthly_names,
                        s4xreg = FALSE)

all_arimax_1 <- my_arimax(y_ts = log_rgdp_ts, xreg_ts = mdata_ext_ts,  y_order = rgdp_order, 
                           y_seasonal = rgdp_seasonal, vec_of_names = monthly_names,
                          s4xreg = FALSE, xreg_lags = 0:1)

all_arimax_2 <- my_arimax(y_ts = log_rgdp_ts, xreg_ts = mdata_ext_ts,  y_order = rgdp_order, 
                           y_seasonal = rgdp_seasonal, vec_of_names = monthly_names,
                          s4xreg = FALSE, xreg_lags = 0:2)


all_fcs_0 <- forecast_xreg(all_arimax_0, mdata_ext_ts, h = h_max, 
                           vec_of_names = monthly_names)
all_fcs_1 <- forecast_xreg(all_arimax_1, mdata_ext_ts, h = h_max, 
                           vec_of_names = monthly_names, xreg_lags = 0:1)
all_fcs_2 <- forecast_xreg(all_arimax_2, mdata_ext_ts, h = h_max,
                           vec_of_names = monthly_names, xreg_lags = 0:2)

toc()


all_arimax <- tibble(arimax_0 = all_arimax_0, arimax_1 = all_arimax_1, 
                     arimax_2 = all_arimax_2,  id_fc = monthly_names) %>%
  gather(key = "type_arimax", value = "arimax", -id_fc) %>% 
  mutate(lag = as.integer(str_remove(type_arimax, "arimax_")), 
         armapar = map(arimax, c("arma")),
         arima_order = map(armapar, function(x) x[c(1, 6, 2)]),
         arima_seasonal = map(armapar, function(x) x[c(3, 7, 4)])  
  )


all_fcs <- tibble(fc_0 = all_fcs_0, fc_1 = all_fcs_1, fc_2 = all_fcs_2, 
                    id_fc = monthly_names) %>%
  gather(key = "type_fc", value = "fc", -id_fc) %>% 
  mutate(lag = as.integer(str_remove(type_fc, "fc_")),
         raw_rgdp_fc = map(fc, "mean")) %>% 
  mutate(armapar = map(fc, c("model", "arma")),
         arima_order = map(armapar, function(x) x[c(1, 6, 2)]),
         arima_seasonal = map(armapar, function(x) x[c(3, 7, 4)])  
         ) %>% 
  mutate(data_and_fc = map(raw_rgdp_fc, ~ts(data = c(log_rgdp_ts, .), frequency = 4,
                                             start = stats::start(log_rgdp_ts))),
         yoy_data_and_fc = map(data_and_fc, ~ make_yoy_ts(exp(.))),
         yoy_raw_rgdp_fc = map2(yoy_data_and_fc, raw_rgdp_fc,
                                ~ window(.x, start = stats::start(.y)))
  )



var_lag_order_season <- all_fcs %>% 
  dplyr::select(id_fc, lag, arima_order, arima_seasonal) %>% 
  rename(variable = id_fc, lag = lag)

rgdp_var_lag_order_season <- tibble(
  variable = "rgdp", lag = 0, 
  arima_order = list(rgdp_order), arima_seasonal = list(rgdp_seasonal)) 

var_lag_order_season <- rbind(rgdp_var_lag_order_season, var_lag_order_season)

mat_of_raw_fcs <- reduce(all_fcs$raw_rgdp_fc, rbind) 


weigthed_fcs <- get_weighted_fcs(raw_fcs = mat_of_raw_fcs,
                        mat_cv_rmses_from_x = cv_all_x_rmse_each_h,
                        vec_cv_rmse_from_rgdp = cv_rmse_each_h_rgdp)

weigthed_fcs[ is.nan(weigthed_fcs)] <- rgdp_uncond_fc_mean[ is.nan(weigthed_fcs)]


fcs_using_yoy_weights <- get_weighted_fcs(raw_fcs = mat_of_raw_fcs,
                                 mat_cv_rmses_from_x = cv_all_x_rmse_each_h_yoy,
                                 vec_cv_rmse_from_rgdp = cv_rmse_each_h_rgdp_yoy)

fcs_using_yoy_weights[ is.nan(fcs_using_yoy_weights)] <- rgdp_uncond_fc_mean[ is.nan(fcs_using_yoy_weights)]

weigthed_fcs <- ts(weigthed_fcs, 
                   start = stats::start(rgdp_uncond_fc_mean), 
                   frequency = 4)

rgdp_data_and_uncond_fc <- ts(data = c(log_rgdp_ts, rgdp_uncond_fc_mean), 
                              frequency = 4, start = stats::start(log_rgdp_ts))

yoy_rgdp_data_and_uncond_fc <- make_yoy_ts(exp(rgdp_data_and_uncond_fc))

rgdp_uncond_yoy_fc_mean <- window(yoy_rgdp_data_and_uncond_fc,
                                  start = stats::start(rgdp_uncond_fc_mean))

fcs_using_yoy_weights <- ts(fcs_using_yoy_weights, 
                            start = stats::start(rgdp_uncond_fc_mean), 
                            frequency = 4)



plot_all_fcs_lev_yoy <- function(fcs_tbl, y_ts, is_log = TRUE) {
  
  this_fc <- fcs_tbl %>% filter(id_fc == "imacec", lag == "2")  
  
  this_fc_mean <- this_fc[["raw_rgdp_fc"]] [[1]] 
  
  this_yoy_fc_mean <- this_fc[["yoy_raw_rgdp_fc"]] [[1]] 
  
  if (is_log) {
    yoy_y_ts <- make_yoy_ts(exp(y_ts))
  } else {
    yoy_y_ts <- make_yoy_ts(y_ts)
  }
  
  all_fcs_no_im0 <- all_fcs %>% filter(!(id_fc == "imacec" & lag == "0"))
  
  p <- autoplot(y_ts) + 
    autolayer(rgdp_uncond_fc_mean, series = "uncond", size = 1.5) +
    autolayer(this_fc_mean, series = "imacec_0", size = 1.5)
  
  yoy_p <- autoplot(yoy_y_ts) + 
    autolayer(rgdp_uncond_yoy_fc_mean, series = "uncond", size = 1.5) +
    autolayer(this_yoy_fc_mean, series = "imacec_0", size = 1.5)
  
  
  for (i in 1:nrow(all_fcs_no_im0)) {
    
    this_fc <- all_fcs_no_im0[i,]  
    this_fc_mean <- this_fc[["raw_rgdp_fc"]][[1]] 
    this_yoy_fc_mean <- this_fc[["yoy_raw_rgdp_fc"]][[1]] 
    
    p <- p + autolayer(this_fc_mean, alpha = 0.2, series = "other")
    
    yoy_p <- yoy_p + autolayer(this_yoy_fc_mean, alpha = 0.2, series = "other")
  }
  
  p <- p + coord_cartesian(xlim = c(2012, 2020))
  yoy_p <- yoy_p + coord_cartesian(xlim = c(2012, 2020))
  
  return(list(p, yoy_p))

}

p_yoy_p <- plot_all_fcs_lev_yoy(fcs_tbl = all_fcs, y_ts = rgdp_ts)

walk(p_yoy_p, print)



final_rgdp_and_w_fc <- ts(c(log_rgdp_ts, weigthed_fcs), frequency = 4,
                              start = stats::start(log_rgdp_ts))

final_rgdp_and_yoyw_fc <- ts(c(log_rgdp_ts, fcs_using_yoy_weights), frequency = 4,
                          start = stats::start(log_rgdp_ts))

expo_final_rgdp_and_w_fc <- exp(final_rgdp_and_w_fc)
expo_final_rgdp_and_yoyw_fc <- exp(final_rgdp_and_yoyw_fc)

yoy_growth_expo_final_rgdp_and_w_fc <- diff(expo_final_rgdp_and_w_fc, lag = 4)/lag.xts(expo_final_rgdp_and_w_fc, k = 4)
yoy_growth_expo_final_rgdp_and_yoyw_fc <- diff(expo_final_rgdp_and_yoyw_fc, lag = 4)/lag.xts(expo_final_rgdp_and_yoyw_fc, k = 4)



