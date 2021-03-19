---
title: 'Plutus: An R package to calculate electricity investments and stranded assets from the Global Change Analysis Model'
tags:
  - R
  - GCAM
  - electricity investments
  - stranded assets
  - premature retirement
authors:
  - name: Mengqi Zhao
    orcid: 0000-0001-5385-2758
    affiliation: 1
  - name: Brinda Yarlagadda
    affiliation: 3
  - name: Tom Wild
    orcid: 0000-0002-6045-7729
    affiliation: "1, 2"
  - name: Zarrar Khan
    orcid: 0000-0002-8147-8553
    affiliation: 2
  - name: Chris Vernon
    orcid: 0000-0002-3406-6214
    affiliation: 4
  - name: Pralit Patel
    affiliation: 4
  - name: Matthew Binsted
    affiliation: 4
  - name: Gokul Lyer
    affiliation: 4
affiliations:
  - name: Earth System Science Interdisciplinary Center (ESSIC), University of Maryland, College Park, MD, USA
    index: 1
  - name: Joint Global Change Research Institute, Pacific Northwest National Laboratory (PNNL), College Park, MD, USA
    index: 2
  - name: School of Public Policy, University of Maryland, College Park, MD, USA
    index: 3
  - name: Pacific Northwest National Laboratory (PNNL), Richland, WA, USA
    index: 4
date: 13 March 2021
bibliography: paper.bib
---

# Summary
Plutus is designed to aid in informed decision-making by exploring economic implications in the power sector under different climate and policy scenarios. Plutus post-processes outputs from the Global Change Analysis Model (GCAM) `@Calvin:2019`, and estimates the electricity investments and stranded assets for the energy sector. The concept and methodology for electricity investments and stranded assets was first introduced in `@Binsted:2020`. GCAM tracks electricity generation by technology and vintage over 32 geopolitical regions throughout the lifetime of each technology. This package extends GCAM functionality by (1) estimating the forgone economic value of prematurely retired power plants as a result of natural and profit-induced retirement; and (2) estimating the new generation capacity installation and capital investements driven by interactions among economic, energy, agriculture, and landuse systems in GCAM.


# Statement of need
The development of plutus was encouraged by the increasing interest in stranded assets and electricity investments from a wide range of GCAM users. Recent examples include the assessment of stranded assets and power sector investments in the context of climate mitigation in Latin America and the Caribbean `[@Binsted:2020; @daSilva:2021]`.**What are other tools comparing with plutus (citations).** A tool with easy access to GCAM output and validated methodology for stranded assets will streamline these otherwise cumbersome analyeses and enhance the GCAM user experience.

To interact with GCAM as well as many other GCAM related tools, plutus allows users to directly use different types of GCAM outputs and generates a data structure that can be incorperated with rmap `@Khan:2021` (in preparation), another R package developed to visualize GCAM output. 


# Design and Implementation
Plutus utilizes capital cost, capacity factor data and assumptions of financial lifetime for electricity generating technologies to calculate stranded assets by scenario, period, and technology. This package is designed for GCAM version 5.3 and up.

## Assumptions
- Lifetime
- Natural retirement for the Baseyear (2015)

## Key Functions
```plutus::elecInvest``` calculates stranded assets and new electricity capacity installation in terms of value (billion $) and energy generation (GW) by scenario, region, period, and technology. The function will take the capital cost, capacity factor data and assumptions of financial lifetime if provided by the user following the format of each data file, otherwise it will use the default dataset collected from GCAM 5.3. The function considers both electricity generation technology and associated cooling system in the overnight capital cost. The function adjusts the retirement for the base/calibration year vintage by the 'S Curve Fraction' function to represent natural retirements for power plants built historically but not retiring properly in the GCAM model.

$$ S \: Curve \: Fraction =  \frac{1}{1+ e^{steepness \times (t-halflife)} } $$

```plutus::hydroInvest``` provides additional calculation for hydropower investment ingored in the ```plutus::elecInvest```. This function will update capital investment in the hydropowwer sector of the output from ```plutus::elecInvest```.

```plutus::gcamInvest``` is the integrated function that reads CGAM output, excutes ```plutus::elecInvest``` and ```plutus::hydroInvest``` functions, and generates output data structure that can be used by rmap `@Khan:2021` (in preparation). This function is developed to connects with GCAM and other tools for post-processesing and  visualization. In addition, ```plutus::gcamInvest``` provides many flexibilities and options depending on users' preference, including the following features.

- Access to different GCAM output database. GCAM output database can be in formats such as ".proj" file or a folder of ".basex" files. ```plutus::gcamInvest``` is able to extract GCAM data from both types of GCAM database by integrating the functionality from the R package "rgcam".
- Use default or user-provided queries and input data. ```plutus::gcamInvest``` includes default "query" file (.xml) that is used to retrieve energy data from GCAM database.Users can also provide queries that includes energy sector. The input data in terms of capital costs, capacity factors, steepness, and lifetime can be provided by users if the data formats are correct.
- Filter GCAM data by scenario and region. It is optional to select scenarios and regions of users' interests.
- Easy start with example dataset. Users can use an example GCAM database by calling ```plutus::exampleGCAMporj``` to get started with. 
- Rename scenario names.
- Reload data faster. It can take some time to connect and read data from the GCAM database in form of '.basex'. The funtion creates a copy of ".proj" file after data has been extracted from GCAM database. Reload the same data with ".proj" will be faster.



## Implementation
To evaluate the economic implications in the energy sector, we use an example dataset from GCAM v5.3 to estimate the stranded assets and new capital investments in Colombia and Argentina under Reference and Policy scenarios.
  - Reference scenario
  - Policy scenario


# Acknowledgement


# References
