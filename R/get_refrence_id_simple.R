get_refrence_id_simple <- function(individual_data,
                                   individual_lat,
                                   individual_lon,
                                   individual_id,
                                   site_data,
                                   site_lat,
                                   site_lon,
                                   site_id){

  ### @ individual_data : the individual dataset from the geo_latlon function
  ### @ individual_lat : varibale which includes the latitude value of the idividual
  ### @ individual_lon : varibale which includes longtitude value of the idividual
  ### @ individual_id  : varibale which includes the id for each individual, fox example: 1,2,3,4

  ### @ site_data : the site dataset from the geo_latlon function
  ### @ site_lat : varibale which includes the latitude value of the site
  ### @ site_lon : varibale which includes the longtitude value of the site
  ### @ site_id  : varibale which includes the id for each site, fox example: site name

  #  individual_data = individual_data_tem;
  #  individual_lat = "lat";
  #  individual_lon = "lon";
  #  individual_id = "编号";
  #  site_data = site_data;
  #  site_lat = "lat";
  #  site_lon = "lon";
  #  site_id = "site"


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
