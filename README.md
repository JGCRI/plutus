[![docs](https://github.com/JGCRI/plutus/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/JGCRI/plutus/actions/workflows/pkgdown.yaml)
[![build](https://github.com/JGCRI/plutus/actions/workflows/rcmd.yml/badge.svg)](https://github.com/JGCRI/plutus/actions/workflows/rcmd.yml)
[![codecov](https://codecov.io/gh/JGCRI/plutus/branch/main/graph/badge.svg?token=1PK34KIHKE)](https://codecov.io/gh/JGCRI/plutus)


# plutus
Plutus is designed for GCAM v5.3 (excluding GCAM-USA).
<br />

<!-------------------------->
<!-------------------------->
# <a name="Contents"></a>Contents
<!-------------------------->
<!-------------------------->

- [Key Links](#KeyLinks)
- [Introduction](#Introduction)
- [Citation](#Citation)
- [Installation Guide](#InstallGuides)
- [How-to Guides](#How-toGuides) 

<br />

<!-------------------------->
<!-------------------------->
# <a name="KeyLinks"></a>Key Links
<!-------------------------->
<!-------------------------->

- Github: https://github.com/JGCRI/plutus
- Webpage: https://jgcri.github.io/plutus/

[Back to Contents](#Contents)

<br />

<!-------------------------->
<!-------------------------->
# <a name="Introduction"></a>Introduction
<!-------------------------->
<!-------------------------->

`plutus` post-processes outputs from the Global Change Analysis Model (GCAM) to calculate the electricity investment costs and stranded asset costs associated with GCAM projections of future power sector energy generation by technology.


[Back to Contents](#Contents)

<br />

<!-------------------------->
<!-------------------------->
# <a name="Citation"></a>Citation
<!-------------------------->
<!-------------------------->

Zhao, M., Binsted, M., Wild, T.B., Khan, Z., Yarlagadda, B., Iyer, G., Vernon, C., Patel, P., Santos da Silva, S.R., Calvin, K.V., (in preparation). plutus - An R package to calculate electricity investments and stranded assets from the Global Change Analysis Model. Journal of Open Source Software.

[Back to Contents](#Contents)

<br />


<!-------------------------->
<!-------------------------->
# <a name="InstallationGuides"></a>Installation Guides
<!-------------------------->
<!-------------------------->

1. Download and install:

    - R (https://www.r-project.org/)
    - R studio (https://www.rstudio.com/)

2. For Linux users, install following libraries:

```
sudo apt install build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev
sudo apt-get install libxml2-dev
```
    
3. Open R studio:

```
install.packages('devtools')
devtools::install_github('JGCRI/rgcam')
devtools::install_github('JGCRI/plutus')
```

4. `Metis` installation

`Metis` provides functions to visualize the outputs from `plutus`. The installation guide for `Metis` can be accessed at [Metis Github Page](https://github.com/JGCRI/metis).

[Back to Contents](#Contents)

<br />


<!-------------------------->
<!-------------------------->
# <a name="How-toGuides"></a>How-to Guides
<!-------------------------->
<!-------------------------->
`plutus::gcamInvest` provides all-in-one workflow that reads gcamdata, processes queries, and estimates stranded assets and capital investments. Please visit the followings for detailed instructions.

- [Instruction on `plutus::gcamInvest`](https://jgcri.github.io/plutus/articles/gcamInvest.html)
- [Case tutorial](https://jgcri.github.io/plutus/articles/CaseTutorial.html)

[Back to Contents](#Contents)

<br />
