% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{xmlElecQueries}
\alias{xmlElecQueries}
\title{elecQueries xml file}
\format{
.xml
}
\source{
gcam query
}
\usage{
xmlElecQueries
}
\description{
elecQueries xml file
}
\examples{
\dontrun{
 library(plutus); library(XML)
 plutus::xmlElecQueries
 # Can save xml
 XML::saveXML(plutus::xmlElecQueries, file=paste(getwd(), "/ElecQueries.xml", sep = ""))
}
}
\keyword{datasets}
