## Football field geometry used to draw the tracking data.

#' Dimensions of a football field, in tracking-data coordinates
#'
#' @return List with the side boundaries (`xmin`, `xmax`), the hash mark
#'   positions (`hash_left`, `hash_right`) and the hash mark `width`.
field_bounds <- function() {
  list(xmin = 0, xmax = 160 / 3, hash_left = 12, hash_right = 38.35, hash_width = 3.3)
}

#' Length-wise boundaries of the portion of the field a play happens on
#'
#' The boundaries extend 10 yards beyond the play, rounded to the closest ten
#' and clipped to the end lines of the field.
#'
#' @param play Frames of a single play.
#' @return List with `ymin` and `ymax`.
play_bounds <- function(play) {
  require_columns(play, "x", "Play")
  if (all(is.na(play$x))) {
    stop("Play has no tracked positions.", call. = FALSE)
  }
  list(
    ymin = max(round(min(play$x, na.rm = TRUE) - 10, -1), 0),
    ymax = min(round(max(play$x, na.rm = TRUE) + 10, -1), 120)
  )
}

#' Hash marks visible between two length-wise boundaries
#'
#' Hash marks are drawn on every yard line that is not a multiple of five,
#' at both side lines and at both rows of inbound marks.
#'
#' @param ymin,ymax Length-wise boundaries, see [play_bounds()].
#' @return Data frame of hash mark coordinates (`x`, `y`).
hash_marks <- function(ymin, ymax) {
  xmax <- field_bounds()$xmax
  marks <- expand.grid(x = c(0, 23.36667, 29.96667, xmax), y = 10:110)
  marks <- marks[floor(marks$y %% 5) != 0, ]
  marks <- marks[marks$y < ymax & marks$y > ymin, ]
  marks[order(marks$x, marks$y), ]
}

#' Yard lines visible between two length-wise boundaries
#'
#' @param ymin,ymax Length-wise boundaries, see [play_bounds()].
#' @return Positions of the yard lines, every five yards.
yard_lines <- function(ymin, ymax) {
  seq(max(10, ymin), min(ymax, 110), by = 5)
}

#' Yard numbers painted along a side line
#'
#' @param side Side line the numbers are read from, `"left"` or `"right"`.
#' @return The eleven labels, from one goal line to the other.
yard_labels <- function(side = c("left", "right")) {
  side <- match.arg(side)
  numbers <- c(seq(10, 50, by = 10), rev(seq(10, 40, by = 10)))
  if (side == "left") {
    c("G   ", numbers, "   G")
  } else {
    c("   G", numbers, "G   ")
  }
}
