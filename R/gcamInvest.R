#' gcamInvest
#'
#' This function connects and reads a gcamdatabase or a query data proj file and calculates
#' electricity and hydropower investments.
#'
#' @param gcamdatabase Default = NULL. Full path to GCAM database folder.
#' @param queryFile Defualt = NULL. When NULL plutus loads pre-saved xml file plutus::xmlElecQueries
#' @param reReadData If TRUE will read the GCAM data base and create a queryData.proj file
#' in the same folder as the GCAM database. If FALSE will load a '.proj' file if a file
#' with full path is provided otherwise it will search for a dataProj.proj file in the existing
#' folder which may have been created from an old run.
#' @param dataProjFile Default = NULL. Optional. A default 'dataProj.proj' is produced if no .Proj file is specified.
#' @param gcamdataFile Default = NULL. Optional. For example, gcamdataFile = "~/gcam-core-gcam-v5.3/input/gcamdata".
#' Use full path to GCAM 'gcamdata' folder that contains costs and capacity data. Data files including:
#'
#' A23.globaltech_retirement.csv
#' L223.GlobalIntTechCapFac_elec.csv
#' L223.GlobalTechCapFac_elec.csv
#' L2233.GlobalIntTechCapital_elec.csv
#' L2233.GlobalIntTechCapital_elec_cool.csv
#' L2233.GlobalTechCapital_elec_cool.csv
#' L2233.GlobalTechCapital_elecPassthru.csv
#' @param scenOrigNames Default = "All". Original Scenarios names in GCAM database in a string vector.
#' For example c('scenario1','scenario2).
#' @param scenNewNames New Names which may be shorter and more useful for figures etc.
#' Default will use Original Names. For example c('scenario1','scenario2)
#' @param regionsSelect The regions to analyze in a vector. Example c('Colombia','Argentina'). Full list:
#'
#' USA, Africa_Eastern, Africa_Northern, Africa_Southern, Africa_Western, Australia_NZ, Brazil, Canada
#' Central America and Caribbean, Central Asia, China, EU-12, EU-15, Europe_Eastern, Europe_Non_EU,
#' European Free Trade Association, India, Indonesia, Japan, Mexico, Middle East, Pakistan, Russia,
#' South Africa, South America_Northern, South America_Southern, South Asia, South Korea, Southeast Asia,
#' Taiwan, Argentina, Colombia, Uruguay
#' @param dirOutputs Full path to directory for outputs
#' @param folderName Default = NULL
#' @param nameAppend  Default = "". Name to append to saved files.
#' @param saveData Default = "T". Set to F if do not want to save any data to file.
#' @keywords gcam, gcam database, query
#' @return Returns (1) annual and cumulative costs and power generation of
#' premature retired electricity infrustructure (including hydropower);
#' (2) annual and cumulative costs and power generation of new capacity from new electricity infrustructures (including hydropower).
#' @export

