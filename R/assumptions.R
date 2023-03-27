#' assumptions
#'
#' This function loads holds the different assumptions used throughout the plutus package.
#'
#'@param name Default=NULL. Name of assumption object.
#' List of Assumptions
#' \itemize{
#' \item GCAMbaseYear,
#' \item convEJ2MTOE,
#' \item convEJ2TWh,
#' \item convEJ2GW,
#' \item convEJ2GWh,
#' \item convGW_kW,
#' \item conv_C_CO2,
#' \item conv_MT_GT,
#' \item hydro_cap_fact,
#' \item hydro_cost_GW,
#' \item convUSD_1975_2010,
#' \item convUSD_1975_2015,
#' \item convUSD_2010_2015,
#' \item conv1975USDperGJ22017USDperMWh,
#' \item conv1975USDperGJ22017USDperMBTU}
#' @keywords assumptions
#' @return A list of assumptions
#' @export
#' @examples
#' library(plutus)
#' a <- plutus::assumptions("GCAMbaseYear")
#' @importFrom magrittr %>%

assumptions <- function(name=NULL) {

  #------------------
  # Conversions
  #------------------
  GCAMbaseYear <- 2015
  convEJ2MTOE<-23.8845897  #https://www.iea.org/statistics/resources/unitconverter/
  convEJ2TWh<-277.77777777778
  convEJ2GW<-convEJ2TWh*1000/8760
  convEJ2GWh <- 277777.778
  convGW_kW <- 1e6
  conv1975USDperGJ22017USDperMWh<- (103.015/28.485)/0.2777778 # (13.02) Deflators 1975 (28.485) to 2017 (103.015) from World Bank https://data.worldbank.org/indicator/NY.GDP.DEFL.ZS?locations=US&view=chart
  conv1975USDperGJ22017USDperMBTU<- (103.015/28.485)/0.947 # (3.82) Deflators 1975 (28.485) to 2017 (103.015) from World Bank https://data.worldbank.org/indicator/NY.GDP.DEFL.ZS?locations=US&view=chart
  convUSD_1975_2010	<- 91.718/28.485 # (3.22) Deflators 1975 (28.485) to 2010 (91.718) from World Bank https://data.worldbank.org/indicator/NY.GDP.DEFL.ZS?locations=US&view=chart
  convUSD_1975_2015	<- 100/28.485 # (3.51) Deflators 1975 (28.485) to 2015 (100) from World Bank https://data.worldbank.org/indicator/NY.GDP.DEFL.ZS?locations=US&view=chart
  convUSD_2010_2015 <- 100/91.9 # (3.51) Deflators 2010 (91.9) to 2015 (100) from World Bank https://data.worldbank.org/indicator/NY.GDP.DEFL.ZS?locations=US&view=chart
  conv_C_CO2 <- 44/12
  conv_MT_GT <- 1e-3


  #--------------------------------------------------------------------------------------------------
  # Data source for capacity factor:
  # https://hub.globalccsinstitute.com/publications/renewable-power-generation-costs-2012-overview/52-capacity-factors-hydropower
  # Data source for hydropower capital cost
  # https://hub.globalccsinstitute.com/publications/renewable-power-generation-costs-2012-overview/51-hydropower-capital-costs
  #--------------------------------------------------------------------------------------------------

  hydro_cap_fact <- 0.38
  hydro_cost_GW <- 1.5
  wind_offshore_cap_fact <- 0.37


  #--------------------------------------------------------------------------------------------------
  # Return Data
  #--------------------------------------------------------------------------------------------------

  listx <- list(
    GCAMbaseYear=GCAMbaseYear,
    convEJ2MTOE=convEJ2MTOE,
    convEJ2TWh=convEJ2TWh,
    convEJ2GW=convEJ2GW,
    convEJ2GWh=convEJ2GWh,
    convGW_kW=convGW_kW,
    conv_C_CO2=conv_C_CO2,
    conv_MT_GT=conv_MT_GT,
    hydro_cap_fact=hydro_cap_fact,
    hydro_cost_GW=hydro_cost_GW,
    wind_offshore_cap_fact=wind_offshore_cap_fact,
    convUSD_1975_2010=convUSD_1975_2010,
    convUSD_1975_2015=convUSD_1975_2015,
    convUSD_2010_2015=convUSD_2010_2015,
    conv1975USDperGJ22017USDperMWh=conv1975USDperGJ22017USDperMWh,
    conv1975USDperGJ22017USDperMBTU=conv1975USDperGJ22017USDperMBTU)

  if(!is.null(name)){returnx <- listx[[name]]} else {returnx <- listx }


  return(returnx)
}
