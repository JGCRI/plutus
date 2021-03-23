#-----------------
# Internal Data
#-----------------

#' elecQueries xml file
#'
#' @source gcam query
#' @format .xml
#' @examples
#' \dontrun{
#'  library(plutus); library(XML)
#'  plutus::xmlElecQueries
#'  # Can save xml
#'  XML::saveXML(plutus::xmlElecQueries, file=paste(getwd(), "/ElecQueries.xml", sep = ""))
#' }
"xmlElecQueries"

# elecInvest internal files

#' data_tech_mapping
#'
#' @source paste(rawDataFolder,"agg_tech_mapping.csv", sep="")
#' @format .csv
#' @examples
#' \dontrun{
#'  library(plutus);
#'  plutus::tech_mapping
#' }
"data_tech_mapping"


#' data_capac_fac
#'
#' @source paste(rawDataFolder,"L223.GlobalTechCapFac_elec.csv", sep="")
#' @format .csv
#' @examples
#' \dontrun{
#'  library(plutus);
#'  plutus::data_capac_fac
#' }
"data_capac_fac"


#' data_capac_fac_region
#'
#' @source paste(rawDataFolder,"L223.StubTechCapFactor_elec.csv", sep="")
#' @format .csv
#' @examples
#' \dontrun{
#'  library(plutus);
#'  plutus::data_capac_fac_region
#' }
"data_capac_fac_region"

#' data_A23.globaltech_retirement
#'
#' @source paste(rawDataFolder,"A23.globaltech_retirement.csv",sep="")
#' @format .csv
#' @examples
#' \dontrun{
#'  library(plutus);
#'  plutus::data_A23.globaltech_retirement
#' }
"data_A23.globaltech_retirement"

#' data_cap_cost_int_cool
#'
#' @source paste(rawDataFolder,"L2233.GlobalIntTechCapital_elec_cool.csv", sep="")
#' @format .csv
#' @examples
#' \dontrun{
#'  library(plutus);
#'  plutus::data_cap_cost_int_cool
#' }
"data_cap_cost_int_cool"

#' data_cap_cost_int_tech
#'
#' @source paste(rawDataFolder,"L2233.GlobalIntTechCapital_elec.csv", sep="")
#' @format .csv
#' @examples
#' \dontrun{
#'  library(plutus);
#'  plutus::data_cap_cost_int_tech
#' }
"data_cap_cost_int_tech"

#' data_cap_cost_cool
#'
#' @source paste(rawDataFolder,"L2233.GlobalTechCapital_elec_cool.csv", sep="")
#' @format .csv
#' @examples
#' \dontrun{
#'  library(plutus);
#'  plutus::data_cap_cost_cool
#' }
"data_cap_cost_cool"

#' data_cap_cost_tech
#'
#' @source paste(rawDataFolder,"L2233.GlobalTechCapital_elecPassthru.csv", sep="")
#' @format .csv
#' @examples
#' \dontrun{
#'  library(plutus);
#'  plutus::data_cap_cost_tech
#' }
"data_cap_cost_tech"

#' data_capfactors
#'
#' @source paste(rawDataFolder,"capacity_factor_by_elec_gen_subsector.csv",sep="")
#' @format .csv
#' @examples
#' \dontrun{
#'  library(plutus);
#'  plutus::data_capfactors
#' }
"data_capfactors"


#-----------------
# Example Data
#-----------------

#' Example GCAM .proj file
#'
#' @source metis.readgcam() run outputs saved
#' @format R table or .csv
#' @examples
#' \dontrun{
#'  library(plutus);
#'  plutus::exampleGCAMproj
#' }
"exampleGCAMproj"
