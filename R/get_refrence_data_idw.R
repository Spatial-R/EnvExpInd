###' @title estimate the environmental exposure using the inverse distance weighting method
###' @description used the envronment concentration in the individual location as the reference point to
###' estimate the environmental exposure. The envionmental concentration at the refrence point was calculated
###' based on the inverse distance weighting method.
###' @param individual_data data.frame includes the refrence id, individual_id and exposure_date
###' @param individual_id character, represents the unique id for each individual
###' @param exposure_date character, represents the date information
###' @param estimate_interval continue numeric vector, represents the time-interval to estimate
###' @param pollutant_data data.frame which indludes the pollutant and site informatin
###' @param pollutant_site character,varibale name which includes the site infromation
###' @param pollutant_date character,varibale name represents the date infromation for the air pollutant dataset
###' @param pollutant_name character, ollutant name in the pollutant_data need to be estimated
###' @examples
###' get_refrence_data_idw(
###' individual_data = individual_data_tem,
###' individual_id = "id",
###' exposure_date ="date",
###' individual_lat ="lat",
###' individual_lon ="lon",
###' pollutant_data = pollutant_data_tem_idw,
###' pollutant_date = "date",
###' pollutant_site_lat = "lat",
###' pollutant_site_lon = "lon",
###' pollutant_name = c("PM10","PM2.5"),
###' estimate_interval = c(0:30)
###' )
###' @return aa
###' @author Bing Zhang, \url{www.spatial-r.com}


get_refrence_data_idw <- function(individual_data,
                                  individual_id,
                                  exposure_date,
                                  individual_lat,
                                  individual_lon,
                                  pollutant_data,
                                  pollutant_date = "date",
                                  pollutant_site_lat,
                                  pollutant_site_lon,
                                  pollutant_name = c("pm10","so2"),
                                  estimate_interval = c(0:30)){

  individual_data <- individual_data[,c(individual_id,exposure_date,individual_lat,individual_lon)]
  names(individual_data) <- c("individual_id","exposure_date","individual_lat","individual_lon")

  pollutant.num <- length(pollutant_name)
  left.date <- min(individual_data[,"exposure_date"]);
  right.date <- max(individual_data[,"exposure_date"])
  date.check <- c(left.date + estimate_interval, right.date + estimate_interval)

  if (!all(date.check %in% (pollutant_data[,pollutant_date]))){
    warning("the date to esitmate is not fully in the pollutant dataset")
    stop("the date to esitmate is not fully in the pollutant dataset")
  }

  result.final <- list()

  for (i in c(1:pollutant.num)){  ### loop for different pollutants
    pollutant.type <- pollutant_data[,c(pollutant_date,pollutant_name[i],
                                        pollutant_site_lat,pollutant_site_lon)]
    names(pollutant.type) <- c("pollutant_date","pollutant","pollutant_site_lat","pollutant_site_lon")

    tem.list <- lapply(1:nrow(individual_data),function(data.id){   ### loop for different individual
      idividual.tem <- individual_data[data.id,c("individual_lat","individual_lon")]
      coordinates(idividual.tem) =~ individual_lat + individual_lon
      date.target   <- individual_data[data.id,"exposure_date"] + estimate_interval
      date.length   <- length(date.target); pollutant.list <- list()

      for (d in (1:date.length)){    ### loop for different date
        idw.data.ori <- pollutant.type[pollutant.type$pollutant_date == (date.target[d]),]
        if(!nrow(idw.data.ori) == 0){
          coordinates(idw.data.ori) =~ pollutant_site_lat + pollutant_site_lon
          pm25.tem = data.frame(tem = idw(pollutant~1,idw.data.ori,idividual.tem)@data[,-2])
          pollutant.list[[d]] <- pm25.tem
        } else{
          pollutant.list[[d]] <- NA
        }
      }
      pollutant.result <- bind_cols(pollutant.list)
      names(pollutant.result) <- paste("day.",estimate_interval,sep = "")
      pollutant.result$id <-  individual_data[data.id,"individual_id"]
      return(pollutant.result)
    })
    result.final[[i]] <- bind_rows(tem.list);
  }
  names(result.final) <- pollutant_name;
  return(result.final)
}
