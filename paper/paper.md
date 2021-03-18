---
title: 'Plutus: An R package to calculate electricity investments and stranded assets from the Global Change Analysis Model'
tags:
  - R
  - GCAM
  - electricity
  - stranded assets
  - premature retirement
  - investment
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


# Summary
Plutus is designed to aid in informed decision-making by exploring economic implications in the power sector under different climate and policy scenarios. Plutus post-processes outputs from the Global Change Analysis Model (GCAM) `Calvin:2019`, and estimates the electricity investments and stranded assets for the energy sector. The concept and methodology for electricity investments and stranded assets was first introduced in `@Binsted:2020`. GCAM tracks electricity generation by technology and vintage over 32 geopolitical regions throughout the lifetime of each technology. This package extends GCAM functionality by (1) estimating the forgone economic value of prematurely retired power plants as a result of natural and profit-induced retirement; and (2) estimating the new generation capacity installation and capital investements driven by interactions among economic, energy, agriculture, and landuse systems in GCAM.


# Statement of need
The development of plutus was encouraged by the increasing interest in stranded assets and electricity investments from a wide range of GCAM users. Recent examples include the assessment of stranded assets and power sector investments in the context of climate mitigation in Latin America and the Caribbean `[@Binsted:2020; @da Silva:2021]`.**What are other tools comparing with plutus (citations).** A tool with easy access to GCAM output and validated methodology for stranded assets will streamline these otherwise cumbersome analyeses and enhance the GCAM user experience.

To harmonzie with many other GCAM related tools, plutus allows users to directly use different types of GCAM outputs and generates a data structure that can be incorperated with rmap `Khan:2021` (in preparation), another R package developed to visualize GCAM output. 


# Design and Implementation
Plutus creates an algorithm to 
Plutus utilizes capital cost, capacity factor data and assumptions of lifetime for electricity generating technologies to estimate the 



# Acknowledgement


# Reference
