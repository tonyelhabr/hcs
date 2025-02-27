
#' Update all data
#' 
#' @param overwrite Whether to overwrite all existing data
#' @export
update_data <- function(
  overwrite = FALSE
) {
  t1 <- Sys.time()
  
  tournaments <- do_scrape_tournaments(
    scrape_time = t1, 
    overwrite = overwrite
  )
  
  brackets <- tournaments %>%
    do_scrape_brackets(
      scrape_time = t1, 
      overwrite = overwrite
    )
  
  teams <- brackets %>% 
    do_update_teams(
      update_time = t1
    )
  
  rosters <- teams %>% 
    do_scrape_rosters(
      scrape_time = t1,
      overwrite = overwrite
    )
  
  players <- rosters %>% 
    do_scrape_players(
      scrape_time = t1, 
      overwrite = overwrite
    )
  
  t2 <- Sys.time()
  ## update based on tournament urls from players
  all_brackets <- players %>% 
    do_insert_player_derived_brackets(
      scrape_time = t2
    )
  
  all_teams <- all_brackets %>% 
    do_update_teams(
      update_time = t2
    )
  
  all_rosters <- all_teams %>% 
    do_scrape_rosters(
      scrape_time = t2,
      ## FALSE because we want to be minimal about updating since we've already 
      ## scraped rosters in the first pass
      overwrite = FALSE
    )
  
  all_players <- all_rosters %>% 
    do_scrape_players(
      scrape_time = t2, 
      overwrite = FALSE
    )
  
  t3 <- Sys.time()
  cli::cli_alert_success(
    sprintf(
      'Done updating data at %s (%.0f seconds).', 
      Sys.time(), 
      as.numeric(t3 - t1, 'days') * 24 * 60 * 60
    )
  )
}
