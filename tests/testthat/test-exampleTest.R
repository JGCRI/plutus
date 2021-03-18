library(plutus)
library(testthat)

test_that("gcamInvest works", {
  test <- exampleFunction(3,5)
  expectedResults <- 8

  testthat::expect_equal(test, expectedResults)

})
