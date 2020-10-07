##' @title transform the address information into the longitude and latitude
##' @description Based on the Baidumap api, get_latlon_china function coverts the detailed address into the longitude and latitude
##' @param data data frame, contains the address information
##' @param add_var character, variable name in the data, which represents the address information
##' @param api_key character,  baidumap api key, seeing: \url{http://lbsyun.baidu.com/index.php?title=webapi/guide/webservice-geocoding}
##' @examples
##' \dontrun{
##'  get_latlon_china(wuhan.sem,add_var = "add",api_key = "sksksksksksk")
##' }
##' @return two clomuns (lon and lat) was added into the origin data.frame
##' @export
##' @import RCurl
##' @import stringi
##' @author Bing Zhang, \url{https://github.com/Spatial-R/EnvExpInd}

get_latlon_china <- function(data,add_var="address",api_key = ""){
  dat.tem <- data
  tar_col <- match(add_var,names(data))

  if(length(tar_col) == 0){
    stop(print("The value of add.var was not in the individual_data"))
  }

  url.base <- "http://api.map.baidu.com/geocoding/v3/?address="
  dat.list <- lapply(1:nrow(dat.tem), function(id){
    url.new <- paste(url.base, dat.tem[id,tar_col],"&output=xml&ak=",api_key,"&callback=renderOption",sep = "")
    url.result <- try(RCurl::getURL(url.new))
    longlat <- unlist(stringi::stri_match_all_regex(url.result,"[0-9]+[.]*[0-9]*[<>]"))[c(2:3)]
    longlat <- data.frame(t(longlat));
    longlat[,1:2] <- apply(longlat[,1:2],2,as.character)
    return(longlat)
  })
  lt <- bind_rows(dat.list)
  lt[,1:2] <- apply(lt[,1:2],2,function(data){
     lt.tem <- as.numeric(gsub("<","",data));
     return(lt.tem)
  })
  names(lt) <- c("lat","lon")
  dat.final <- cbind(dat.tem,lt); return(dat.final)
}
