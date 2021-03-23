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
  - name: Matthew Binsted
    affiliation: 2
  - name: Tom Wild
    orcid: 0000-0002-6045-7729
    affiliation: "1, 3"
  - name: Zarrar Khan
    orcid: 0000-0002-8147-8553
    affiliation: 3
  - name: Gokul Lyer
    affiliation: 2
  - name: Brinda Yarlagadda
    affiliation: 4
  - name: Silvia Regina Santos Da Silva
    affiliation: 5
  - name: Chris Vernon
    orcid: 0000-0002-3406-6214
    affiliation: 2
  - name: Pralit Patel
    affiliation: 2
affiliations:
  - name: Earth System Science Interdisciplinary Center (ESSIC), University of Maryland, College Park, MD, USA
    index: 1
  - name: Pacific Northwest National Laboratory (PNNL), Richland, WA, USA
    index: 2
  - name: Joint Global Change Research Institute (JGCRI), Pacific Northwest National Laboratory (PNNL), College Park, MD, USA
    index: 3
  - name: School of Public Policy, University of Maryland, College Park, MD, USA
    index: 4
  - name: Department of Atmospheric and Oceanic Science, University of Maryland, College Park, MD, USA
    index: 5
date: 13 March 2021
bibliography: paper.bib
---

# Summary
Plutus is designed to aid in informed decision-making by exploring economic implications in the power sector under different climate and policy scenarios. Plutus post-processes outputs from the Global Change Analysis Model (GCAM) `[@Calvin:2019]`, and estimates the electricity investments and stranded assets for the energy sector. The concept and methodology for electricity investments and stranded assets was first introduced in `[@Binsted:2020]`. GCAM tracks electricity generation by technology and vintage over 32 geopolitical regions throughout the lifetime of each technology. This package extends GCAM functionality by (1) estimating the forgone economic value of prematurely retired power plants as a result of natural and profit-induced retirement; and (2) estimating the new installations and capital investements driven by interactions among economic, energy, agriculture, and landuse systems in GCAM.


# Statement of need
The development of plutus was encouraged by the increasing interest in stranded assets and electricity investments from a wide range of GCAM users. Recent examples include the assessment of stranded assets and power sector investments in the context of climate mitigation in Latin America and the Caribbean `[@Binsted:2020; @daSilva:2021]`. Similarly, `[@McCollum:2018]` investigated the necessary energy investments to reach international policy goals by comparing output from GCAM and six other integrated assessment model (IAM) frameworks. Currently, there exists no uniform procedure amongst the GCAM community for calculating energy investments inclusive of all technologies present in GCAM 5.3. Plutus addresses this need while providing users with a flexible data structure that can be incorperated with a growing suite of GCAM oriented R packages, such as metis `[@khan:2020]`, to augment the analysis and visualization of GCAM output in the energy sector. A tool with easy access to GCAM output and validated methodology for stranded assets will streamline these otherwise cumbersome analyeses and enhance GCAM functionality.

# Design and implementation
Plutus utilizes capital cost, capacity factor data and assumptions of financial lifetime for electricity generating technologies to calculate stranded assets by scenario, period, and technology. This package is designed for GCAM version 5.3 and up.

## Workflow
The mandatory input from users is GCAM output in the format of databse folder or .proj file. Users are able to use different input data and assumptions associated with their GCAM runs (\autoref{fig:1}). Otherwise, plutus uses default data and assumptions to calculate stranded assets and electricity investment. More details of step-by-step instruction on plutus can be accessed via the repository at https://github.com/JGCRI/plutus. 

![**Figure 1.** The workflow for plutus.\label{fig:1}](Figures/Figure1.png)

## Key functions
```plutus::elecInvest``` calculates stranded assets and new installations in terms of value (billion 2010 USD) and energy generation (GW) by scenario, region, period, and technology. The function considers both the electricity generation technology and its associated cooling system in the overnight capital cost. The function adjusts the retirement for the base/calibration year vintage by the 'S Curve Fraction' function to represent natural retirements for power plants built before the base year.

$$ S \: Curve \: Fraction =  \frac{1}{1+ e^{steepness \times (t-halflife)} } $$

```plutus::hydroInvest``` updates the ```plutus::elecInvest``` output with corrected capital investment in the hydropowwer sector.

```plutus::gcamInvest``` is the integrated function that reads CGAM output, excutes ```plutus::elecInvest``` and ```plutus::hydroInvest``` functions, and generates output in a data structure that can be used by metis `[@khan:2020]`. This function is developed to connect with GCAM and other tools for post-processesing and visualization. ```plutus::gcamInvest``` provides flexibility to users with features such as:

- Access to different GCAM output database formats. GCAM output databases can be in formats such as ".proj" files or a folder of ".basex" files. ```plutus::gcamInvest``` is able to extract GCAM data from both types of GCAM database by integrating functions from the R package "rgcam".
- Use default or user-provided input data. The function will take the capital cost, capacity factor data and assumptions of steepness and financial lifetime if provided by the user following the format of each data file, otherwise it will use the default dataset collected from GCAM 5.3.
- Filter GCAM data by scenario and region. It is optional to select scenarios and regions of users' interests.
- Quick start with example dataset. Users can use an example GCAM database by calling ```plutus::exampleGCAMporj``` to get started. 
- Rename scenarios.
- Reload data faster. It can take some time to connect and read data from the GCAM database in the form of '.basex'. The funtion creates a ".proj" file after the data has been extracted from the GCAM database. Reloading the same data using the ".proj" file will be faster.


## Implementation
For demonstration, we use an example dataset from GCAM v5.3 to estimate the stranded assets and new capital investments in the USA power sector (\autoref{fig:2}). Figure 2 was a product by first using plutus to calculate stranded assets and new installations in the USA and then collaborating metis for visualizaitons `[@khan:2020]`. Plutus provides and effective means of disseminating complex ecomonic implications in magnitudes of strandded assets and investments concerning energy policy. Plutus becomes a more convenient tool in discovering outputs by interations with other R packages like metis.  

![**Figure 2.** Premature retirements and new installations in economic value (billion 2010 USD) and power (GW) terms in the USA power sector.\label{fig:2}](Figures/Figure2.png)


# Acknowledgement


# References