## Makes the scripts in R/ and small tracking fixtures available to the tests.

for (script in list.files("../../R", pattern = "[.]R$", full.names = TRUE)) {
  source(script)
}

#' Tracking frames of a fabricated play
#'
#' @param frames Frame identifiers, one row per player per frame.
#' @param x,y Positions, recycled over the players of every frame.
#' @param game_id,play_id Identifiers written to every row.
fake_tracking <- function(frames = 1:3,
                          x = c(30, 35, 40),
                          y = c(20, 25, 30),
                          game_id = 2017090700,
                          play_id = 2756) {
  players <- data.frame(
    nflId = c(2495340, 2552415, NA),
    displayName = c("Anthony Sherman", "Tyreek Hill", "football"),
    jerseyNumber = c(42, 10, NA),
    team = c("away", "home", "football"),
    stringsAsFactors = FALSE
  )
  frames <- rep(frames, each = nrow(players))
  data.frame(
    time = sprintf("2017-09-08T00:41:%02dZ", frames),
    x = rep_len(x, length(frames)),
    y = rep_len(y, length(frames)),
    s = 3.91,
    dis = 0.41,
    dir = 78.9,
    event = NA_character_,
    players[rep_len(seq_len(nrow(players)), length(frames)), ],
    `frame.id` = frames,
    gameId = game_id,
    playId = play_id,
    row.names = NULL,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

fake_games <- function(game_id = 2017090700) {
  data.frame(gameId = game_id, season = 2017, week = 1)
}

fake_plays <- function(game_id = 2017090700, play_id = 2756,
                       description = "A.Smith pass deep left to T.Hill for 75 yards, TOUCHDOWN.") {
  data.frame(gameId = game_id, playId = play_id, playDescription = description,
             stringsAsFactors = FALSE)
}

#' A play as the plotting functions expect it: tracking joined with its context
fake_play <- function(...) {
  merge_tracking(fake_tracking(...), fake_games(), fake_plays())
}
