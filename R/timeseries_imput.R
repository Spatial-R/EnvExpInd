###' @title Impute the missing value for the timeseries using the linear interpolation
###' @description Complete the time series using the linear interpolation
###' @param data data.frame, contains the refrence id, individual_id and exposure_date
###' @param date_var character, varibale name in data, represents the monitoring date.
###' @param site_var character, varibale name in data, represents the name of monitoring site.
###' @param imput_col numeric,the column position of the target variables need to be imputed
###' @import dplyr
###' @import zoo
###' @examples
###' library(EnvExpInd)
###' pollutant_data_com <- timeseries_imput(data= pollutant_data,date_var = "date",
###'                       site_var = "site.name",imput_col = 3:8)
###' @return  a data.frame
###' @export
###' @author  Bing Zhang, \url{https://github.com/Spatial-R/EnvExpInd}


timeseries_imput <- function(data,date_var,site_var,imput_col){

  timeseres_data <- data
  var_check_ind <- match(c(date_var,site_var),names(timeseres_data))

  if(length(which(is.na(var_check_ind))) > 0){
    miss_var_ind <- paste(c(date_var,site_var)[which(is.na(var_check_ind))],collapse = ",")
    stop(print(paste0("The parameter of ",miss_var_ind," was not in your data, please check it")))
  }

  stopifnot(all(is.numeric(imput_col)))

  names(timeseres_data)[var_check_ind] <- c("date","site.name")

  timeseres_data$date <- as.Date(timeseres_data$date)
  full.date <- data.frame(date = seq.Date(range(timeseres_data$date)[1],range(timeseres_data$date)[2],by="day"))

  pollutant.list <- lapply(unique(timeseres_data$site.name),function(id){
    dat.tem <- timeseres_data[timeseres_data$site.name == id,]
    pollutant.1 <- merge(full.date,dat.tem,by.x = "date",by.y = "date",all.x = T)
    pollutant.1 <- dplyr::arrange(pollutant.1,date);
    pollutant.1[,imput_col] <- apply(pollutant.1[,imput_col],2,as.numeric)

   if(any(is.na(pollutant.1[,imput_col]))){
    na.num.max <- max(which(is.na(pollutant.1$site.name)))
    na.num.min <- min(which(is.na(pollutant.1$site.name)))
    pollutant.1$site.name  <- ifelse(is.na(pollutant.1$site.name),id,pollutant.1$site.name)

    if(na.num.max == nrow(pollutant.1)) {
      mean.value <- apply(pollutant.1[,imput_col],2,mean)
      pollutant.1[na.num.max,] <- c(pollutant.1[na.num.max,1:2],mean.value)
    }
    if(na.num.min == 1) {
      mean.value <- apply(pollutant.1[,imput_col],2,mean)
      pollutant.1[na.num.min,] <- c(pollutant.1[na.num.min,1:2],mean.value)
    }
    pollutant.1[,imput_col] <- apply(pollutant.1[,imput_col],2,zoo::na.approx)
    pollutant.1$site.name <- id
   }
    return(pollutant.1)
  })
  timeseres_data_fin <- bind_rows(pollutant.list)
  return(timeseres_data_fin)
}