gcamInvest <- function(gcamdatabase = NULL,
                       queryFile = NULL,
                       reReadData = T,
                       dataProjFile = paste(getwd(), "/outputs/dataProj.proj", sep = ""),
                       gcamdataFile = NULL,
                       scenOrigNames = 'All',
                       scenNewNames = NULL,
                       regionsSelect = NULL,
                       dirOutputs = paste(getwd(), "/outputs", sep = ""),
                       folderName = NULL,
                       nameAppend = "",
                       saveData = T
){
  #---------------------
  # Initialize variables by setting to NULL
  #---------------------

  NULL -> vintage -> year -> xLabel -> x -> value -> sector -> scenario -> region -> param -> origX -> origValue ->
    origUnits -> origScen -> origQuery -> classPalette2 -> classPalette1 -> classLabel2 -> classLabel1 -> class2 ->
    class1 -> connx -> aggregate -> Units -> sources -> paramx -> technology -> input -> output -> regionsSelectAll ->
    . -> agg_tech -> subsector -> paramsSelectAll -> dataTemplate -> datax -> group -> basin -> subRegion -> query


  #---------------------
  # Params and Queries
  #---------------------

  queriesSelectx <- c("elec gen by gen tech and cooling tech and vintage",
                      "Electricity generation by aggregate technology")

  #-----------------------------
  # Create necessary directories if they dont exist.
  #----------------------------
  if (!dir.exists(dirOutputs)){
    dir.create(dirOutputs)}  # Output Directory
  if (!dir.exists(paste(dirOutputs, "/", folderName, sep = ""))){
    dir.create(paste(dirOutputs, "/", folderName, sep = ""))}
  if (!dir.exists(paste(dirOutputs, "/", folderName,"/readGCAM",sep=""))){
    dir.create(paste(dirOutputs, "/", folderName,"/readGCAM",sep=""))}  # Output Directory
  if (!dir.exists(paste(dirOutputs, "/", folderName, "/readGCAM/Tables_gcam", sep = ""))){
    dir.create(paste(dirOutputs, "/", folderName, "/readGCAM/Tables_gcam", sep = ""))}  # GCAM output directory
  if (!dir.exists(paste(dirOutputs, "/", folderName, "/readGCAM/Tables_Templates", sep = ""))){
    dir.create(paste(dirOutputs, "/", folderName, "/readGCAM/Tables_Templates", sep = ""))}  # GCAM output directory

  #---------------------
  # Set file paths
  #---------------------

  if(is.null(gcamdatabase)){
    gcamdatabasePath = NULL
    gcamdatabaseName = NULL
  }else{
    if(is.character(gcamdatabase)){
      if(dir.exists(gcamdatabase)){
        gcamdatabasePath <- gsub("/$","",gsub("[^/]+$","",gcamdatabase)); gcamdatabasePath
        gcamdatabaseName <- basename(gcamdatabase); gcamdatabaseName
        print(paste("Connecting to GCAM database provided ",gcamdatabase,"...",sep=""))
      }else{print(paste("The GCAM database path provided dos not exist: ", gcamdatabase, sep=""))}
    }else{
      print(paste("gcamdatabase provided is not a character string to the GCAM database path. Please check your entry."))
    }
  }

  if(is.null(queryFile)){
    XML::saveXML(plutus::xmlElecQueries, file=paste(dirOutputs, "/", folderName,"/readGCAM/ElecQueries.xml", sep = ""))
    queryFile <- paste(dirOutputs, "/", folderName,"/readGCAM/ElecQueries.xml", sep = "")
    queryPath <- gsub("[^/]+$","",queryFile)
    queryxml <- basename(queryFile)
  }else{
    if(is.character(queryFile)){
      if(file.exists(queryFile)){
        queryPath <- gsub("[^/]+$","",queryFile)
        queryxml <- basename(queryFile)
        print(paste("Connecting to the queryFile provided ",queryFile,"...",sep=""))
      }else{print(paste("The queryFile path provided dos not exist: ", queryFile, sep=""))}
    }else{
      print(paste("The queryFile path provided is not a character string to the query file. Please check your entry."))
    }
  }

  if(is.null(dataProjFile)){
    dataProj = "dataProj"
    dataProjPath = gsub("//","/",paste(dirOutputs, "/", folderName,"/readGCAM/", sep = ""))
  }else{
    if(is.list(dataProjFile)){
      dataProjPath <- gsub("//","/",paste(dirOutputs, "/", folderName,"/readGCAM/", sep = ""))
      dataProj <- paste("dataProj", sep = "")
    }else{
      if(is.character(dataProjFile)){
        if(grepl("/",dataProjFile)){
          if(file.exists(dataProjFile)){
            dataProjPath <- gsub("[^/]+$","",dataProjFile)
            dataProj <- basename(dataProjFile)
            print(paste("Connecting to the dataProjFile provided ",dataProjFile,"...",sep=""))}else{
              dataProjPath <- gsub("[^/]+$","",dataProjFile)
              dataProj <- basename(dataProjFile)
              print(gsub("//","/",paste("Will save GCAM data to ",dataProjPath,"/",dataProjFile,"...",sep="")))
            }
        }else{
          dataProjPath <- gsub("//","/",paste(dirOutputs, "/", folderName,"/readGCAM/", sep = ""))
          dataProj <- dataProjFile
          print(paste("Will save data to: ", dataProjPath,"/",dataProjFile, sep=""))
        }
      }else{
        print(paste("The dataProjFile path provided is not a character string to the query file. Please check your entry."))
      }
    }
  }

  # Set new scenario names if provided
  if (is.null(scenOrigNames)) {
    scenNewNames <- NULL
    #print("scenOrigNames is NULL so cannot assign scenNewNames.")
    #print("To set new names for scenarios please enter original names in scenOrigNames and then corresponding new names in scenNewNames.")
  } else {
    if(any(c("all","All","ALL") %in% scenOrigNames)){
      scenNewNames <- NULL
      #print("scenOrigNames is All so cannot assign scenNewNames.")
      #print("To set new names for scenarios please enter original names in scenOrigNames and then corresponding new names in scenNewNames.")
    }
  }


  #---------------------------------------------
  # Read gcam database or existing dataProj.proj
  #--------------------------------------------

  # In case user sets reReadData=F and provides a .proj file instead of a gcamdatabase
  if ((is.null(gcamdatabasePath) |
       is.null(gcamdatabaseName)) & reReadData == T) {
    if (is.list(dataProjFile)) {
      reReadData = F
      #print("Setting reReadData to F because no gcamdatabase is provided but a valid dataProjFile provided.")
    }
    if (file.exists(paste(dataProjPath, "/", dataProj, sep = ""))) {
      reReadData = F
      #print("Setting reReadData to F because no gcamdatabase is provided but a valid dataProjFile provided.")
    }
  }

  if (!reReadData) {
    # Check for proj file path and folder if incorrect give error
    if(!is.list(dataProjFile)){
      if(!file.exists(gsub("//","/",paste(dataProjPath, "/", dataProj, sep = "")))){
        stop(gsub("//","/",paste("dataProj file: ", dataProjPath,"/",dataProj," is incorrect or doesn't exist.",sep="")))}
    }

    # Checking if dataProjFile is preloaded xml plutus::xmlElecQueries
    if(is.list(dataProjFile)){
      dataProjLoaded <- rgcam::loadProject(dataProjFile)
    }else{
      if (file.exists(gsub("//","/",paste(dataProjPath, "/", dataProj, sep = "")))) {
        dataProjLoaded <- rgcam::loadProject(gsub("//","/",paste(dataProjPath, "/", dataProj, sep = "")))
      } else {
        stop(paste("No ", dataProj, " file exists. Please set reReadData=T to create dataProj.proj"))
      }}

    scenarios <- rgcam::listScenarios(dataProjLoaded); scenarios  # List of Scenarios in GCAM database
    queries <- rgcam::listQueries(dataProjLoaded); queries  # List of queries in GCAM database

    # Select Scenarios
    if(is.null(scenOrigNames)){
      scenOrigNames <- scenarios[1]
      print(paste("scenOrigNames set to NULL so using only first scenario: ",scenarios[1],sep=""))
      print(paste("from all available scenarios: ",paste(scenarios,collapse=", "),sep=""))
      print("To run all scenarios please set scenOrigNames to 'All' or")
      print(paste("you can choose a subset of scenarios by setting the scenOrigNames input (eg. scenOrigNames = c('scen1','scen2'))" ,sep=""))
    } else {
      if(any(c("all","All","ALL") %in% scenOrigNames)){
        scenOrigNames <- scenarios
        print(paste("scenOrigNames set to 'All' (Default) so using all available scenarios: ",paste(scenarios,collapse=", "),sep=""))
        print(paste("You can choose a subset of scenarios by setting the scenOrigNames input (eg. scenOrigNames = c('scen1','scen2'))" ,sep=""))
      } else {
        if(any(scenOrigNames %in% scenarios)){
          print(paste("scenOrigNames available in scenarios are :",paste(scenOrigNames[scenOrigNames %in% scenarios],collapse=", "),sep=""))
          if(length(scenOrigNames[!scenOrigNames %in% scenarios])>0){
            print(paste("scenOrigNames not available in scenarios are :",paste(scenOrigNames[!scenOrigNames %in% scenarios],collapse=", "),sep=""))}
          if(length(scenarios[!scenarios %in% scenOrigNames])>0){
            print(paste("Other scenarios not selected are :",paste(scenarios[!scenarios %in% scenOrigNames],collapse=", "),sep=""))}
        } else {
          print(paste("None of the scenOrigNames : ",paste(scenOrigNames,collapse=", "),sep=""))
          print(paste("are in the available scenarios : ",paste(scenarios,collapse=", "),sep=""))
        }
      }
    }

    scenarios <- scenOrigNames # Set scenarios to chosen scenarios

  } else {

    # Check for query file and folder if incorrect give error
    if(!file.exists(gsub("//","/",paste(queryPath, "/", queryxml, sep = "")))){stop(paste("query file: ", queryPath,"/",queryxml," is incorrect or doesn't exist.",sep=""))}
    if(file.exists(gsub("//","/",paste(queryPath, "/subSetQueries.xml", sep = "")))){unlink(gsub("//","/",paste(queryPath, "/subSetQueries.xml", sep = "")))}

    # Subset the query file if queriwsSelect is not "All"
    if(!any(c("All","all","ALL") %in% paramsSelect)){

      xmlFilePath = gsub("//","/",paste(queryPath, "/", queryxml, sep = ""))
      xmlfile <- XML::xmlTreeParse(xmlFilePath)
      xmltop <- XML::xmlRoot(xmlfile)
      top <- XML::xmlNode(XML::xmlName(xmltop))

      for(i in 1:length(xmltop)){
        for(j in 1:length(queriesSelectx)){
          if(any(grepl(gsub("\\(","\\\\(",gsub("\\)","\\\\)",queriesSelectx[j])), as.character(xmltop[[i]]))))
            top <- XML::addChildren(top, xmltop[[i]])
        }
      }
      XML::saveXML(top, file=gsub("//","/",paste(queryPath, "/subSetQueries.xml", sep = "")))
    } else {
      print(paste("paramsSelect includes 'All' so running all available queries: ",paste(queriesSelectx,collapse=", "),".",sep=""))
      file.copy(from=gsub("//","/",paste(queryPath, "/", queryxml, sep = "")),
                to=gsub("//","/",paste(queryPath, "/subSetQueries.xml", sep = "")))
    }

    if(!file.exists(gsub("//","/",paste(queryPath, "/subSetQueries.xml", sep = "")))){
      stop(gsub("//","/",paste("query file: ", queryPath,"/subSetQueries.xml is incorrect or doesn't exist.",sep="")))}else{
        print(gsub("//","/",paste("Reading queries from queryFile created: ", queryPath,"/subSetQueries.xml.",sep="")))
      }

    # Check for gcamdatbasePath and gcamdatabasename
    if(!is.null(gcamdatabase)){
      if(is.null(gcamdatabasePath) | is.null(gcamdatabaseName)){
        stop(gsub("//","/",paste("GCAM database: ", gcamdatabasePath,"/",gcamdatabaseName," is incorrect or doesn't exist.",sep="")))}
      if(!file.exists(gsub("//","/",paste(gcamdatabasePath, "/", gcamdatabaseName, sep = "")))){
        stop(gsub("//","/",paste("GCAM database: ", gcamdatabasePath,"/",gcamdatabaseName," is incorrect or doesn't exist.",sep="")))}
    }

    # Get names of scenarios in database
    # Save Message from rgcam::localDBConn to a text file and then extract names
    zz <- file(paste(getwd(),"/test.txt",sep=""), open = "wt")
    sink(zz,type="message")
    rgcam::localDBConn(gcamdatabasePath,gcamdatabaseName)
    sink()
    closeAllConnections()
    # Read temp file
    con <- file(paste(getwd(),"/test.txt",sep=""),open = "r")
    first_line <- readLines(con,n=1); first_line
    closeAllConnections()
    if(grepl("error",first_line,ignore.case = T)){stop(paste(first_line))}
    print(first_line)
    if(file.exists(paste(getwd(),"/test.txt",sep=""))){unlink(paste(getwd(),"/test.txt",sep=""))}
    # Extract scenario names from saved line
    s1 <- gsub(".*:","",first_line);s1
    s2 <- gsub(" ","",s1);s2
    scenarios <- as.vector(unlist(strsplit(s2,",")))
    print(paste("All scenarios in data available: ", paste(scenarios,collapse=", "), sep=""))


    if(file.exists(gsub("//","/",paste(dataProjPath, "/", dataProj, sep = "")))){
      unlink(gsub("//","/",paste(dataProjPath, "/", dataProj, sep = "")))}  # Delete old project file

    # Select Scenarios
    if(is.null(scenOrigNames)){
      scenOrigNames <- scenarios[1]
      print(paste("scenOrigNames set to NULL so using only first scenario: ",scenarios[1],sep=""))
      print(paste("from all available scenarios: ",paste(scenarios,collapse=", "),sep=""))
      print("To run all scenarios please set scenOrigNames to 'All'")
    } else {
      if(any(c("all","All","ALL") %in% scenOrigNames)){
        scenOrigNames <- scenarios
        print(paste("scenOrigNames set to 'All' so using all available scenarios: ",paste(scenarios,collapse=", "),sep=""))
      } else {
        if(any(scenOrigNames %in% scenarios)){
          print(paste("scenOrigNames available in scenarios are :",paste(scenOrigNames[scenOrigNames %in% scenarios],collapse=", "),sep=""))
          if(length(scenOrigNames[!scenOrigNames %in% scenarios])>0){
            print(paste("scenOrigNames not available in scenarios are :",paste(scenOrigNames[!scenOrigNames %in% scenarios],collapse=", "),sep=""))}
          if(length(scenarios[!scenarios %in% scenOrigNames])>0){
            print(paste("Other scenarios not selected are :",paste(scenarios[!scenarios %in% scenOrigNames],collapse=", "),sep=""))}
        } else {
          print(paste("None of the scenOrigNames : ",paste(scenOrigNames,collapse=", "),sep=""))
          print(paste("are in the available scenarios : ",paste(scenarios,collapse=", "),sep=""))
          stop("Please check scenOrigNames and rerun.")
        }
      }
    }

    for (scenario_i in scenOrigNames) {
      dataProj.proj <- rgcam::addScenario(
        conn = rgcam::localDBConn(gcamdatabasePath, gcamdatabaseName),
        proj = gsub("//", "/", paste(dataProjPath, "/", dataProj, sep = "")),
        scenario = scenario_i,
        queryFile = gsub("//", "/", paste(queryPath, "/subSetQueries.xml", sep = ""))
      )  # Check your queries file
    }

    dataProjLoaded <- rgcam::loadProject(gsub("//","/",paste(dataProjPath, "/", dataProj, sep = "")))

    # Save list of scenarios and queries
    scenarios <- rgcam::listScenarios(dataProjLoaded); scenarios  # List of Scenarios in GCAM database
    queries <- rgcam::listQueries(dataProjLoaded); queries  # List of queries in GCAM database
  }

  queries <- rgcam::listQueries(dataProjLoaded); queries  # List of Queries in queryxml

  # Set new scenario names if provided
  if (is.null(scenNewNames)) {
    scenNewNames <- scenOrigNames
  } else{
    scenNewNames <- scenNewNames[1:length(scenOrigNames)]
  }

  # Read in paramaters from query file to create formatted table
  queriesx <- queries

  if(!any(queriesSelectx %in% queries)) {
    stop("None of the selected params are available in the data that has been read. Please check your data if reRead was set to F. Otherwise check the paramSelect entries and the queryxml file.")
  }

  datax <- tibble::tibble()


  # ----------------------------------------------
  # Electricity generation by aggregate technology
  # ----------------------------------------------
  paramsSelectx <- c("elecNewCapCost","elecNewCapGW","elecAnnualRetPrematureCost","elecAnnualRetPrematureGW",
                     "elecCumCapCost","elecCumCapGW","elecCumRetPrematureCost","elecCumRetPrematureGW")
  queryx <- "elec gen by gen tech and cooling tech and vintage"
  queryx2 <- "Electricity generation by aggregate technology"
  if (queryx %in% queriesx & queryx2 %in% queries) {

    tbl <- rgcam::getQuery(dataProjLoaded, queryx)  # Tibble
    if (!is.null(regionsSelect)) {
      tbl <- tbl %>% dplyr::filter(region %in% regionsSelect)
    }
    tblx <- rgcam::getQuery(dataProjLoaded, queryx2)  # Tibble
    if (!is.null(regionsSelect)) {
      tblx <- tblx %>% dplyr::filter(region %in% regionsSelect)
    }

    counter <- 0
    # NEW--must do loop throug scenarios due to current design of script
    start_year_i = max(min(unique(tbl$year)), plutus::assumptions("GCAMbaseYear"))
    end_year_i = max(unique(tbl$year))
    temp_list = list()
    for (scen in scenarios){
      elec_gen_vintage <- tbl %>%
        dplyr::filter(scenario == scen) %>%
        tidyr::spread(year, value) %>%
        dplyr::mutate_all( ~ replace(., is.na(.), 0))
      temp_list <- plutus::elecInvest(elec_gen_vintage,
                                      gcamdataFile = gcamdataFile,
                                      world_regions = regionsSelect,
                                      start_year = start_year_i,
                                      end_year = end_year_i)
      start_yr_hydro <- start_year_i
      end_year <- end_year_i
      temp_df <- tblx %>%
        dplyr::filter(scenario == scen) %>%
        dplyr::rename(agg_tech = technology) %>%
        dplyr::filter(year >= start_yr_hydro, year <= end_year) %>%
        tidyr::spread(year, value) %>%
        dplyr::mutate_all( ~ replace(., is.na(.), 0))
      if(counter==0){
        addition_costs <- temp_list
        # Include hydropower cost/installed capacity needs, which isn't handled in the SA_elec script because it is not vintaged.
        addition_costs[['elec_prod']] <- temp_df
      }else{
        addition_costs[['elec_prod']] <- rbind(addition_costs[['elec_prod']], temp_df)
        for (key in names(addition_costs)){
          addition_costs[[key]] <- rbind(addition_costs[[key]], temp_list[[key]])
          # Include hydropower cost/installed capacity needs, which isn't handled in the SA_elec script because it is not vintaged.
        }
      }
      counter <- counter+1
    }

    addition_costsWhydro <- plutus::hydroInvest(addition_costs=addition_costs, start_year=start_year_i)$addition_costs

    tbl1<-tbl2<-tbl3<-tbl4<-tbl5<-tbl6<-tbl7<-tbl8<-tibble::tibble()

    # newCap_cost
    if(nrow(addition_costsWhydro[["newCap_cost"]])>0){
      tbl1 <- addition_costsWhydro[["newCap_cost"]] %>%
        tidyr::gather(key="year",value=value,-Units,-scenario,-region, -subRegion, -agg_tech)%>%
        dplyr::filter(scenario %in% scenOrigNames)%>%
        dplyr::left_join(tibble::tibble(scenOrigNames, scenNewNames), by = c(scenario = "scenOrigNames")) %>%
        dplyr::rename(technology=agg_tech)%>%
        dplyr::mutate(year=as.numeric(year),
                      param = "elecNewCapCost",
                      technology=gsub("biomass","bioenergy",technology),
                      technology=gsub("Biomass","Bioenergy",technology),
                      technology=gsub("b\\sbiomass","b bioenergy",technology),
                      technology=gsub("g\\sBiomass","g Bioenergy",technology),
                      technology=gsub("h\\sBiomass\\sw\\/CCS","h Bioenergy w/CCS",technology),
                      sources = "Sources",
                      origScen = scenario,
                      origQuery = queryx,
                      origValue = value,
                      origUnits = Units,
                      origX = year, subRegion=region,
                      scenario = scenNewNames,
                      units = "New Elec Cap Cost (Billion 2010 USD)",
                      vintage = paste("Vint_", year, sep = ""),
                      x = year,
                      xLabel = "Year",
                      aggregate = "sum",
                      class1 = technology,
                      classLabel1 = "Fuel",
                      classPalette1 = "pal_metis",
                      class2 = "class2",
                      classLabel2 = "classLabel2",
                      classPalette2 = "classPalette2")%>%
        dplyr::select(scenario, region, subRegion,    param, sources, class1, class2, x, xLabel, vintage, units, value,
                      aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                      origScen, origQuery, origValue, origUnits, origX)%>%
        dplyr::group_by(scenario, region, subRegion,  param, sources,class1,class2, x, xLabel, vintage, units,
                        aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                        origScen, origQuery, origUnits, origX)%>%
        dplyr::summarize_at(dplyr::vars("value","origValue"),list(~sum(.,na.rm = T)))%>%dplyr::ungroup()%>%
        dplyr::filter(!is.na(value))
    }

    # newCap_GW
    if(nrow(addition_costs[["newCap_GW"]])>0){
      tbl2 <- addition_costs[["newCap_GW"]] %>%
        tidyr::gather(key="year",value=value,-Units,-scenario,-region, -subRegion, -agg_tech)%>%
        dplyr::filter(scenario %in% scenOrigNames)%>%
        dplyr::left_join(tibble::tibble(scenOrigNames, scenNewNames), by = c(scenario = "scenOrigNames")) %>%
        dplyr::rename(technology=agg_tech)%>%
        dplyr::mutate(year=as.numeric(year),
                      param = "elecNewCapGW",
                      technology=gsub("biomass","bioenergy",technology),
                      technology=gsub("Biomass","Bioenergy",technology),
                      technology=gsub("b\\sbiomass","b bioenergy",technology),
                      technology=gsub("g\\sBiomass","g Bioenergy",technology),
                      technology=gsub("h\\sBiomass\\sw\\/CCS","h Bioenergy w/CCS",technology),
                      sources = "Sources",
                      origScen = scenario,
                      origQuery = queryx,
                      origValue = value,
                      origUnits = Units,
                      origX = year, subRegion=region,
                      scenario = scenNewNames,
                      units = "New Elec Cap (GW)",
                      vintage = paste("Vint_", year, sep = ""),
                      x = year,
                      xLabel = "Year",
                      aggregate = "sum",
                      class1 = technology,
                      classLabel1 = "Fuel",
                      classPalette1 = "pal_metis",
                      class2 = "class2",
                      classLabel2 = "classLabel2",
                      classPalette2 = "classPalette2")%>%
        dplyr::select(scenario, region, subRegion,    param, sources, class1, class2, x, xLabel, vintage, units, value,
                      aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                      origScen, origQuery, origValue, origUnits, origX)%>%
        dplyr::group_by(scenario, region, subRegion,    param, sources,class1,class2, x, xLabel, vintage, units,
                        aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                        origScen, origQuery, origUnits, origX)%>%dplyr::summarize_at(dplyr::vars("value","origValue"),list(~sum(.,na.rm = T)))%>%dplyr::ungroup()%>%
        dplyr::filter(!is.na(value))
    }

    # retPremature_cost
    if(nrow(addition_costs[["annualPrematureRet_cost"]])>0){
      tbl3 <- addition_costs[["annualPrematureRet_cost"]] %>%
        tidyr::gather(key="year",value=value,-Units,-scenario,-region, -subRegion, -agg_tech)%>%
        dplyr::filter(scenario %in% scenOrigNames)%>%
        dplyr::left_join(tibble::tibble(scenOrigNames, scenNewNames), by = c(scenario = "scenOrigNames")) %>%
        dplyr::rename(technology=agg_tech)%>%
        dplyr::mutate(year=as.numeric(year),
                      param = "elecAnnualRetPrematureCost",
                      technology=gsub("biomass","bioenergy",technology),
                      technology=gsub("Biomass","Bioenergy",technology),
                      technology=gsub("b\\sbiomass","b bioenergy",technology),
                      technology=gsub("g\\sBiomass","g Bioenergy",technology),
                      technology=gsub("h\\sBiomass\\sw\\/CCS","h Bioenergy w/CCS",technology),
                      sources = "Sources",
                      origScen = scenario,
                      origQuery = queryx,
                      origValue = value,
                      origUnits = Units,
                      origX = year, subRegion=region,
                      scenario = scenNewNames,
                      units = "Premature Elec Retire Cost (billion 2010 USD)",
                      vintage = paste("Vint_", year, sep = ""),
                      x = year,
                      xLabel = "Year",
                      aggregate = "sum",
                      class1 = technology,
                      classLabel1 = "Fuel",
                      classPalette1 = "pal_metis",
                      class2 = "class2",
                      classLabel2 = "classLabel2",
                      classPalette2 = "classPalette2")%>%
        dplyr::select(scenario, region, subRegion,    param, sources, class1, class2, x, xLabel, vintage, units, value,
                      aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                      origScen, origQuery, origValue, origUnits, origX)%>%
        dplyr::group_by(scenario, region, subRegion,    param, sources,class1,class2, x, xLabel, vintage, units,
                        aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                        origScen, origQuery, origUnits, origX)%>%dplyr::summarize_at(dplyr::vars("value","origValue"),list(~sum(.,na.rm = T)))%>%dplyr::ungroup()%>%
        dplyr::filter(!is.na(value))
    }

    # retPremature_GW
    if(nrow(addition_costs[["annualPrematureRet_GW"]])>0){
      tbl4 <- addition_costs[["annualPrematureRet_GW"]] %>%
        tidyr::gather(key="year",value=value,-Units,-scenario,-region, -subRegion, -agg_tech)%>%
        dplyr::filter(scenario %in% scenOrigNames)%>%
        dplyr::left_join(tibble::tibble(scenOrigNames, scenNewNames), by = c(scenario = "scenOrigNames")) %>%
        dplyr::rename(technology=agg_tech)%>%
        dplyr::mutate(year=as.numeric(year),
                      param = "elecAnnualRetPrematureGW",
                      technology=gsub("biomass","bioenergy",technology),
                      technology=gsub("Biomass","Bioenergy",technology),
                      technology=gsub("b\\sbiomass","b bioenergy",technology),
                      technology=gsub("g\\sBiomass","g Bioenergy",technology),
                      technology=gsub("h\\sBiomass\\sw\\/CCS","h Bioenergy w/CCS",technology),
                      sources = "Sources",
                      origScen = scenario,
                      origQuery = queryx,
                      origValue = value,
                      origUnits = Units,
                      origX = year, subRegion=region,
                      scenario = scenNewNames,
                      units = "Premature Elec Retire (GW)",
                      vintage = paste("Vint_", year, sep = ""),
                      x = year,
                      xLabel = "Year",
                      aggregate = "sum",
                      class1 = technology,
                      classLabel1 = "Fuel",
                      classPalette1 = "pal_metis",
                      class2 = "class2",
                      classLabel2 = "classLabel2",
                      classPalette2 = "classPalette2")%>%
        dplyr::select(scenario, region, subRegion,    param, sources, class1, class2, x, xLabel, vintage, units, value,
                      aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                      origScen, origQuery, origValue, origUnits, origX)%>%
        dplyr::group_by(scenario, region, subRegion,    param, sources,class1,class2, x, xLabel, vintage, units,
                        aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                        origScen, origQuery, origUnits, origX)%>%dplyr::summarize_at(dplyr::vars("value","origValue"),list(~sum(.,na.rm = T)))%>%dplyr::ungroup()%>%
        dplyr::filter(!is.na(value))
    }

    # newCap_cost
    if(nrow(addition_costsWhydro[["cumCap_cost"]])>0){
      tbl5 <- addition_costsWhydro[["cumCap_cost"]] %>%
        tidyr::gather(key="year",value=value,-Units,-scenario,-region, -subRegion, -agg_tech)%>%
        dplyr::filter(scenario %in% scenOrigNames)%>%
        dplyr::left_join(tibble::tibble(scenOrigNames, scenNewNames), by = c(scenario = "scenOrigNames")) %>%
        dplyr::rename(technology=agg_tech)%>%
        dplyr::mutate(year=as.numeric(year),
                      param = "elecCumCapCost",
                      technology=gsub("biomass","bioenergy",technology),
                      technology=gsub("Biomass","Bioenergy",technology),
                      technology=gsub("b\\sbiomass","b bioenergy",technology),
                      technology=gsub("g\\sBiomass","g Bioenergy",technology),
                      technology=gsub("h\\sBiomass\\sw\\/CCS","h Bioenergy w/CCS",technology),
                      sources = "Sources",
                      origScen = scenario,
                      origQuery = queryx,
                      origValue = value,
                      origUnits = Units,
                      origX = year, subRegion=region,
                      scenario = scenNewNames,
                      units = "New Elec Cap Cost (billion 2010 USD)",
                      vintage = paste("Vint_", year, sep = ""),
                      x = year,
                      xLabel = "Year",
                      aggregate = "sum",
                      class1 = technology,
                      classLabel1 = "Fuel",
                      classPalette1 = "pal_metis",
                      class2 = "class2",
                      classLabel2 = "classLabel2",
                      classPalette2 = "classPalette2")%>%
        dplyr::select(scenario, region, subRegion,    param, sources, class1, class2, x, xLabel, vintage, units, value,
                      aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                      origScen, origQuery, origValue, origUnits, origX)%>%
        dplyr::group_by(scenario, region, subRegion,    param, sources,class1,class2, x, xLabel, vintage, units,
                        aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                        origScen, origQuery, origUnits, origX)%>%dplyr::summarize_at(dplyr::vars("value","origValue"),list(~sum(.,na.rm = T)))%>%dplyr::ungroup()%>%
        dplyr::filter(!is.na(value))
    }

    # newCap_GW
    if(nrow(addition_costs[["cumCap_GW"]])>0){
      tbl6 <- addition_costs[["cumCap_GW"]] %>%
        tidyr::gather(key="year",value=value,-Units,-scenario,-region, -subRegion, -agg_tech)%>%
        dplyr::filter(scenario %in% scenOrigNames)%>%
        dplyr::left_join(tibble::tibble(scenOrigNames, scenNewNames), by = c(scenario = "scenOrigNames")) %>%
        dplyr::rename(technology=agg_tech)%>%
        dplyr::mutate(year=as.numeric(year),
                      param = "elecCumCapGW",
                      technology=gsub("biomass","bioenergy",technology),
                      technology=gsub("Biomass","Bioenergy",technology),
                      technology=gsub("b\\sbiomass","b bioenergy",technology),
                      technology=gsub("g\\sBiomass","g Bioenergy",technology),
                      technology=gsub("h\\sBiomass\\sw\\/CCS","h Bioenergy w/CCS",technology),
                      sources = "Sources",
                      origScen = scenario,
                      origQuery = queryx,
                      origValue = value,
                      origUnits = Units,
                      origX = year, subRegion=region,
                      scenario = scenNewNames,
                      units = "New Elec Cap (GW)",
                      vintage = paste("Vint_", year, sep = ""),
                      x = year,
                      xLabel = "Year",
                      aggregate = "sum",
                      class1 = technology,
                      classLabel1 = "Fuel",
                      classPalette1 = "pal_metis",
                      class2 = "class2",
                      classLabel2 = "classLabel2",
                      classPalette2 = "classPalette2")%>%
        dplyr::select(scenario, region, subRegion,    param, sources, class1, class2, x, xLabel, vintage, units, value,
                      aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                      origScen, origQuery, origValue, origUnits, origX)%>%
        dplyr::group_by(scenario, region, subRegion,    param, sources,class1,class2, x, xLabel, vintage, units,
                        aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                        origScen, origQuery, origUnits, origX)%>%dplyr::summarize_at(dplyr::vars("value","origValue"),list(~sum(.,na.rm = T)))%>%dplyr::ungroup()%>%
        dplyr::filter(!is.na(value))
    }


    # retPremature_cost
    if(nrow(addition_costs[["cumPrematureRet_cost"]])>0){
      tbl7 <- addition_costs[["cumPrematureRet_cost"]] %>%
        tidyr::gather(key="year",value=value,-Units,-scenario,-region, -subRegion, -agg_tech)%>%
        dplyr::filter(scenario %in% scenOrigNames)%>%
        dplyr::left_join(tibble::tibble(scenOrigNames, scenNewNames), by = c(scenario = "scenOrigNames")) %>%
        dplyr::rename(technology=agg_tech)%>%
        dplyr::mutate(year=as.numeric(year),
                      param = "elecCumRetPrematureCost",
                      technology=gsub("biomass","bioenergy",technology),
                      technology=gsub("Biomass","Bioenergy",technology),
                      technology=gsub("b\\sbiomass","b bioenergy",technology),
                      technology=gsub("g\\sBiomass","g Bioenergy",technology),
                      technology=gsub("h\\sBiomass\\sw\\/CCS","h Bioenergy w/CCS",technology),
                      sources = "Sources",
                      origScen = scenario,
                      origQuery = queryx,
                      origValue = value,
                      origUnits = Units,
                      origX = year, subRegion=region,
                      scenario = scenNewNames,
                      units = "Premature Elec Retire Cost (billion 2010 USD)",
                      vintage = paste("Vint_", year, sep = ""),
                      x = year,
                      xLabel = "Year",
                      aggregate = "sum",
                      class1 = technology,
                      classLabel1 = "Fuel",
                      classPalette1 = "pal_metis",
                      class2 = "class2",
                      classLabel2 = "classLabel2",
                      classPalette2 = "classPalette2")%>%
        dplyr::select(scenario, region, subRegion,    param, sources, class1, class2, x, xLabel, vintage, units, value,
                      aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                      origScen, origQuery, origValue, origUnits, origX)%>%
        dplyr::group_by(scenario, region, subRegion,    param, sources,class1,class2, x, xLabel, vintage, units,
                        aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                        origScen, origQuery, origUnits, origX)%>%dplyr::summarize_at(dplyr::vars("value","origValue"),list(~sum(.,na.rm = T)))%>%dplyr::ungroup()%>%
        dplyr::filter(!is.na(value))
    }

    # retPremature_GW
    if(nrow(addition_costs[["cumPrematureRet_GW"]])>0){
      tbl8 <- addition_costs[["cumPrematureRet_GW"]] %>%
        tidyr::gather(key="year",value=value,-Units,-scenario,-region, -subRegion, -agg_tech)%>%
        dplyr::filter(scenario %in% scenOrigNames)%>%
        dplyr::left_join(tibble::tibble(scenOrigNames, scenNewNames), by = c(scenario = "scenOrigNames")) %>%
        dplyr::rename(technology=agg_tech)%>%
        dplyr::mutate(year=as.numeric(year),
                      param = "elecCumRetPrematureGW",
                      technology=gsub("biomass","bioenergy",technology),
                      technology=gsub("Biomass","Bioenergy",technology),
                      technology=gsub("b\\sbiomass","b bioenergy",technology),
                      technology=gsub("g\\sBiomass","g Bioenergy",technology),
                      technology=gsub("h\\sBiomass\\sw\\/CCS","h Bioenergy w/CCS",technology),
                      sources = "Sources",
                      origScen = scenario,
                      origQuery = queryx,
                      origValue = value,
                      origUnits = Units,
                      origX = year, subRegion=region,
                      scenario = scenNewNames,
                      units = "Premature Elec Retire (GW)",
                      vintage = paste("Vint_", year, sep = ""),
                      x = year,
                      xLabel = "Year",
                      aggregate = "sum",
                      class1 = technology,
                      classLabel1 = "Fuel",
                      classPalette1 = "pal_metis",
                      class2 = "class2",
                      classLabel2 = "classLabel2",
                      classPalette2 = "classPalette2")%>%
        dplyr::select(scenario, region, subRegion,    param, sources, class1, class2, x, xLabel, vintage, units, value,
                      aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                      origScen, origQuery, origValue, origUnits, origX)%>%
        dplyr::group_by(scenario, region, subRegion,    param, sources,class1,class2, x, xLabel, vintage, units,
                        aggregate, classLabel1, classPalette1,classLabel2, classPalette2,
                        origScen, origQuery, origUnits, origX)%>%dplyr::summarize_at(dplyr::vars("value","origValue"),list(~sum(.,na.rm = T)))%>%dplyr::ungroup()%>%
        dplyr::filter(!is.na(value))
    }

    datax <- dplyr::bind_rows(datax, tbl1,tbl2,tbl3,tbl4,tbl5,tbl6,tbl7,tbl8)
  } else {
    # if(queryx %in% queriesSelectx){print(paste("Query '", queryx, "' not found in database", sep = ""))}
  }



  if(nrow(datax)>0){

    datax<-datax%>%unique()

    # -----------
    # Region Name Modifications
    # -----------
    datax <- datax %>%
      dplyr::mutate(region = gsub("-", "_", region),
                    # To make consistent with maps (see ./metis/extras/metis.saveDataFile.R)
                    subRegion = gsub("-", "_", subRegion)) %>% # To make consistent with maps (see ./metis/extras/metis.saveDataFile.R)
      dplyr::filter(param %in% paramsSelectx) %>%
      unique()

    # metis.chart(tbl,xData="x",yData="value",useNewLabels = 0)

    # Check
    # unique(datax$param)%>%sort();unique(datax$scenario)%>%sort()
    # datax%>%as.data.frame()%>%dplyr::select(scenario,class1,class2,x,param,value)%>%
    # dplyr::filter(x %in% c(2010:2050),param=="elecNewCapGW",scenario=="GCAMRef")%>%
    # dplyr::group_by(scenario,x)%>%dplyr::summarize(sum=sum(value))

    #---------------------
    # Create Data Template
    #---------------------

    dataTemplate <- datax %>%
      dplyr::mutate(scenario = "Local Data", value = 0, sources="Sources", x=2010) %>%
      dplyr::select(scenario, region, subRegion,    sources, param, units, class1,class2, x, value) %>%
      unique()

    fullTemplateMap <- datax %>%
      dplyr::select(units, param, class1, class2, units, xLabel, aggregate,
                    classLabel1, classPalette1, classLabel2, classPalette2) %>%
      unique()



    #---------------------
    # Save Data in CSV
    #---------------------

    if(!all(regionsSelect %in% unique(datax$region))){
      print(paste("Regions not available in data: ", paste(regionsSelect[!(regionsSelect %in% unique(datax$region))],collapse=", "), sep=""))
      print(paste("Running remaining regions: ",  paste(regionsSelect[(regionsSelect %in% unique(datax$region))],collapse=", "), sep=""))
    }


    if (!dir.exists(paste(getwd(),"/dataFiles", sep = ""))){
      dir.create(paste(getwd(),"/dataFiles", sep = ""))}  # dataFiles directory (should already exist)
    if (!dir.exists(paste(getwd(),"/dataFiles/mapping", sep = ""))){
      dir.create(paste(getwd(),"/dataFiles/mapping", sep = ""))}  # mapping directory

    if(saveData){
      # Template Maps
      if (file.exists(paste(getwd(),"/dataFiles/mapping/template_mapping.csv", sep = ""))){
        fullTemplateMapExisting <- data.table::fread(file=paste(getwd(),"/dataFiles/mapping/template_mapping.csv", sep = ""),encoding="Latin-1")
        fullTemplateMap <- fullTemplateMap %>% dplyr::bind_rows(fullTemplateMapExisting) %>% unique()
      }

      utils::write.csv(fullTemplateMap, file = paste(getwd(),"/dataFiles/mapping/template_mapping.csv", sep = ""),row.names = F)

      # All Data
      utils::write.csv(datax, file = paste(dirOutputs, "/", folderName, "/readGCAM/Tables_gcam/gcamDataTable",nameAppend, ".csv", sep = ""), row.names = F)
      print(paste("GCAM data table saved to: ",
                  gsub("//","/",paste(dirOutputs, "/", folderName, "/readGCAM/Tables_gcam/gcamDataTable",nameAppend,".csv", sep = ""))))
      utils::write.csv(dataTemplate, file = paste(dirOutputs, "/", folderName, "/readGCAM/Tables_Templates/template_gcamDataTable",
                                                  nameAppend,".csv", sep = ""),row.names = F)
      #print(paste("GCAM data template saved to: ", paste(dirOutputs, "/", folderName, "/readGCAM/Tables_Templates/template_",nameAppend,".csv", sep = "")))
    }

    # Aggregate across Class 2
    dataxAggsums <- datax %>%
      dplyr::filter(aggregate == "sum") %>%
      dplyr::select(-c(class1, classLabel1, classPalette1)) %>%
      dplyr::group_by_at(dplyr::vars(-value, -origValue)) %>%
      dplyr::summarize_at(c("value"), list( ~ sum(., na.rm = T)))
    dataxAggmeans <- datax %>%
      dplyr::filter(aggregate == "mean") %>%
      dplyr::select(-c(class1, classLabel1, classPalette1)) %>%
      dplyr::group_by_at(dplyr::vars(-value, -origValue)) %>%
      dplyr::summarize_at(c("value"), list( ~ mean(., na.rm = T)))
    dataxAggClass <-
      dplyr::bind_rows(dataxAggsums, dataxAggmeans) %>% dplyr::ungroup()

    dataAggClass2 <- dataxAggClass %>% dplyr::rename(class = class2,
                                                     classLabel = classLabel2,
                                                     classPalette = classPalette2)

    if(saveData){
      utils::write.csv(dataxAggClass %>% dplyr::rename(class=class2,classLabel=classLabel2,classPalette=classPalette2),
                       file = gsub("//","/",paste(dirOutputs, "/", folderName,
                                                  "/readGCAM/Tables_gcam/gcamDataTable_aggClass2",
                                                  nameAppend,".csv", sep = "")),row.names = F)

      print(paste("GCAM data aggregated to class 2 saved to: ",gsub("//","/",paste(dirOutputs, "/", folderName,
                                                                                   "/readGCAM/Tables_gcam/gcamDataTable_aggClass2",
                                                                                   nameAppend,".csv", sep = "")),sep=""))

      dataTemplateAggClass <- dataxAggClass  %>% dplyr::rename(class=class2,classLabel=classLabel2,classPalette=classPalette2) %>%
        dplyr::mutate(scenario = "Local Data", value = 0, sources="Sources", x=2010) %>%
        dplyr::select(scenario, region, subRegion,    sources, param, units, class,x, value) %>%
        unique()

      utils::write.csv(dataTemplateAggClass, file = paste(dirOutputs, "/", folderName, "/readGCAM/Tables_Templates/template_AggClass2",nameAppend,".csv", sep = ""),
                       row.names = F)
      #print(paste("GCAM data template aggregated to class 2 saved to: ", paste(dirOutputs, "/", folderName, "/readGCAM/Tables_Templates/template_AggClass2",nameAppend,".csv", sep = "")))
    }

    # Aggregate across Class 1
    dataxAggsums <- datax %>%
      dplyr::filter(aggregate == "sum") %>%
      dplyr::select(-c(class2, classLabel2, classPalette2)) %>%
      dplyr::group_by_at(dplyr::vars(-value, -origValue)) %>%
      dplyr::summarize_at(c("value"), list( ~ sum(., na.rm = T)))
    dataxAggmeans <- datax %>%
      dplyr::filter(aggregate == "mean") %>%
      dplyr::select(-c(class2, classLabel2, classPalette2)) %>%
      dplyr::group_by_at(dplyr::vars(-value, -origValue)) %>%
      dplyr::summarize_at(c("value"), list( ~ mean(., na.rm = T)))
    dataxAggClass <-
      dplyr::bind_rows(dataxAggsums, dataxAggmeans) %>% dplyr::ungroup()

    dataAggClass1 <- dataxAggClass %>% dplyr::rename(class = class1,
                                                     classLabel = classLabel1,
                                                     classPalette = classPalette1)

    if(saveData){

      utils::write.csv(dataxAggClass  %>% dplyr::rename(class=class1,classLabel=classLabel1,classPalette=classPalette1),
                       file = gsub("//","/",paste(dirOutputs, "/", folderName,
                                                  "/readGCAM/Tables_gcam/gcamDataTable_aggClass1",
                                                  nameAppend,".csv", sep = "")),row.names = F)

      print(paste("GCAM data aggregated to class 1 saved to: ",gsub("//","/",paste(dirOutputs, "/", folderName,
                                                                                   "/readGCAM/Tables_gcam/gcamDataTable_aggClass1",
                                                                                   nameAppend,".csv", sep = "")),sep=""))

      dataTemplateAggClass <- dataxAggClass  %>% dplyr::rename(class=class1,classLabel=classLabel1,classPalette=classPalette1) %>%
        dplyr::mutate(scenario = "Local Data", value = 0, sources="Sources", x=2010) %>%
        dplyr::select(scenario, region, subRegion,    sources, param, units, class,x, value) %>%
        unique()

      utils::write.csv(dataTemplateAggClass, file = paste(dirOutputs, "/", folderName, "/readGCAM/Tables_Templates/template_AggClass1",nameAppend,".csv", sep = ""),
                       row.names = F)
      #print(paste("GCAM data template aggregated to class 1 saved to: ", paste(dirOutputs, "/", folderName, "/readGCAM/Tables_Templates/template_AggClass1",nameAppend,".csv", sep = "")))
    }

    # Aggregate across Param
    dataxAggsums <- datax %>%
      dplyr::filter(aggregate == "sum") %>%
      dplyr::select(-c(class2, classLabel2, classPalette2, class1, classLabel1)) %>%
      dplyr::group_by_at(dplyr::vars(-value, -origValue)) %>%
      dplyr::summarize_at(c("value"), list( ~ sum(., na.rm = T)))
    dataxAggmeans <- datax %>%
      dplyr::filter(aggregate == "mean") %>%
      dplyr::select(-c(class2, classLabel2, classPalette2, class1, classLabel1)) %>%
      dplyr::group_by_at(dplyr::vars(-value, -origValue)) %>%
      dplyr::summarize_at(c("value"), list( ~ mean(., na.rm = T)))
    dataxAggClass <-
      dplyr::bind_rows(dataxAggsums, dataxAggmeans) %>% dplyr::ungroup()

    dataAggParam <- dataxAggClass %>% dplyr::rename(classPalette = classPalette1)

    if(saveData){
      utils::write.csv(dataxAggClass %>% dplyr::rename(classPalette=classPalette1),
                       file = gsub("//","/",paste(dirOutputs, "/", folderName,
                                                  "/readGCAM/Tables_gcam/gcamDataTable_aggParam",
                                                  nameAppend,".csv", sep = "")),row.names = F)


      print(paste("GCAM data aggregated to param saved to: ",gsub("//","/",paste(dirOutputs, "/", folderName,
                                                                                 "/readGCAM/Tables_gcam/gcamDataTable_aggParam",
                                                                                 nameAppend,".csv", sep = "")),sep=""))

      dataTemplateAggClass <- dataxAggClass %>%
        dplyr::mutate(scenario = "Local Data", value = 0, sources="Sources", x=2010) %>%
        dplyr::select(scenario, region, subRegion,    sources, param, units, x, value) %>%
        unique()


      utils::write.csv(dataTemplateAggClass, file = paste(dirOutputs, "/", folderName, "/readGCAM/Tables_Templates/template_AggParam",nameAppend,".csv", sep = ""),
                       row.names = F)

    }

  } else{
    print("No data for any of the regions, params or queries selected")
  } # Close datax nrow check

print("Outputs returned as list containing data, dataTemplate, scenarios and queries.")
# print("For example if df <- metis.readgcam(dataProjFile = metis::exampleGCAMproj)")
# print("Then you can view the outputs as df$data, df$dataAggClass1, df$dataAggClass2, df$dataAggParam, df$dataTemplate, df$scenarios, df$queries.")
# print(gsub("//","/",paste("All outputs in : ",dirOutputs, "/", folderName, "/readGCAM/",sep="")))
print("gcamInvest run completed.")

return(list(data = datax,
            dataAggClass1 = dataAggClass1,
            dataAggClass2 = dataAggClass2,
            dataAggParam = dataAggParam,
            dataTemplate = dataTemplate,
            scenarios = scenarios,
            queries = queries))

}
