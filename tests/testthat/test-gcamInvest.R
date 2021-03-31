context('plutus::gcamInvest Tests')
library(plutus)
library(testthat)

queryFile <- system.file('extdata', 'Main_queries.xml', package = 'plutus')


invest <- plutus::gcamInvest(gcamdatabase = NULL,
                             dataProjFile = plutus::exampleGCAMproj,
                             reReadData = F,
                             queryFile = queryFile,
                             scenOrigNames = 'Impacts',
                             scenNewNames = 'Climate Impacts',
                             regionsSelect = 'Uruguay',
                             saveData = F)


testthat::skip_on_cran(); testthat::skip_on_travis()

test_that("returns a list containing 7 elements", {
  test <- length(invest)
  testthat::expect_equal(test, 7)
})

test_that("data exists", {
  test <- nrow(invest$data)
  testthat::expect_gt(test, 0)
})

test_that("data has 22 colomns", {
  test <- ncol(invest$data)
  testthat::expect_equal(test, 22)
})

test_that("scenario is selected and new name is applied", {
  test <- unique(invest$data$scenario)
  testthat::expect_equivalent(test, 'Climate Impacts')
})

test_that("region is selected", {
  test <- unique(invest$data$region)
  testthat::expect_equivalent(test, 'Uruguay')
})

#===============================================================================
# Test errors and warnings

test_that("throw error message if the path to gcamdatabase doesn't exist", {
  testthat::expect_error(plutus::gcamInvest(gcamdatabase = 'E:/'),
                         'doesn\'t exist')
})

test_that("throw error message if the path to .proj file doesn't exist", {
  testthat::expect_error(plutus::gcamInvest(dataProjFile = 'E:/test.proj',
                                            reReadData = F),
                         'doesn\'t exist')
})

test_that("throw error message if the path to gcamdataFile doesn't exist", {
  testthat::expect_warning(plutus::gcamInvest(dataProjFile = plutus::exampleGCAMproj,
                                              reReadData = F,
                                              gcamdataFile = 'E:/',
                                              scenOrigNames = 'Reference',
                                              regionsSelect = 'Uruguay',
                                              saveData = F),
                         'missing')
})
