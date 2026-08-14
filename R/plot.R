## Drawing and animating a single play.

#' Draw the players of a play on a football field
#'
#' The side lines run along the x-axis and the yard lines along the y-axis, so
#' the tracking coordinates are flipped. Only the portion of the field the play
#' happens on is drawn, see [play_bounds()].
#'
#' @param play Frames of a single play, see [select_play()].
#' @param colours One colour per team, in the order the `team` column is
#'   sorted: away, football, home.
#' @return A ggplot of every frame of the play.
plot_play <- function(play, colours = c("#e31837", "#654321", "#002244")) {
  require_columns(play, c("x", "y", "team", "nflId", "jerseyNumber"), "Play")
  field <- field_bounds()
  bounds <- play_bounds(play)
  marks <- hash_marks(bounds$ymin, bounds$ymax)
  lines <- yard_lines(bounds$ymin, bounds$ymax)

  ggplot2::ggplot() +
    ggplot2::geom_point(data = play,
                        ggplot2::aes(x = field$xmax - .data$y, y = .data$x,
                                     colour = .data$team, group = .data$nflId,
                                     pch = .data$team, size = .data$team)) +
    ggplot2::geom_text(data = play,
                       ggplot2::aes(x = field$xmax - .data$y, y = .data$x,
                                    label = .data$jerseyNumber),
                       colour = "white", vjust = 0.36, size = 3.5) +
    ggplot2::scale_size_manual(values = c(6, 4, 6), guide = "none") +
    ggplot2::scale_shape_manual(values = c(19, 16, 19), guide = "none") +
    ggplot2::scale_colour_manual(values = colours, guide = "none") +
    ggplot2::annotate("text", x = marks$x[marks$x < field$xmax / 2],
                      y = marks$y[marks$x < field$xmax / 2],
                      label = "_", hjust = 0, vjust = -0.2) +
    ggplot2::annotate("text", x = marks$x[marks$x > field$xmax / 2],
                      y = marks$y[marks$x > field$xmax / 2],
                      label = "_", hjust = 1, vjust = -0.2) +
    ggplot2::annotate("segment", x = field$xmin, y = lines,
                      xend = field$xmax, yend = lines) +
    ggplot2::annotate("text", x = rep(field$hash_left, 11),
                      y = seq(10, 110, by = 10),
                      label = yard_labels("left"), angle = 270, size = 4) +
    ggplot2::annotate("text", x = rep(field$xmax - field$hash_left, 11),
                      y = seq(10, 110, by = 10),
                      label = yard_labels("right"), angle = 90, size = 4) +
    ggplot2::annotate("segment",
                      x = c(field$xmin, field$xmin, field$xmax, field$xmax),
                      y = c(bounds$ymin, bounds$ymax, bounds$ymax, bounds$ymin),
                      xend = c(field$xmin, field$xmax, field$xmax, field$xmin),
                      yend = c(bounds$ymax, bounds$ymax, bounds$ymin, bounds$ymin),
                      colour = "black") +
    ggplot2::ylim(bounds$ymin, bounds$ymax) +
    ggplot2::coord_fixed()
}

#' Animate a play at the sampling rate of the tracking data
#'
#' @param play Frames of a single play, see [select_play()].
#' @param ... Passed on to [plot_play()].
#' @return The animation of the play, one frame per tracked frame.
animate_play <- function(play, ...) {
  for (package in c("gganimate", "cowplot")) {
    if (!requireNamespace(package, quietly = TRUE)) {
      stop(sprintf("Package '%s' is required to animate a play.", package),
           call. = FALSE)
    }
  }
  animation <- plot_play(play, ...) +
    cowplot::theme_nothing() +
    gganimate::transition_time(.data$frame.id) +
    gganimate::ease_aes("linear")
  gganimate::animate(animation, fps = 10, nframe = play_length(play))
}
