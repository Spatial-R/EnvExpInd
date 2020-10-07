##' @title  get the refrence site for every sample
##' @param  individual_data data.frame from the geo_latlon_china function or geocode function in ggmap
##' @param  individual_lat character, varibale name in individual_data, includes the latitude information of each idividual
##' @param  individual_lon character, varibale name in individual_data, includes the longtitude information of each idividual
##' @param  individual_id  character, varibale name in individual_data, includes the unique id for each individual
##' @param  site_data  data.frame from the geo_latlon function
##' @param  site_lat  character varibale includes the latitude value of the site
##' @param  site_lon  character varibale includes the longtitude value of the site
##' @param  site_id   character varibale includes the id for each site
##' @examples
##' \dontrun{
##' get_refrence_id_simple(
##'      individual_data = individual_data_tem,
##'      individual_lat = "lat",
##'      individual_lon = "lon",
##'      individual_id = "id",
##'      site_data = site_data,
##'      site_lon = "lon",
##'      site_id = "site")
##' }
##' @return refrence_id for each individual
##' @author Bing Zhang, \url{https://github.com/Spatial-R/EnvExpInd}

get_refrence_id_simple <- function(individual_data,
                                   individual_lat,
                                   individual_lon,
                                   individual_id,
                                   site_data,
                                   site_lat,
                                   site_lon,
                                   site_id){


  if (any(is.na(individual_data[,individual_lat]))){
    print("There is missing value in the individual dataset")
  }
  if (any(is.na(site_data[,site_lat]))){
    print("There is missing value in the site dataset")
  }

  if(!any(is.na(individual_data[,individual_lat])) & (!any(is.na(site_data[,site_lat])))){

    individual.site.id <- unlist(lapply(1:nrow(individual_data),function(id){
      distance.1 <- (individual_data[id,individual_lat] - site_data[,site_lat])^2
      distance.2 <- (individual_data[id,individual_lon] - site_data[,site_lon])^2
      site.num <- which.min((distance.1 + distance.2))
      return(site_data[site.num,site_id])
    }))}
  # dat.tem <- data.frame(individual_id = individaul_data[,individual_id],
  #                      refrence_id = as.character(individual.site.id))
  return(as.character(individual.site.id))
}
