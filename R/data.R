## Loading and joining the Big Data Bowl data sets.

TRACKING_COLUMNS <- c("time", "x", "y", "s", "dis", "dir", "event", "nflId",
                      "displayName", "jerseyNumber", "team", "frame.id",
                      "gameId", "playId")
GAMES_COLUMNS <- c("gameId", "season", "week")
PLAYS_COLUMNS <- c("gameId", "playId", "playDescription")

#' Path to the tracking file of a single game
#'
#' @param game_id 10-digit game identifier.
#' @param data_dir Directory holding the .csv files.
#' @return Path to `tracking_gameId_[game_id].csv`.
tracking_file <- function(game_id, data_dir = "Data") {
  if (length(game_id) != 1 || is.na(game_id)) {
    stop("`game_id` must be a single, non-missing identifier.", call. = FALSE)
  }
  file.path(data_dir, paste0("tracking_gameId_", format(game_id, scientific = FALSE), ".csv"))
}

require_columns <- function(data, columns, what) {
  missing <- setdiff(columns, names(data))
  if (length(missing) > 0) {
    stop(sprintf("%s is missing required column(s): %s", what,
                 paste(missing, collapse = ", ")), call. = FALSE)
  }
  invisible(data)
}

read_data_file <- function(path, columns, what) {
  if (!grepl("^(https?|ftp)://", path) && !file.exists(path)) {
    stop(sprintf("%s file not found: %s", what, path), call. = FALSE)
  }
  data <- readr::read_csv(path, progress = FALSE, show_col_types = FALSE)
  require_columns(data, columns, what)
  data
}

#' Read player tracking data
#'
#' @param path Path or URL of a `tracking_gameId_[gameId].csv` file.
read_tracking <- function(path) {
  read_data_file(path, TRACKING_COLUMNS, "Tracking")
}

#' Read game-level data
#'
#' @param path Path or URL of `games.csv`.
read_games <- function(path) {
  read_data_file(path, GAMES_COLUMNS, "Games")
}

#' Read play-level data
#'
#' @param path Path or URL of `plays.csv`.
read_plays <- function(path) {
  read_data_file(path, PLAYS_COLUMNS, "Plays")
}

#' Join tracking data with its game- and play-level context
#'
#' @param tracking Tracking data of a single game.
#' @param games Game-level data.
#' @param plays Play-level data.
#' @return Tracking rows enriched with game and play columns.
merge_tracking <- function(tracking, games, plays) {
  require_columns(tracking, TRACKING_COLUMNS, "Tracking")
  require_columns(games, GAMES_COLUMNS, "Games")
  require_columns(plays, PLAYS_COLUMNS, "Plays")
  tracking %>%
    dplyr::inner_join(games, by = "gameId") %>%
    dplyr::inner_join(plays, by = c("gameId", "playId"))
}

#' Extract the frames of a single play
#'
#' @param merged Output of [merge_tracking()].
#' @param play_id Play identifier.
#' @return Frames of `play_id`, ordered by frame.
select_play <- function(merged, play_id) {
  require_columns(merged, c("playId", "frame.id"), "Merged tracking data")
  play <- merged %>%
    dplyr::filter(.data$playId == play_id) %>%
    dplyr::arrange(.data$frame.id)
  if (nrow(play) == 0) {
    stop(sprintf("No tracking frames found for playId %s.", play_id), call. = FALSE)
  }
  play
}

#' Description of a play
#'
#' @param play Frames of a single play.
play_description <- function(play) {
  require_columns(play, "playDescription", "Play")
  play$playDescription[[1]]
}

#' Number of tracked frames of a play
#'
#' Used to keep an animation at the 10 frames-per-second sampling rate of the
#' tracking data.
#'
#' @param play Frames of a single play.
play_length <- function(play) {
  require_columns(play, "frame.id", "Play")
  length(unique(play$frame.id))
}
