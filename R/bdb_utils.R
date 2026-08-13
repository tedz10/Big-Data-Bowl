## Shared helpers for reading and plotting the Big Data Bowl tracking data.
## Source this file (`source("R/bdb_utils.R")`) before using the functions below.

library(tidyverse)

BDB_DATA_BASE_URL <- "https://raw.githubusercontent.com/nfl-football-ops/Big-Data-Bowl/master/Data"

## General field boundaries, in the coordinate system of the tracking data.
FIELD_WIDTH <- 160 / 3
FIELD <- list(
  xmin = 0,
  xmax = FIELD_WIDTH,
  hash.right = 38.35,
  hash.left = 12,
  hash.width = 3.3,
  hash.x = c(0, 23.36667, 29.96667, FIELD_WIDTH)
)

bdb_data_url <- function(file) {
  paste(BDB_DATA_BASE_URL, file, sep = "/")
}

read_bdb_data <- function(file) {
  read_csv(bdb_data_url(file))
}

read_tracking_data <- function(game.id) {
  read_bdb_data(paste0("tracking_gameId_", game.id, ".csv"))
}

## Tracking data for a single play, joined to its game and play information.
read_play <- function(game.id, play.id) {
  read_tracking_data(game.id) %>%
    inner_join(read_bdb_data("games.csv")) %>%
    inner_join(read_bdb_data("plays.csv")) %>%
    filter(playId == play.id)
}

## Field boundaries covering the part of the field a given play takes place on.
play_boundaries <- function(play) {
  list(
    ymin = max(round(min(play$x, na.rm = TRUE) - 10, -1), 0),
    ymax = min(round(max(play$x, na.rm = TRUE) + 10, -1), 120)
  )
}

hash_marks <- function(ymin, ymax) {
  expand.grid(x = FIELD$hash.x, y = (10:110)) %>%
    filter(!(floor(y %% 5) == 0)) %>%
    filter(y < ymax, y > ymin)
}

## ggplot layers drawing the field: hash marks, yard lines, yard numbers and sideline.
field_layers <- function(ymin, ymax) {
  df.hash <- hash_marks(ymin, ymax)
  yard.lines <- seq(max(10, ymin), min(ymax, 110), by = 5)
  yard.numbers <- c(seq(10, 50, by = 10), rev(seq(10, 40, by = 10)))

  hash_side <- function(side, hjust) {
    on.side <- if (side == "left") df.hash$x < 55 / 2 else df.hash$x > 55 / 2
    annotate("text", x = df.hash$x[on.side], y = df.hash$y[on.side],
             label = "_", hjust = hjust, vjust = -0.2)
  }

  numbers_side <- function(x, label, angle) {
    annotate("text", x = rep(x, 11), y = seq(10, 110, by = 10),
             label = label, angle = angle, size = 4)
  }

  list(
    hash_side("left", hjust = 0),
    hash_side("right", hjust = 1),
    annotate("segment", x = FIELD$xmin, y = yard.lines,
             xend = FIELD$xmax, yend = yard.lines),
    numbers_side(FIELD$hash.left, c("G   ", yard.numbers, "   G"), angle = 270),
    numbers_side(FIELD$xmax - FIELD$hash.left, c("   G", yard.numbers, "G   "), angle = 90),
    annotate("segment", x = c(FIELD$xmin, FIELD$xmin, FIELD$xmax, FIELD$xmax),
             y = c(ymin, ymax, ymax, ymin),
             xend = c(FIELD$xmin, FIELD$xmax, FIELD$xmax, FIELD$xmin),
             yend = c(ymax, ymax, ymin, ymin), colour = "black")
  )
}

## ggplot layers drawing the players (dots plus jersey numbers) of a play.
player_layers <- function(play) {
  ## The x-axis and y-axis coordinates of the tracking data are flipped.
  position <- function(...) aes(x = (FIELD$xmax - y), y = x, ...)

  list(
    geom_point(data = play,
               position(colour = team, group = nflId, pch = team, size = team)),
    geom_text(data = play, position(label = jerseyNumber),
              colour = "white", vjust = 0.36, size = 3.5),
    scale_size_manual(values = c(6, 4, 6), guide = FALSE),
    scale_shape_manual(values = c(19, 16, 19), guide = FALSE),
    scale_colour_manual(values = c("#e31837", "#654321", "#002244"), guide = FALSE)
  )
}

## An animation of every player on the field for a given play.
plot_play <- function(play) {
  bounds <- play_boundaries(play)

  ggplot() +
    player_layers(play) +
    field_layers(bounds$ymin, bounds$ymax) +
    ylim(bounds$ymin, bounds$ymax) +
    coord_fixed() +
    theme_nothing() +
    transition_time(frame.id) +
    ease_aes("linear")
}

## Animate a play, ensuring the timing matches the data's 10 frames-per-second.
animate_play <- function(play, fps = 10) {
  animate(plot_play(play), fps = fps, nframe = length(unique(play$frame.id)))
}
