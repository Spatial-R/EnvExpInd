##' @title Address to the longitude and latitude
##' @description convert the detailed address into the longitude and latitude based on the Baidumap api
##' @param data: data frame which must contain the address
##' @param add.var: which column or variable contains the address information
##' @param api_key: your key for the baidumap api seeing: \url{http://lbsyun.baidu.com/index.php?title=webapi/guide/webservice-geocoding}
##' @examples
##' \dontrun{
##'  geo_latlon(wuhan.sem,add_var = "add",api_key = "sksksksksksk")
##' }
##' @return two clomuns (lon and lat) was added into the origin data.frame
##' @author Bing Zhang, \url{https://github.com/Spatial-R/EnvExpInd}

geo_latlon <- function(data,add_var="address",api_key = ""){
  dat.tem <- data
  url.base <- "http://api.map.baidu.com/geocoder/v2/?ak="
  url.true <- paste(url.base,api_key,"&callback=renderOption&output=xml&address=",sep = "")
  dat.list <- lapply(1:nrow(dat.tem), function(id){
    url.new <- paste(url.true, dat.tem[id,add_var],sep = "")
    url.result <- try(getURL(url.new))
    longlat <- unlist(stri_match_all_regex(url.result,"[0-9]+[.]*[0-9]*[<>]"))[c(2:3)]
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
