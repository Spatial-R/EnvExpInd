###' @title  Assess the environmental exposure using the simplest method: nearest monitoring site method
###' @description Using the nearest surveillance site as the refrence site to estimate the pollutant exposure.
###' @param  individual_data data.frame, includes the refrence id, individual_id and exposure_date
###' @param  individual_id character, variable name in the individual_data, which represents the unique id for each individual
###' @param  reference_id character, variable name in the individual_data, which represents the nearest surveillance site for each individual
###' @param  exposure_date character, variable name in the individual_data, which represents the start date to estimate the environment exposure
###' @param  estimate_interval continue numeric vector, the estimation period, for example: 0:30, for each individual we estimate the environment exposure ranging from the exposure_date to exposure_date + 30 days
###' @param  pollutant_data data.frame, contains the pollutant and site information. One column represents the site information and other columns represent the concentration of pollutants
###' @param  pollutant_site character, variable name in the pollutant_data, which represents the monitoring site information
###' @param  pollutant_date character, variable name in the pollutant_data, which represents the surveillance date for pollutant concentration
###' @param  pollutant_name vector, variable names in the pollutant_data, which represent the name of the target pollutants to be estimated
###' @examples
###'  library(EnvExpInd)
###'  individual_data$date <- as.Date(individual_data$date)
###'  pollutant_data$date <- as.Date(pollutant_data$date)
###'  pollutant_data_full <- timeseries_imput(data= pollutant_data,
###'      date_var = "date",site_var = "site.name",imput_col = 3:8)
###'  pollutant_data_tem <- merge(pollutant_data_full,site_data,by.x = "site.name",by.y = "site")
###'  individual_data$reference_id <- get_reference_id_simple(
###'    individual_data = individual_data,
###'    individual_lat = "lat",
###'    individual_lon = "lon",
###'    individual_id = "id",
###'    site_data = site_data,
###'    site_lon = "lon",
###'    site_lat = "lat",
###'    site_id = "site")
###' expoure_estimate_simple(
###'    individual_data = individual_data,
###'    individual_id = "id",
###'    reference_id = "reference_id",
###'    exposure_date = "date",
###'    pollutant_data = pollutant_data_tem,
###'    pollutant_site = "site.name",
###'    pollutant_date = "date",
###'    pollutant_name = c("PM10","PM2.5"),
###'    estimate_interval = c(0:10))
###' @return A list. For each element in the list, there is a dataframe with the first column representing the individual id, the remaining columns represent the exposure estimation
###' in different time points.
###' @export
###' @import dplyr
###' @author Bing Zhang, \url{https://github.com/Spatial-R/EnvExpInd}


expoure_estimate_simple <- function(individual_data,
                                    individual_id,
                                    reference_id,
                                    exposure_date,
                                    pollutant_data,
                                    pollutant_site = "site",
                                    pollutant_date = "date",
                                    pollutant_name = c("pm10","so2"),
                                    estimate_interval){

  pollutant_data <- data.frame(pollutant_data)
  individual_data <- data.frame(individual_data)

  var_check_ind <-  match(c(individual_id,reference_id,exposure_date),names(individual_data))
  var_check_polt <- match(c(pollutant_site,pollutant_date,pollutant_name),names(pollutant_data))

  if(length(which(is.na(var_check_ind))) > 0){
    miss_var_ind <- paste(c(individual_id,reference_id,exposure_date)[which(is.na(var_check_ind))],collapse = ",")
    stop(print(paste0("The names of variables: ",miss_var_ind," were not in the individual_data")))
  }

  if(length(which(is.na(var_check_polt))) > 0){
    miss_var_polt <- paste(c(pollutant_site,pollutant_date,pollutant_name)[which(is.na(var_check_polt))],collapse = ",")
    stop(print(paste0("The names of variables: ",miss_var_polt," were not in the pollutant_data")))
  }

  individual_data <- individual_data[,var_check_ind]
  names(individual_data) <- c("individual_id","reference_id","exposure_date")

  pollutant_data <- pollutant_data[,var_check_polt]
  names(pollutant_data) <- c("pollutant_site","pollutant_date",pollutant_name)

  pollutant.num <- length(pollutant_name)
  left.date <- min(individual_data$exposure_date);
  right.date <- max(individual_data$exposure_date)
  date.check <- c(left.date + estimate_interval, right.date + estimate_interval)

  if (!all(date.check %in% (pollutant_data$pollutant_date))){
    stop(print("The date you want to esitmate the exposure is not in the pollutant dataset"))
  }

  result.final <- list()

  for (i in c(1:pollutant.num)){

    pollutant.type <- pollutant_data
    pollutant_col <- match(pollutant_name[i],names(pollutant.type))
    names(pollutant.type)[pollutant_col] <- c("pollutant")

    tem.list <- lapply(1:nrow(individual_data),function(data.id){
      idividual.tem <- individual_data[data.id,]
      date.target   <- idividual.tem[1,"exposure_date"] + estimate_interval
      date.length   <- length(date.target)
      pollutant.tem <- pollutant.type[(pollutant.type$pollutant_date %in% date.target) &
                                        (pollutant.type$pollutant_site == idividual.tem$reference_id),]
      if(nrow(pollutant.tem) == 0){
        exposure <- c(individual_data[data.id,"individual_id"], rep("NA",length(date.target)))
      } else{
        pollutant.tem <- dplyr::arrange(pollutant.tem,desc(pollutant_date))
        exposure <- c(individual_data[data.id,"individual_id"],
                      pollutant.tem$pollutant,rep("NA",date.length-nrow(pollutant.tem)))
      }
      exposure <- data.frame(matrix(exposure,ncol = (date.length + 1),nrow = 1))
      exposure[,1] <- as.character(exposure[,1])
      return(exposure)
    })
    tem.result <- dplyr::bind_rows(tem.list);
    names(tem.result) <- c("id",paste("day.",estimate_interval,sep = ""))
    result.final[[i]] <- tem.result
  }
  names(result.final) <- pollutant_name;
  return(result.final)
}
