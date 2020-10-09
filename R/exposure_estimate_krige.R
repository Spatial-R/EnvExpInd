###' @title assess the pollutant exposure using the kringe method
###' @description Based on the kringe method, the pollutant exposure in each individual location was estimated and then assess the
###' total pollutant exposure through the estimate_interval
###' @param individual_data data.frame, contains the refrence id, individual_id and exposure_date
###' @param individual_lat character, varibale name in individual_data, represents the latitude information of each idividual
###' @param individual_lon character, varibale name in individual_data, represents the longtitude information of each idividual
###' @param individual_id character, varibale name in individual_data, represents the unique id for each individual
###' @param exposure_date character, varibale name in individual_data, which represents the start date to estimate the environment exposure
###' @param estimate_interval continue numeric vector, the estimation period, for example: 0:30, for each individual we estimate the environment exposure ranging from the exposure_date to exposure_date + 30 days
###' @param pollutant_data data.frame, contains the pollutant and site informatin. One column represents the site information and other columns represent the concentration of pollutants
###' @param pollutant_site_lat character, varibale name in pollutant_data, includes the latitude information of each monitoring site
###' @param pollutant_site_lon character, varibale name in pollutant_data, includes the longtitude information of each monitoring site
###' @param pollutant_date character,varibale name represents the date infromation for the air pollutant dataset
###' @param pollutant_name vactor, pollutant name in the pollutant_data need to be estimated
###' @param krige_model ?krige
###' @param nmax ?krige
###' @param krige_method ?krige
###' @export
###' @import dplyr
###' @import gstat
###' @examples
###' \dontrun{
###' library(EnvExpInd)
###' data(envind)
###' exposure_estimate_krige(
###'        individual_data = individual_data_tem,
###'        individual_id = "id",
###'        exposure_date ="date",
###'        individual_lat ="lat",
###'        individual_lon ="lon",
###'        pollutant_data = pollutant_data_tem_idw,
###'        pollutant_date = "date",
###'        pollutant_site_lat = "lat",
###'        pollutant_site_lon = "lon",
###'        pollutant_name = c("PM10","PM2.5"),
###'        krige_model,
###'        nmax = 7,
###'        krige_method = "med",
###'        estimate_interval = c(0:30))
###' }
###' @return  a list. every dataframe in the list was with the first column representing the individual id, the remaining columns represent the exposure estimation
###' in different days.
###' @export
###' @author  Bing Zhang, \url{https://github.com/Spatial-R/EnvExpInd}

exposure_estimate_krige  <- function(individual_data,
                                     individual_id,
                                     exposure_date,
                                     individual_lat,
                                     individual_lon,
                                     pollutant_data,
                                     pollutant_date = "date",
                                     pollutant_site_lat,
                                     pollutant_site_lon,
                                     pollutant_name = c("pm10","so2"),
                                     estimate_interval = c(0:30),
                                     krige_model,
                                     nmax = 7,
                                     krige_method = "med"){

  pollutant_data <- data.frame(pollutant_data)
  individual_data <- data.frame(pollutant_data)
  
  var_check_ind <- match(c(individual_id,individual_lat,
                                       individual_lon,exposure_date),names(individual_data))
  var_check_polt <- match(c(pollutant_date,pollutant_name,
                                        pollutant_site_lat,pollutant_site_lon),names(pollutant_data))

  if(length(which(is.na(var_check_ind))) > 0){
    miss_var_ind <- paste(c(individual_id,individual_lat,
                            individual_lon,exposure_date)[var_check_ind],collapse = ",")
    stop(print(paste0("The names of variables: ",miss_var_ind," were not in the individual_data")))
  }

  if(length(which(is.na(var_check_polt))) > 0){
    miss_var_polt <- paste(c(pollutant_date,pollutant_name,
                             pollutant_site_lat,pollutant_site_lon)[var_check_polt],collapse = ",")
    stop(print(paste0("The names of variables: ",miss_var_polt," were not in the pollutant_data")))
  }

  individual_data <- individual_data[,var_check_ind]
  names(individual_data) <- c("individual_id","exposure_date","individual_lat","individual_lon")
  
  pollutant_data <- pollutant_data[,var_check_polt]
  names(pollutant_data) <- c("pollutant_date",pollutant_name,"pollutant_site_lat","pollutant_site_lon")
  
  pollutant.num <- length(pollutant_name)
  left.date <- min(individual_data$exposure_date);
  right.date <- max(individual_data$exposure_date)

  if (!all(date.check %in% (pollutant_data$pollutant_date))){
    stop(paste0("the date to esitmate is not fully in the pollutant dataset"))
  }

  result.final <- list()

  for (i in c(1:pollutant.num)){  ### loop for different pollutants

    pollutant_col <- match(pollutant_name[i],names(pollutant_data))
    names(pollutant_data)[pollutant_col] <- c("pollutant")

    tem.list <- lapply(1:nrow(individual_data),function(data.id){   ### loop for different individual
      idividual.tem <- individual_data[data.id,c("individual_lat","individual_lon")]
      sp::coordinates(idividual.tem) =~ individual_lat + individual_lon
      date.target   <- individual_data[data.id,"exposure_date"] + estimate_interval
      date.length   <- length(date.target); pollutant.list <- list()

      for (d in (1:date.length)){    ### loop for different date
        idw.data.ori <- pollutant.type[pollutant.type$pollutant_date == (date.target[d]),]
        if(!nrow(idw.data.ori) == 0){
          sp::coordinates(idw.data.ori) =~ pollutant_site_lat + pollutant_site_lon
          pm25.tem = data.frame(tem = gstat::krige(pollutant~1,idw.data.ori,idividual.tem,
                                            model = krige_model, nmax = nmax,
                                            set = list(method = krige_method))@data[,-2])
          pollutant.list[[d]] <- pm25.tem
        } else{
          pollutant.list[[d]] <- NA
        }
      }
      pollutant.result <- dplyr::bind_cols(pollutant.list)
      names(pollutant.result) <- paste("day.",estimate_interval,sep = "")
      pollutant.result$id <-  individual_data[data.id,"individual_id"]
      pollutant.result <- pollutant.result[,c("id", paste("day.",estimate_interval,sep = ""))]
      return(pollutant.result)
    })
    result.final[[i]] <- dplyr::bind_rows(tem.list);
  }
  names(result.final) <- pollutant_name;
  return(result.final)
}
