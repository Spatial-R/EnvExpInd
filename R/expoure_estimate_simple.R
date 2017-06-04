###' @title  estimate the environmental exposure using the simple method
###' @description using the nearest surveillance site as the refrence site to estimate the environment exposure.
###' @param  individual_data the dataset which inludes the refrence id, indi_id and exposure_date
###' @param  individual_id varibale which includes the id for each individual, fox example: 1,2,3,4
###' @param  refrence_id varibale which tell you the target site id
###' @param  exposure_date varibale which has the date information
###' @param  estimate_interval how long do you need to measure, for example: 0:30
###' @param  pollutant_data the dataset which indludes the pollutant and site informatin
###' @param  pollutant_site varibale name which includes the site infromation
###' @param  pollutant_date varibale name which includes the date infromation for pollutant
###' @param  pollutant_name which pollutant need to be estimated
###' @examples
###' expoure_estimate_simple(
###'     individual_data = individual_data_tem,
###'    individual_id = "id",
###'    refrence_id = "refrence_id",
###'    exposure_date = "date",
###'    pollutant_data = pollutant_data_tem,
###'    pollutant_site = "site.name",
###'    pollutant_date = "date",
###'    pollutant_name = c("PM10","PM2.5"),
###'    estimate_interval = c(0:30))
###' @return aa
###' @author Bing Zhang, \url{www.spatial-r.com}


expoure_estimate_simple <- function(individual_data,
                                    individual_id,
                                    refrence_id,
                                    exposure_date,
                                    pollutant_data,
                                    pollutant_site = "site",
                                    pollutant_date = "date",
                                    pollutant_name = c("pm10","so2"),
                                    estimate_interval){

  individual_data <- individual_data[,c(individual_id,refrence_id,exposure_date)]
  names(individual_data) <- c("individual_id","refrence_id","exposure_date")

  pollutant.num <- length(pollutant_name)
  left.date <- min(individual_data[,"exposure_date"]);
  right.date <- max(individual_data[,"exposure_date"])
  date.check <- c(left.date + estimate_interval, right.date + estimate_interval)

  if (!all(date.check %in% (pollutant_data[,pollutant_date]))){
    warning("the date to esitmate is not fully in the pollutant dataset")
  }

  result.final <- list()

  for (i in c(1:pollutant.num)){
    pollutant.type <- pollutant_data[,c(pollutant_site,pollutant_date,pollutant_name[i])]
    names(pollutant.type) <- c("pollutant_site","pollutant_date","pollutant")
    tem.list <- lapply(1:nrow(individual_data),function(data.id){
      idividual.tem <- individual_data[data.id,]
      date.target   <- idividual.tem[1,"exposure_date"] + estimate_interval
      date.length   <- length(date.target)
      pollutant.tem <- pollutant.type[(pollutant.type$pollutant_date %in% date.target) &
                                        (pollutant.type$pollutant_site == idividual.tem$refrence_id),]
      if(nrow(pollutant.tem) == 0){
        exposure <- c(individual_data[data.id,"individual_id"], rep("NA",length(date.targrt)))
      } else{
        pollutant.tem <- arrange(pollutant.tem,desc(pollutant_date))
        exposure <- c(individual_data[data.id,"individual_id"],
                      pollutant.tem$pollutant,rep("NA",date.length-nrow(pollutant.tem)))
      }
      exposure <- data.frame(matrix(exposure,ncol = (date.length + 1),nrow = 1))
      exposure[,1] <- as.character(exposure[,1])
      return(exposure)
    })
    tem.result <- bind_rows(tem.list);
    names(tem.result) <- c("id",paste("day.",estimate_interval,sep = ""))
    result.final[[i]] <- tem.result
  }
  names(result.final) <- pollutant_name;
  return(result.final)
}
