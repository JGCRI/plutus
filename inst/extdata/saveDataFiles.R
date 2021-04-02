# Converting raw data into package data
library(usethis)
library(data.table)
library(XML)

rawDataFolder = "E:/NEXO-UA/Github/plutus/inst/extdata/"

#-------------------
# Data
#-------------------

# Metis XMl Query Files
xmlFilePath = paste0(rawDataFolder,"ElecQueries.xml")
xmlfile <- XML::xmlTreeParse(xmlFilePath)
xmltop <- XML::xmlRoot(xmlfile)
top <- XML::xmlNode(XML::xmlName(xmltop))
for(i in 1:length(xmltop)){
  top <- XML::addChildren(top, xmltop[[i]])
}
xmlElecQueries <- top
use_data(xmlElecQueries, overwrite=T)

# Capacity factors
data_cap_cost_tech <- data.table::fread(paste(rawDataFolder,"L2233.GlobalTechCapital_elecPassthru.csv", sep=""), skip=1, stringsAsFactors = FALSE)
data_cap_cost_cool <- data.table::fread(paste(rawDataFolder,"L2233.GlobalTechCapital_elec_cool.csv", sep=""), skip=1, stringsAsFactors = FALSE)
data_cap_cost_int_tech <- data.table::fread(paste(rawDataFolder,"L2233.GlobalIntTechCapital_elec.csv", sep=""), skip=1, stringsAsFactors = FALSE)
data_cap_cost_int_cool <- data.table::fread(paste(rawDataFolder,"L2233.GlobalIntTechCapital_elec_cool.csv", sep=""), skip=1, stringsAsFactors = FALSE)
data_A23.globaltech_retirement <- data.table::fread(paste(rawDataFolder,"A23.globaltech_retirement.csv",sep=""), skip=1)
data_capac_fac <- data.table::fread(paste(rawDataFolder,"L223.GlobalTechCapFac_elec.csv", sep=""), skip=1, stringsAsFactors = FALSE)
data_capac_fac_int <- data.table::fread(paste(rawDataFolder,"L223.GlobalIntTechCapFac_elec.csv", sep=""), skip=1, stringsAsFactors = FALSE)
data_capac_fac_region <- data.table::fread(paste(rawDataFolder,"L223.StubTechCapFactor_elec.csv", sep=""), skip=1, stringsAsFactors = FALSE)
data_tech_mapping <- data.table::fread(paste(rawDataFolder,"agg_tech_mapping.csv", sep=""), skip=1)

use_data(data_cap_cost_tech, overwrite=T)
use_data(data_cap_cost_cool, overwrite=T)
use_data(data_cap_cost_int_tech, overwrite=T)
use_data(data_cap_cost_int_cool, overwrite=T)
use_data(data_A23.globaltech_retirement, overwrite=T)
use_data(data_capac_fac, overwrite=T)
use_data(data_capac_fac_int, overwrite=T)
use_data(data_capac_fac_region, overwrite=T)
use_data(data_tech_mapping, overwrite=T)

#-------------------
# Example Data
#-------------------

# Example .proj file
# Run this
metis.readgcam(gcamdatabase = "E:/NEXO-UA/GCAM-Workspace/gcam-core_LAC_v02_5Nov2019/output/FinalRuns/IDBNexus_gcam5p3_HadGEM2-ES_rcp8p5",
               paramsSelect = c(
                 "elecNewCapCost",
                 "elecNewCapGW",
                 "elecAnnualRetPrematureCost",
                 "elecAnnualRetPrematureGW",
                 "elecCumCapCost",
                 "elecCumCapGW",
                 "elecCumRetPrematureCost",
                 "elecCumRetPrematureGW"
               ),
               dataProjFile = "E:/NEXO-UA/Github/plutus/inst/extdata/Example_gcam5p3_HadGEM2-ES_rcp8p5.proj",
               saveData = F,
               reReadData = T)
exampleGCAMproj <- rgcam::loadProject('E:/NEXO-UA/Github/plutus/inst/extdata/Example_gcam5p3_HadGEM2-ES_rcp8p5.proj')
use_data(exampleGCAMproj, overwrite = T)
