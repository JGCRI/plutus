#' elecInvest
#'
#' Function that calculates electricity subsector investment requirements from a given GCAM run.
#'
#' @param elec_gen_vintage Electricity vintage query result
#' @param gcamdataFile Default = NULL. Optional. For example, gcamdataFile = "~/gcam-core-gcam-v5.3/input/gcamdata".
#' @param start_year Start year of time frame of interest for analysis
#' @param end_year end_year of time frame of interest for analysis
#' @param world_regions GCAM regions for which to collect data
#' @keywords investments, infrastructure
#' @return Returns data in a form required by plutus::gcamInvest.R
#' @export

elecInvest <- function(elec_gen_vintage, gcamdataFile, world_regions, start_year=2015, end_year=2050) {


  #----------------
  # Initialize variables by setting to NULL
  #----------------

  NULL -> year -> technology -> wtechnology -> sector.name -> subsector.name ->
    intermittent.technology -> capacity.factor -> capacity.factor.region -> sector ->
    Year -> value -> scenario -> region -> subsector -> Units -> temp ->
    prev_year -> retirements -> supplysector -> half.life -> steepness -> lifetime ->
    s_curve_adj -> OG_gen -> gen_expect -> prev_yr_expect -> additions -> add_adj ->
    ret_adj -> ret_adj_OG -> natural_retire -> input.capital -> fixed.charge.rate ->
    add_GW -> capital.overnight -> early_ret -> early_ret_GW -> agg_tech ->
    cap_invest -> unrec_Cap -> dep_factor -> unrec_cap -> stub.technology ->
    capacity.factor.global -> capacity.factor.global_int -> capital.overnight.cool ->
    capital.overnight.elec -> subsector.name.elec -> old.technology

  if(is.null(world_regions)){
    world_regions <- unique(elec_gen_vintage$region)
  }

  # ============================================================================
  # Exclude rooftop PV
  elec_gen_vintage <- elec_gen_vintage %>%
    dplyr::filter(!subsector %in% 'rooftop_pv')

  # ============================================================================
  # Mapping files

  years_mapping <- data.frame(year = c(rep("final-calibration-year", 1),
                                       rep("initial-future-year", length(seq(plutus::assumptions("GCAMbaseYear") + 5, 2100, by = 5)))),
                              vintage = c(plutus::assumptions("GCAMbaseYear"),
                                          seq(plutus::assumptions("GCAMbaseYear") + 5, 2100, by = 5)))%>%
    dplyr::mutate(year=as.character(year));years_mapping


  # Read gcam data files from user provided path
  if(!is.null(gcamdataFile)){
    if(!dir.exists(gcamdataFile)){
      warning(gsub('//', '/', paste('WARNING: Folder ', gcamdataFile, ' does not exist.', sep = '')))
      gcamdataFile <- NULL
    }else{
      file_names <- c('A23.globaltech_retirement.csv',
                      'L223.GlobalTechCapFac_elec.csv',
                      'L223.GlobalIntTechCapFac_elec.csv',
                      'L223.StubTechCapFactor_elec.csv',
                      'L2233.GlobalIntTechCapital_elec.csv',
                      'L2233.GlobalIntTechCapital_elec_cool.csv',
                      'L2233.GlobalTechCapital_elec_cool.csv',
                      'L2233.GlobalTechCapital_elecPassthru.csv')
      data_files <- list.files(path = gcamdataFile, pattern = paste(file_names, collapse = '|'), recursive = TRUE, full.names = TRUE)
      if(any(!file.exists(data_files)) | (length(file_names) != length(data_files))){
        missing_files <- setdiff(file_names, basename(data_files))
        warning(paste('WARNING: One or more required data files are missing:', missing_files))
        gcamdataFile <- NULL
      }else{
        print('------------------------------------------------------------------')
        print('Reading data and assumptions from user provided gcamdata folder:')
        print('------------------------------------------------------------------')
        print(gsub('//', '/', paste(data_files)))
        A23.globaltech_retirement <- data.table::fread(data_files[1], skip=1)
        capac_fac <- data.table::fread(data_files[2], skip=1, stringsAsFactors = FALSE)
        capaC_fac_int <- data.table::fread(data_files[3], skip=1, stringsAsFactors = FALSE)
        capac_fac_region <- data.table::fread(data_files[4], skip=1, stringsAsFactors = FALSE)
        cap_cost_int_tech <- data.table::fread(data_files[5], skip=1, stringsAsFactors = FALSE)
        cap_cost_int_cool <- data.table::fread(data_files[6], skip=1, stringsAsFactors = FALSE)
        cap_cost_cool <- data.table::fread(data_files[7], skip=1, stringsAsFactors = FALSE)
        cap_cost_tech <- data.table::fread(data_files[8], skip=1, stringsAsFactors = FALSE)

      }
    }
  }

  if(is.null(gcamdataFile)){
    print('---------------------------------------')
    print('Using default data and assumptions ...')
    print('---------------------------------------')
    A23.globaltech_retirement <- plutus::data_A23.globaltech_retirement
    capac_fac <- plutus::data_capac_fac
    capac_fac_int <- plutus::data_capac_fac_int
    capac_fac_region <- plutus::data_capac_fac_region
    cap_cost_int_tech <- plutus::data_cap_cost_int_tech
    cap_cost_int_cool <- plutus::data_cap_cost_int_cool
    cap_cost_cool <- plutus::data_cap_cost_cool
    cap_cost_tech <- plutus::data_cap_cost_tech

  }


  s_curve_shutdown <- tibble::as_tibble(A23.globaltech_retirement)%>%
    dplyr::mutate(year=dplyr::if_else(year=="final-historical-year","final-calibration-year",year),
                  year=dplyr::if_else(year=="initial-nonhistorical-year","initial-future-year",year)); s_curve_shutdown


  # Add water cooling technologies if they dont exist
  waterTechs <- s_curve_shutdown %>% dplyr::select(technology); waterTechs
  if(any(!grepl("once through",unique(waterTechs$technology),ignore.case = T))){
    waterTechsCooling <- waterTechs %>% dplyr::mutate(wtechnology=paste(technology," (dry cooling)",sep="")) %>%
      dplyr::bind_rows(waterTechs %>% dplyr::mutate(wtechnology=paste(technology," (once through)",sep=""))) %>%
      dplyr::bind_rows(waterTechs %>% dplyr::mutate(wtechnology=paste(technology," (recirculating)",sep=""))) %>%
      dplyr::bind_rows(waterTechs %>% dplyr::mutate(wtechnology=paste(technology," (seawater)",sep=""))) %>%
      dplyr::bind_rows(waterTechs %>% dplyr::mutate(wtechnology=paste(technology," (cooling pond)",sep=""))) %>%
      dplyr::bind_rows(waterTechs %>% dplyr::mutate(wtechnology=paste(technology," (dry_hybrid)",sep=""))) %>%
      dplyr::bind_rows(waterTechs %>% dplyr::mutate(wtechnology=paste(technology,"",sep="")))
  }else{waterTechsCooling <- waterTechs %>% dplyr::mutate(wtechnology=technology)}

  s_curve_shutdown <- s_curve_shutdown %>%
    dplyr::left_join(waterTechsCooling, by = "technology") %>%
    dplyr::mutate(technology = wtechnology) %>%
    dplyr::select(-wtechnology)

  # ============================================================================
  # Combine the cooling technology cost sheets, and the electricity generating technology cost dataframes
  elec_gen_tech_cost <- rbind(cap_cost_tech, cap_cost_int_tech)
  # Get dispatchable capacity factor column added to elec_gen_tech_cost
  capac_fac %>% dplyr::select(-sector.name, -subsector.name) -> capac_fac_new
  elec_gen_tech_cost <- merge(elec_gen_tech_cost, capac_fac_new, by=c("technology", "year"), all=TRUE)

  df_elec_gen <- data.frame(region = rep(x = world_regions, each = nrow(elec_gen_tech_cost)),
                            technology = rep(x = elec_gen_tech_cost$technology, times = length(world_regions)),
                            year = rep(x = elec_gen_tech_cost$year, times = length(world_regions)))
  elec_gen_tech_cost_global <- df_elec_gen %>%
    dplyr::left_join(elec_gen_tech_cost, by = c('technology', 'year')) %>%
    dplyr::left_join(capac_fac_int,
                     by = c('sector.name', 'subsector.name', 'technology' = 'intermittent.technology', 'year'),
                     suffix = c('.global', '.global_int')) %>%
    dplyr::mutate(capacity.factor = dplyr::if_else(!is.na(capacity.factor.global), capacity.factor.global, capacity.factor.global_int)) %>%
    dplyr::mutate(capacity.factor = dplyr::if_else(technology == 'wind_offshore' & is.na(capacity.factor),
                                           plutus::assumptions('wind_offshore_cap_fact'), capacity.factor)) %>%
    dplyr::select(-capacity.factor.global, -capacity.factor.global_int)

  # Get intermittent capacity factor column added to elec_gen_tech_cost
  capac_fac_int_new <- capac_fac_region %>%
    dplyr::rename(sector.name = supplysector,
                  subsector.name = subsector,
                  technology = stub.technology,
                  capacity.factor.region = capacity.factor) %>%
    dplyr::filter(region %in% world_regions) %>%
    dplyr::select(-sector.name, -subsector.name)

  elec_gen_tech_cost <- elec_gen_tech_cost_global %>%
    dplyr::left_join(capac_fac_int_new, by = c('region', 'technology', 'year'))

  elec_gen_tech_cost <- elec_gen_tech_cost %>%
    dplyr::mutate(capacity.factor = dplyr::if_else(is.na(capacity.factor.region), capacity.factor, capacity.factor.region)) %>%
    dplyr::select(-capacity.factor.region) %>%
    dplyr::relocate(region, sector.name, subsector.name, technology, year, input.capital, capital.overnight, fixed.charge.rate, capacity.factor)




  cool_tech_cost_temp <- rbind(cap_cost_cool, cap_cost_int_cool)
  df_cooling <- data.frame(region = rep(x = world_regions, each = nrow(cool_tech_cost_temp)),
                           technology = rep(x = cool_tech_cost_temp$technology, times = length(world_regions)),
                           year = rep(x = cool_tech_cost_temp$year, times = length(world_regions)))
  cool_tech_cost <- df_cooling %>%
    dplyr::left_join(cool_tech_cost_temp, by = c('technology', 'year'))

  # Add capital overnight cost from cooling technology to electricity generation technology
  cool_tech_cost <- cool_tech_cost %>%
    dplyr::left_join(elec_gen_tech_cost %>%
                       dplyr::select(region, subsector.name, technology, year, capital.overnight, capacity.factor),
                     by = c('region', 'subsector.name'='technology', 'year'),
                     suffix = c('.cool', '.elec')) %>%
    dplyr::mutate(capital.overnight = capital.overnight.cool + capital.overnight.elec) %>%
    dplyr::rename(old.technology = subsector.name,
                  subsector.name = subsector.name.elec) %>%
    dplyr::select(region, technology, year, sector.name, subsector.name, input.capital,
                  capital.overnight, fixed.charge.rate, capacity.factor, old.technology)

  cap_cost <- cool_tech_cost
  A <- unique(cool_tech_cost$old.technology)
  B <- unique(elec_gen_tech_cost$technology)
  C <- setdiff(B,A) # the technolgies being used in elec_gen_tech_cost, but not included in cooling tech
  D <- dplyr::filter(elec_gen_tech_cost, technology %in% C)
  D[,'old.technology'] <- NA
  cap_cost <- rbind(cap_cost, D)

  tech_mapping <- plutus::data_tech_mapping


  # ============================================================================
  # dplyr::filter scenarios that meet the cumulative emissions budgets

  elec_gen_vintage %>%
    dplyr::select(-sector)%>%
    tidyr::gather(Year, value, - scenario, -region, -subsector, -technology, -Units) %>%
    dplyr::mutate(Year = gsub('X', '', Year)) %>%
    dplyr::mutate(Year = as.numeric(Year)) %>%
    dplyr::mutate(value = as.numeric(value)) %>%
    tidyr::separate(technology, c("technology", "temp"), sep = ",") %>%
    tidyr::separate(temp, c("temp", "vintage"), sep = "=") %>%
    dplyr::select(-temp) %>%
    dplyr::mutate(vintage = as.numeric(vintage)) %>%
    dplyr::filter(region %in% world_regions, Year <= end_year, vintage >= plutus::assumptions("GCAMbaseYear"),
                  vintage <= end_year, Year >= vintage) -> elec_vintage

  # ============================================================================
  # Calculate s-curve output fraction
  # Hydro assumed to never retire, lifetime set to 110 years (hitting error, for now hydro is NA)
  # Wind and Solar are assumed never retire as well (MZ)
  elec_vintage %>%
    dplyr::left_join(years_mapping, by = c("vintage")) %>%
    dplyr::left_join(s_curve_shutdown %>% dplyr::select(-supplysector),
                     by = c("subsector", "technology", "year")) %>%
    # dplyr::mutate(lifetime = dplyr::if_else(technology == "hydro", 110, lifetime)) %>%
    dplyr::mutate(half.life = as.numeric(half.life),
                  steepness = as.numeric(steepness),
                  half.life = dplyr::if_else(is.na(half.life), 0, half.life),
                  steepness = dplyr::if_else(is.na(steepness), 0, steepness),
                  s_curve_frac = dplyr::if_else(Year > vintage & half.life != 0,
                                                (1 / (1 + exp( steepness * ((Year - vintage) - half.life )))),
                                                1)) %>%
    unique()-> s_curve_frac

  # Adjust s-curve output fraction to ensure that all of the capacity is retired at the end of lifetime
  s_curve_frac %>%
    dplyr::mutate(s_curve_adj = dplyr::if_else(Year - vintage >= lifetime, 0, s_curve_frac),
                  s_curve_adj = dplyr::if_else(is.na(s_curve_adj), 1, s_curve_adj)) %>%
    dplyr::select(scenario, region, subsector, technology, vintage, Units, Year, value, s_curve_adj) -> s_curve_frac_adj

  # Expected generation assuming natural shutdowns only
  # Create variable reflecting each tech/ vintage generation in year of installment (OG_gen)
  s_curve_frac_adj %>%
    dplyr::left_join(elec_vintage %>%
                       dplyr::filter(vintage == Year) %>%
                       dplyr::select(-Year) %>%
                       dplyr::rename(OG_gen = value),
                     by = c("scenario", "region", "subsector", "technology", "vintage", "Units")) %>%
    dplyr::mutate(gen_expect = OG_gen * s_curve_adj) -> elec_gen_expect


  # Expected natural retirements
  elec_gen_expect %>%
    dplyr::group_by(scenario, region, subsector, technology, Units, vintage) %>%
    dplyr::mutate(prev_yr_expect = dplyr::lag(gen_expect, n = 1L),
                  natural_retire = dplyr::if_else(Year > vintage & prev_yr_expect > gen_expect, prev_yr_expect - gen_expect, 0)) %>%
    dplyr::ungroup() -> elec_retire_expect


  # ============================================================================
  # Calculate additions by vintage
  elec_vintage %>%
    dplyr::mutate(additions = dplyr::if_else(vintage == Year, value, 0)) -> elec_vintage_add

  # Calculate retirements by vintage
  elec_vintage %>%
    dplyr::group_by(scenario, region, subsector, technology, Units, vintage) %>%
    dplyr::mutate(prev_year = dplyr::lag(value, n = 1L)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(prev_year = dplyr::if_else(is.na(prev_year), 0, prev_year),
                  retirements = prev_year - value,
                  retirements = dplyr::if_else(retirements < 0, 0, retirements)) %>%
    dplyr::arrange(vintage, technology, region) -> elec_vintage_ret


  # Total additions per region/ technology/ year (in EJ)
  elec_vintage_add %>%
    dplyr::group_by(scenario, region, subsector, technology, Units, Year) %>%
    dplyr::summarise(additions = sum(additions)) %>%
    dplyr::ungroup() -> elec_total_add

  # Total retirements per region/ technology/ year (in EJ)
  elec_vintage_ret %>%
    dplyr::group_by(scenario, region, subsector, technology, Units, Year) %>%
    dplyr::summarise(retirements = sum(retirements)) %>%
    dplyr::ungroup() -> elec_total_ret

  # Adjusted (Net) additions and retirements
  # Merge total additions and retirements data tables
  elec_total_add %>%
    dplyr::left_join(elec_total_ret, by = c("scenario", "region", "subsector", "technology", "Units", "Year")) %>%
    dplyr::mutate(add_adj = dplyr::if_else(additions > retirements, additions - retirements, 0),
                  ret_adj = dplyr::if_else(retirements > additions, retirements - additions, 0)) -> elec_add_ret

  # ============================================================================
  # Assign adjusted retirements to vintages, assuming older vintages retire first
  # Merge retirement by vintage and retirement by year data tables
  elec_vintage_ret %>%
    dplyr::select(-value, -prev_year) %>%
    dplyr::left_join(elec_add_ret %>%
                       dplyr::select(-additions, -retirements, -add_adj),
                     by = c("scenario", "region", "subsector", "technology", "Units", "Year")) -> elec_ret_adj_vintage

  # dplyr::filter years with zero adjusted retirements, set retirements for each vintage to zero
  elec_ret_adj_vintage %>%
    dplyr::filter(ret_adj == 0) %>%
    dplyr::mutate(retirements = ret_adj) -> elec_ret_adj_0

  # dplyr::filter years with non-zero adjusted retirements
  elec_ret_adj_vintage %>%
    dplyr::filter(ret_adj != 0) -> elec_ret_adj

  # Create list of adjusted retirements by technology / year
  elec_ret_adj_vintage %>%
    dplyr::distinct(scenario, region, subsector, technology, Units, Year, ret_adj) -> elec_ret_adj_year

  vintage <- unique(elec_ret_adj_vintage$Year)
  elec_ret_adjust <- dplyr::tibble()

  for (v in vintage) {

    # Assign adjusted retirements to vintages, assuming older vintages retire first
    # retirements will be adjusted to the smaller value between ret_adj and retirements
    # ret_adj will be adjusted to the difference between ret_adj and retirements if the difference >0
    elec_ret_adj %>%
      dplyr::filter(vintage == v) %>%
      dplyr::select(-ret_adj) %>%
      dplyr::left_join(elec_ret_adj_year,
                       by = c("scenario", "region", "subsector", "technology", "Units", "Year")) %>%
      dplyr::mutate(ret_adj = ret_adj - retirements,
                    retirements = dplyr::if_else(ret_adj < 0, retirements + ret_adj, retirements),
                    ret_adj = dplyr::if_else(ret_adj < 0, 0, ret_adj)) -> elec_ret_adj_temp

    elec_ret_adjust %>%
      dplyr::bind_rows(elec_ret_adj_temp) -> elec_ret_adjust

    # Revise list of adjusted retirements by technology / year, removing retirements allocated to vintage v
    elec_ret_adj_year %>%
      dplyr::rename(ret_adj_OG = ret_adj) %>%
      dplyr::left_join(elec_ret_adj_temp %>%
                         dplyr::select(-vintage, -retirements),
                       by = c("scenario", "region", "subsector", "technology", "Units", "Year")) %>%
      dplyr::mutate(ret_adj = dplyr::if_else(is.na(ret_adj), ret_adj_OG, ret_adj)) %>%
      dplyr::select(-ret_adj_OG) -> elec_ret_adj_year

  }

  # Re-bind adjusted retirements data frames
  elec_ret_adjust %>%
    dplyr::select(-ret_adj) %>%
    dplyr::bind_rows(elec_ret_adj_0 %>% dplyr::select(-ret_adj)) %>%
    dplyr::filter(Year >= vintage) -> elec_ret_vintage


  # ============================================================================
  # Subtract expected retirements to calculate premature retirements
  elec_ret_vintage %>%
    dplyr::left_join(elec_retire_expect %>%
                       dplyr::select(scenario, region, subsector, technology, Units, Year, vintage, natural_retire),
                     by = c("scenario", "region", "subsector", "technology", "Units", "Year", "vintage")) %>%
    dplyr::mutate(early_ret = dplyr::if_else(retirements > natural_retire, retirements - natural_retire, 0)) -> elec_ret_premature


  # Calculate final (adjusted) additions in GW /year (8760 hours/yr = 365 days/yr * 24 hours/day)
  elec_add_ret %>%
    dplyr::select(-ret_adj) %>%
    dplyr::left_join(cap_cost %>%
                       dplyr::select(-sector.name, -input.capital, -fixed.charge.rate),
                     by = c("region", "subsector" = "subsector.name", "technology", "Year" = "year")) %>%
    dplyr::mutate(add_GW = (add_adj * plutus::assumptions("convEJ2GWh")) / (8760 * capacity.factor),
                  Units = "GW") -> elec_add_GW

  # Calculate final capital investments in billion 2015 USD
  elec_add_GW %>%
    dplyr::mutate(cap_invest = (add_GW * plutus::assumptions("convGW_kW") * capital.overnight * plutus::assumptions("convUSD_1975_2015")) / 1e9,
                  Units = "billion 2015 USD") -> elec_add_cap_invest

  # Calculate final premature retirements in GW
  # NOTE:  dividing capital costs for 2010 vintages in half
  elec_ret_premature %>%
    dplyr::select(-retirements, -natural_retire) %>%
    dplyr::left_join(cap_cost %>%
                       dplyr::select(-sector.name, -input.capital, -fixed.charge.rate),
                     by = c("region", "subsector" = "subsector.name", "technology", "vintage" = "year")) %>%
    dplyr::mutate(capital.overnight = dplyr::if_else(vintage == 2010, capital.overnight * .5, capital.overnight * 1),
                  early_ret_GW = (early_ret * plutus::assumptions("convEJ2GWh")) / (8760 * capacity.factor),
                  Units = "GW") -> elec_ret_GW

  # Calculate unrecovered capital costs of prematurely retired assets
  # Calculate depreciation factor for prematurely retired assets
  elec_ret_GW %>%
    dplyr::left_join(years_mapping, by = c("vintage")) %>%
    dplyr::left_join(s_curve_shutdown %>%
                       dplyr::select(technology, year, lifetime),
                     by = c("technology", "year")) %>%
    dplyr::mutate(dep_factor = 1 - ((Year - vintage) / lifetime),
                  unrec_cap = (early_ret_GW * plutus::assumptions("convGW_kW") * capital.overnight * dep_factor * plutus::assumptions("convUSD_1975_2015")) / 1e9,
                  Units = "billion 2015 USD") -> elec_ret_cap_cost


  # ============================================================================
  # Constants
  tech_order <- c("Coal", "Coal CCS", "Gas", "Gas CCS", "Oil", "Oil CCS", "Biomass", "Biomass CCS", "Nuclear",
                  "Geothermal", "Hydro", "Wind", "Solar", "CHP", "Battery", "energy reduction")

  # New Cap Costs
  elec_add_cap_invest %>%
    dplyr::left_join(tech_mapping, by = c("technology")) %>%
    dplyr::group_by(scenario, region, Year, Units, agg_tech) %>%
    dplyr::summarise(cap_invest = sum(cap_invest, na.rm = T)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(Year >= start_year) %>%
    dplyr::mutate(cap_invest = dplyr::if_else(Year == plutus::assumptions("GCAMbaseYear"), 0, cap_invest)) %>%
    tidyr::spread(Year, cap_invest) %>%
    dplyr::mutate_all( ~ replace(., is.na(.), 0)) %>%
    dplyr::mutate(agg_tech = factor(agg_tech, levels = tech_order)) %>%
    dplyr::arrange(region, agg_tech) -> newCap_cost

  # Cum Cap Costs
  elec_add_cap_invest %>%
    dplyr::left_join(tech_mapping, by = c("technology")) %>%
    dplyr::group_by(scenario, region, Year, Units, agg_tech) %>%
    dplyr::summarise(cap_invest = sum(cap_invest, na.rm = T)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(Year >= start_year) %>%
    dplyr::mutate(cap_invest = dplyr::if_else(Year == plutus::assumptions("GCAMbaseYear"), 0, cap_invest)) %>%
    dplyr::group_by(scenario, region, Units, agg_tech) %>%
    dplyr::mutate(cap_invest = cumsum(cap_invest)) %>%
    dplyr::ungroup() %>%
    tidyr::spread(Year, cap_invest) %>%
    dplyr::mutate_all( ~ replace(., is.na(.), 0)) %>%
    dplyr::mutate(agg_tech = factor(agg_tech, levels = tech_order)) %>%
    dplyr::arrange(region, agg_tech) -> cumCap_cost

  # New Capacity
  elec_add_GW %>%
    dplyr::left_join(tech_mapping, by = c("technology")) %>%
    dplyr::group_by(scenario, region, Year, Units, agg_tech) %>%
    dplyr::summarise(add_GW = sum(add_GW, na.rm = T)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(Year >= start_year) %>%
    tidyr::spread(Year, add_GW) %>%
    dplyr::mutate_all( ~ replace(., is.na(.), 0)) %>%
    dplyr::mutate(agg_tech = factor(agg_tech, levels = tech_order)) %>%
    dplyr::arrange(region, agg_tech) -> newCap_GW

  # Cumulative Capacity
  elec_add_GW %>%
    dplyr::left_join(tech_mapping, by = c("technology")) %>%
    dplyr::group_by(scenario, region, Year, Units, agg_tech) %>%
    dplyr::summarise(add_GW = sum(add_GW, na.rm = T)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(Year >= start_year) %>%
    dplyr::group_by(scenario, region, Units, agg_tech) %>%
    dplyr::mutate(add_GW = cumsum(add_GW)) %>%
    dplyr::ungroup() %>%
    tidyr::spread(Year, add_GW) %>%
    dplyr::mutate_all( ~ replace(., is.na(.), 0)) %>%
    dplyr::mutate(agg_tech = factor(agg_tech, levels = tech_order)) %>%
    dplyr::arrange(region, agg_tech) -> cumCap_GW

  # Premature retirements by region & technology
  elec_ret_cap_cost %>%
    dplyr::left_join(tech_mapping, by = c("technology")) %>%
    dplyr::group_by(scenario, region, Year, Units, agg_tech) %>%
    dplyr::summarise(unrec_cap = sum(unrec_cap, na.rm = T)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(unrec_cap = unrec_cap * -1) %>%
    dplyr::filter(Year >= start_year) %>%
    dplyr::mutate(unrec_cap = dplyr::if_else(Year == plutus::assumptions("GCAMbaseYear"), 0, unrec_cap)) %>%
    tidyr::spread(Year, unrec_cap) %>%
    dplyr::mutate_all( ~ replace(., is.na(.), 0)) %>%
    dplyr::mutate(agg_tech = factor(agg_tech, levels = tech_order)) %>%
    dplyr::arrange(region, agg_tech) -> annualPrematureRet_cost

  # Cum Premature retirements by region & technology
  elec_ret_cap_cost %>%
    dplyr::left_join(tech_mapping, by = c("technology")) %>%
    dplyr::group_by(scenario, region, Year, Units, agg_tech) %>%
    dplyr::summarise(unrec_cap = sum(unrec_cap, na.rm = T)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(unrec_cap = unrec_cap * -1) %>%
    dplyr::filter(Year >= start_year) %>%
    dplyr::mutate(unrec_cap = dplyr::if_else(Year == plutus::assumptions("GCAMbaseYear"), 0, unrec_cap)) %>%
    dplyr::group_by(scenario, region, Units, agg_tech) %>%
    dplyr::mutate(unrec_cap = cumsum(unrec_cap)) %>%
    dplyr::ungroup() %>%
    tidyr::spread(Year, unrec_cap) %>%
    dplyr::mutate_all( ~ replace(., is.na(.), 0)) %>%
    dplyr::mutate(agg_tech = factor(agg_tech, levels = tech_order)) %>%
    dplyr::arrange(region, agg_tech) -> cumPrematureRet_cost


  # Premature retirements by region & technology
  elec_ret_GW %>%
    dplyr::left_join(tech_mapping, by = c("technology")) %>%
    dplyr::group_by(scenario, region, Year, Units, agg_tech) %>%
    dplyr::summarise(early_ret_GW = sum(early_ret_GW,na.rm=T)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(early_ret_GW = early_ret_GW * -1) %>%
    dplyr::filter(Year >= start_year) %>%
    tidyr::spread(Year, early_ret_GW) %>%
    dplyr::mutate_all(~replace(., is.na(.), 0)) %>%
    dplyr::mutate(agg_tech = factor(agg_tech, levels = tech_order)) %>%
    dplyr::arrange(region, agg_tech) -> annualPrematureRet_GW

  # Cum Premature retirements by region & technology
  elec_ret_GW %>%
    dplyr::left_join(tech_mapping, by = c("technology")) %>%
    dplyr::group_by(scenario, region, Year, Units, agg_tech) %>%
    dplyr::summarise(early_ret_GW = sum(early_ret_GW, na.rm = T)) %>%
    dplyr::ungroup() %>%
    dplyr::filter(Year >= start_year) %>%
    dplyr::group_by(scenario, region, Units, agg_tech) %>%
    dplyr::mutate(early_ret_GW = cumsum(early_ret_GW)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(early_ret_GW = early_ret_GW * -1) %>%
    tidyr::spread(Year, early_ret_GW) %>%
    dplyr::mutate_all( ~ replace(., is.na(.), 0)) %>%
    dplyr::mutate(agg_tech = factor(agg_tech, levels = tech_order)) %>%
    dplyr::arrange(region, agg_tech) -> cumPrematureRet_GW


  # ============================================================================
  return(list("newCap_cost"=newCap_cost,
              "newCap_GW"=newCap_GW,
              "annualPrematureRet_cost"=annualPrematureRet_cost,
              "annualPrematureRet_GW"=annualPrematureRet_GW,
              "cumCap_cost"=cumCap_cost,
              "cumCap_GW"=cumCap_GW,
              "cumPrematureRet_cost"=cumPrematureRet_cost,
              "cumPrematureRet_GW"=cumPrematureRet_GW))

}
