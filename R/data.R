#' Monitoring sites.
#'
#' A dataset containing the information of the monitoring sites
#'
#' @format A data frame with 10 rows and 2 variables:
#' \describe{
#'   \item{site}{the name of monitoring sites}
#'   \item{lat}{the latitude for each monitoring site}
#'   \item{lon}{the longtitude for each monitoring site}
#'   ...
#' }
"site_data"


#' The concentration of air pollutant at each time point.
#'
#' A dataset containing the concentration of air pollutant at each time point
#'
#' @format A data frame with 11090 rows and 8 variables:
#' \describe{
#'   \item{date}{the monitoring time point}
#'   \item{site.name}{the names of the monitoring site}
#'   \item{SO2}{the concentration of SO2}
#'   \item{NO2}{the concentration of NO2}
#'   \item{PM10}{the concentration of PM10}
#'   \item{CO}{the concentration of CO}
#'   \item{O3}{the concentration of O3}
#'   \item{PM2.5}{the concentration of PM2.5}
#'   ...
#' }
"pollutant_data"


#' The detailed information for each individual.
#'
#' A dataset containing the detailed information for each individual
#'
#' @format A data frame with 21 rows and 3 variables:
#' \describe{
#'   \item{id}{id number for each individual}
#'   \item{date}{the monitoring time point}
#'   \item{lat}{the latitude for each individual}
#'   \item{lon}{the longtitude for each individual}
#'   ...
#' }
"individual_data"
