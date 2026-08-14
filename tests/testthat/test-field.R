test_that("the field is 160/3 yards wide, with hash marks 3.3 yards apart", {
  field <- field_bounds()

  expect_equal(field$xmin, 0)
  expect_equal(field$xmax, 160 / 3)
  expect_equal(field$hash_right - field$hash_left, 26.35)
  expect_equal(field$hash_width, 3.3)
})

test_that("play_bounds extends the play by ten yards, rounded to the closest ten", {
  bounds <- play_bounds(data.frame(x = c(43, 78)))

  expect_equal(bounds$ymin, 30)
  expect_equal(bounds$ymax, 90)
})

test_that("play_bounds stays between the two end lines", {
  bounds <- play_bounds(data.frame(x = c(2, 118)))

  expect_equal(bounds$ymin, 0)
  expect_equal(bounds$ymax, 120)
})

test_that("play_bounds ignores untracked positions", {
  bounds <- play_bounds(data.frame(x = c(NA, 43, NA, 78)))

  expect_equal(bounds$ymin, 30)
  expect_equal(bounds$ymax, 90)
})

test_that("play_bounds rejects a play without tracked positions", {
  expect_error(play_bounds(data.frame(x = c(NA_real_, NA_real_))), "no tracked positions")
  expect_error(play_bounds(data.frame(y = 1)), "^Play is missing")
})

test_that("hash marks are drawn at both side lines and both rows of inbound marks", {
  marks <- hash_marks(30, 60)

  expect_equal(sort(unique(marks$x)), c(0, 23.36667, 29.96667, 160 / 3))
  expect_equal(nrow(marks), 4 * length(setdiff(31:59, seq(35, 55, by = 5))))
})

test_that("hash marks skip the yard lines and stay inside the boundaries", {
  marks <- hash_marks(30, 60)

  expect_false(any(marks$y %% 5 == 0))
  expect_true(all(marks$y > 30 & marks$y < 60))
})

test_that("hash marks are limited to the playing field", {
  marks <- hash_marks(0, 120)

  expect_equal(min(marks$y), 11)
  expect_equal(max(marks$y), 109)
})

test_that("hash marks can be empty between two neighbouring yard lines", {
  expect_equal(nrow(hash_marks(40, 40)), 0)
})

test_that("yard lines are drawn every five yards between the goal lines", {
  expect_equal(yard_lines(30, 60), seq(30, 60, by = 5))
  expect_equal(yard_lines(0, 120), seq(10, 110, by = 5))
})

test_that("yard labels count up to midfield and back down, from both side lines", {
  expect_equal(yard_labels("left"),
               c("G   ", "10", "20", "30", "40", "50", "40", "30", "20", "10", "   G"))
  expect_equal(yard_labels("right"), rev(yard_labels("left")))
  expect_length(yard_labels(), 11)
})

test_that("yard labels are read from one of the two side lines", {
  expect_equal(yard_labels(), yard_labels("left"))
  expect_error(yard_labels("middle"))
})
