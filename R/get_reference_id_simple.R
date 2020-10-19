##' @title  Match the nearing monitoring site for each individual
##' @param  individual_data data.frame, including three variables (individual_lat, individual_lon and individual_id)
##' @param  individual_lat character, varibale name in individual_data, includes the latitude information of each individual
##' @param  individual_lon character, varibale name in individual_data, includes the longtitude information of each individual
##' @param  individual_id  character, varibale name in individual_data, includes the unique id for each individual
##' @param  site_data  data.frame, including three variables (site_lat, site_lon and site_id)
##' @param  site_lat  character variable includes the latitude value of the site
##' @param  site_lon  character variable includes the longtitude value of the site
##' @param  site_id   character variable includes the id for each site
##' @export
##' @examples
##' get_reference_id_simple(
##'      individual_data = individual_data,
##'      individual_lat = "lat",
##'      individual_lon = "lon",
##'      individual_id = "id",
##'      site_data = site_data,
##'      site_lon = "lon",
##'      site_lat = "lat",
##'      site_id = "site")
##' @return A vector, including the reference_id for each individual
##' @author Bing Zhang, \url{https://github.com/Spatial-R/EnvExpInd}

get_reference_id_simple <- function(individual_data,
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
  return(as.character(individual.site.id))
}
