test_that("tracking_file builds the file name of a game", {
  expect_equal(tracking_file(2017090700), file.path("Data", "tracking_gameId_2017090700.csv"))
  expect_equal(tracking_file(2017090700, data_dir = "/tmp/bdb"),
               file.path("/tmp/bdb", "tracking_gameId_2017090700.csv"))
})

test_that("tracking_file keeps 10-digit game ids readable", {
  expect_equal(basename(tracking_file(2017090700L)), "tracking_gameId_2017090700.csv")
  expect_equal(basename(tracking_file("2017090700")), "tracking_gameId_2017090700.csv")
})

test_that("tracking_file rejects missing or multiple game ids", {
  expect_error(tracking_file(NA), "single, non-missing")
  expect_error(tracking_file(c(2017090700, 2017091000)), "single, non-missing")
})

test_that("the readers reject files that are not where they are expected", {
  expect_error(read_tracking(tempfile(fileext = ".csv")), "Tracking file not found")
  expect_error(read_games(tempfile(fileext = ".csv")), "Games file not found")
  expect_error(read_plays(tempfile(fileext = ".csv")), "Plays file not found")
})

test_that("the readers reject files that are missing required columns", {
  path <- tempfile(fileext = ".csv")
  readr::write_csv(data.frame(gameId = 2017090700), path)

  expect_error(read_tracking(path), "Tracking is missing required column")
  expect_error(read_games(path), "Games is missing required column\\(s\\): season, week")
  expect_error(read_plays(path), "Plays is missing required column\\(s\\): playId, playDescription")
})

test_that("read_tracking reads the tracking columns of a game", {
  path <- tempfile(fileext = ".csv")
  readr::write_csv(fake_tracking(), path)

  tracking <- read_tracking(path)

  expect_true(all(TRACKING_COLUMNS %in% names(tracking)))
  expect_equal(nrow(tracking), 9)
  expect_equal(unique(tracking$gameId), 2017090700)
})

test_that("merge_tracking adds the game and play context to every frame", {
  merged <- merge_tracking(fake_tracking(), fake_games(), fake_plays())

  expect_equal(nrow(merged), 9)
  expect_true(all(c("week", "playDescription") %in% names(merged)))
  expect_equal(unique(merged$week), 1)
})

test_that("merge_tracking keeps only frames whose game and play are known", {
  tracking <- rbind(fake_tracking(), fake_tracking(play_id = 9999))

  merged <- merge_tracking(tracking, fake_games(), fake_plays())

  expect_equal(unique(merged$playId), 2756)
  expect_equal(nrow(merged), 9)
  expect_equal(nrow(merge_tracking(tracking, fake_games(game_id = 1), fake_plays())), 0)
})

test_that("merge_tracking does not duplicate the join keys", {
  merged <- merge_tracking(fake_tracking(), fake_games(), fake_plays())

  expect_false(any(grepl("^gameId[.]", names(merged))))
  expect_false(any(grepl("^playId[.]", names(merged))))
})

test_that("merge_tracking reports which data set is incomplete", {
  expect_error(merge_tracking(fake_games(), fake_games(), fake_plays()), "^Tracking is missing")
  expect_error(merge_tracking(fake_tracking(), fake_plays(), fake_plays()), "^Games is missing")
  expect_error(merge_tracking(fake_tracking(), fake_games(), fake_games()), "^Plays is missing")
})

test_that("select_play returns the frames of one play, in order", {
  merged <- merge_tracking(rbind(fake_tracking(frames = 3:1), fake_tracking(play_id = 44)),
                           fake_games(),
                           fake_plays(play_id = c(2756, 44), description = c("Hill TD", "Kickoff")))

  play <- select_play(merged, 2756)

  expect_equal(unique(play$playId), 2756)
  expect_equal(play$`frame.id`, rep(1:3, each = 3))
})

test_that("select_play rejects a play that was not tracked", {
  merged <- merge_tracking(fake_tracking(), fake_games(), fake_plays())

  expect_error(select_play(merged, 1), "No tracking frames found for playId 1")
})

test_that("play_description returns the description once", {
  play <- fake_play()

  expect_equal(play_description(play),
               "A.Smith pass deep left to T.Hill for 75 yards, TOUCHDOWN.")
  expect_length(play_description(play), 1)
})

test_that("play_length counts frames, not tracked rows", {
  expect_equal(play_length(fake_play(frames = 1:40)), 40)
  expect_equal(play_length(fake_play(frames = c(1, 1, 2))), 2)
})

test_that("the play helpers reject data that is not a play", {
  expect_error(play_description(fake_games()), "^Play is missing")
  expect_error(play_length(fake_games()), "^Play is missing")
})
