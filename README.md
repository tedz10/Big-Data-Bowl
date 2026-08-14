
<!-- README.md is generated from README.Rmd. Please edit that file -->
<img src="Extras/bdb.png" align="right" />

Welcome to the data homepage for the NFL's 2019 Big Data Bowl. Here, you'll find links to 6 weeks of player tracking data from [Next Gen Stats](https://nextgenstats.nfl.com/), a style guide with references to each data set and each variable, a list of FAQs related to player tracking data and this contest, and a tutorial on how to visualize and animate the player tracking data using the [R Statistical Software](https://cran.r-project.org/).

What is contained in this repository
------------------------------------

There are five primary parts to this Github repo.

1.  Player tracking data from a subset of games from the 2017 season. See <https://github.com/nfl-football-ops/Big-Data-Bowl/tree/master/Data>. Tracking data from each game is stored as a unique .csv file: `tracking_gameId_[gameId].csv`, where `[gameId]` is a unique, 10-digit identifier for each game.

2.  Player, play, and game-level data that correspond to the tracking data. See <https://github.com/nfl-football-ops/Big-Data-Bowl/tree/master/Data> for each of these .csv files.

3.  A Data schema, which contains information on each of the variables in the data set, as well as the *key* variables needed to link the data sets together. See <https://github.com/nfl-football-ops/Big-Data-Bowl/blob/master/schema.md>.

4.  A list of Data FAQs. See <https://github.com/nfl-football-ops/Big-Data-Bowl/blob/master/faqs.md>.

5.  The R code of the tutorial below, in [`R/`](R), with its tests in [`tests/`](tests).

Official rules
--------------

A complete set of official rules for the Big Data Bowl can be found [here](http://ops.nfl.com/big-data-bowl).

**Ownership of Next Gen Stats:** Data provided in this Contest (NGS Data) is solely owned by the Sponsor. Any and all rights to NGS Data granted to each Entrant are subject to the Sponsor’s ownership rights to the NGS Data. Each Entrant expressly acknowledges and agrees that it will not use, edit, modify, create derivatives, combinations or compilations of, combine, associate, re-identify, reverse engineer, reproduce, display, distribute, disclose, license, sell or otherwise process NGS Data for any purpose whatsoever other than to compete in this contest, unless expressly permitted otherwise by the Sponsor in writing. Each Entrant acknowledges that it is not authorized to archive NGS Data and may not grant to any other party any rights to access, use or process NGS Data. Under no circumstances is participation in this Contest intended to be construed as a license (expressly, by implication, estoppel, or otherwise) or the grant of any right of ownership in any of the NGS Data.

**Disclaimer of Warranties:** ENTRANT ACKNOWLEDGES THAT NGS DATA IS PROVIDED ON AN “AS IS” BASIS AND THAT THE SPONSOR MAKES NO REPRESENTATION OR WARRANTY WHATSOEVER, EXPRESS OR IMPLIED, WITH RESPECT TO NGS DATA.

**Confidentiality:** The NGS Data provided in this Contest is not generally available to the public. Each Entrant agrees that it shall keep NGS Data strictly confidential and not transmit, duplicate, publish, redistribute, provide or communicate the data (or any part thereof) to any other person or entity without the prior written consent of the Sponsor. Each Entrant shall destroy NGS Data in its possession following conclusion of this Contest.

What player tracking data looks like
------------------------------------

A brief tutorial using the `gganimate` [package](https://github.com/thomasp85/gganimate) in R to animate the tracking data follows.

### Reading in the data

First, the following code reads in a few of the different data sets and selects a play to animate (Tyreek Hill's TD reception during Week 1, video [here](https://www.youtube.com/watch?v=QJaC5jHOwDY))

The code of this tutorial lives in [`R/`](R), and is unit tested with [testthat](https://testthat.r-lib.org/) (see [Running the tests](#running-the-tests)).

``` r
library(tidyverse)
for (script in list.files("R", pattern = "[.]R$", full.names = TRUE)) source(script)

data.url <- "https://raw.githubusercontent.com/nfl-football-ops/Big-Data-Bowl/master/Data"
tracking.example <- read_tracking(tracking_file(2017090700, data_dir = data.url))
games.sum <- read_games(file.path(data.url, "games.csv"))
plays.sum <- read_plays(file.path(data.url, "plays.csv"))

tracking.example.merged <- merge_tracking(tracking.example, games.sum, plays.sum)

example.play <- select_play(tracking.example.merged, 2756)

play_description(example.play)
#> [1] "(9:28) (Shotgun) A.Smith pass deep right to T.Hill for 75 yards, TOUCHDOWN."
```

### Animating the data

The following code animates each player that was on the field for Hill's touchdown. As one note, the code is flexible, such that plays at different parts of the field could feature different boundaries. As a second, the x-axis and y-axis coordinates are flipped.

``` r
library(gganimate)
library(cowplot)

## One animation frame per tracked frame, so that the play runs at the
## 10 frames-per-second sampling rate of the tracking data
animate_play(example.play)
```

![](man/figures/README-unnamed-chunk-3-1.gif)

`animate_play()` draws the play with `plot_play()` and animates it. The field it is drawn on is described by [`R/field.R`](R/field.R): `field_bounds()` holds the dimensions of a field, and `play_bounds()`, `hash_marks()`, `yard_lines()` and `yard_labels()` return the part of the field the play happens on.

### Running the tests

The tests of the tutorial code run from the root of the repository, and need `dplyr`, `readr`, `ggplot2` and `testthat`:

``` r
Rscript tests/testthat.R
```
