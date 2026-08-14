test_that("plot_play draws every tracked row of the play", {
  play <- fake_play(frames = 1:5)

  plot <- plot_play(play)

  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(ggplot2::layer_data(plot, 1)), nrow(play))
})

test_that("plot_play flips the tracking coordinates onto the field", {
  play <- fake_play(frames = 1, x = 45, y = 20)

  drawn <- ggplot2::layer_data(plot_play(play), 1)

  expect_equal(unique(drawn$x), 160 / 3 - 20)
  expect_equal(unique(drawn$y), 45)
})

test_that("plot_play labels the players with their jersey number", {
  play <- fake_play(frames = 1)

  labels <- ggplot2::layer_data(plot_play(play), 2)$label

  expect_equal(sort(as.character(labels[!is.na(labels)])), c("10", "42"))
})

test_that("plot_play colours the teams and the football apart", {
  play <- fake_play(frames = 1)

  drawn <- ggplot2::layer_data(plot_play(play), 1)

  expect_equal(length(unique(drawn$colour)), 3)
  expect_true("#654321" %in% drawn$colour)
})

test_that("plot_play shows only the part of the field the play happens on", {
  play <- fake_play(frames = 1:3, x = c(43, 60, 78))

  plot <- plot_play(play)

  expect_equal(ggplot2::layer_scales(plot)$y$get_limits(), c(30, 90))
})

test_that("plot_play rejects data that is not a play", {
  expect_error(plot_play(fake_games()), "^Play is missing")
})

test_that("animate_play renders one animation frame per tracked frame", {
  skip_if_not_installed("gganimate")
  skip_if_not_installed("cowplot")
  play <- fake_play(frames = 1:3, x = c(43, 60, 78))

  animation <- suppressWarnings(animate_play(play))

  expect_equal(length(animation), play_length(play))
})

test_that("animate_play refuses to animate without its animation packages", {
  skip_if(requireNamespace("gganimate", quietly = TRUE) &&
            requireNamespace("cowplot", quietly = TRUE),
          "gganimate and cowplot are installed")

  expect_error(animate_play(fake_play()), "required to animate a play")
})
