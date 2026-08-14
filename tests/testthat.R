## Runs the test suite from the root of the repository:
##
##     Rscript tests/testthat.R

library(testthat)

test_dir("tests/testthat", stop_on_failure = TRUE)
