# ------------------------------------------------------------------------------
# 03-scrape-pac-all.R: map scrape_pac() over all years
# ------------------------------------------------------------------------------

# load packages ----------------------------------------------------------------

library(tidyverse) # 1.3.0
library(rvest)     # 0.3.5
library(here)      # 0.1

# list of urls -----------------------------------------------------------------

# first part of url
root <- "https://www.opensecrets.org/political-action-committees-pacs/foreign-connected-pacs?cycle="

# second part of url (election years as a sequence)
year <- seq(from = 1998, to = 2020, by = 2)

# construct urls by pasting first and second parts together
urls <- paste0(root, year)

# map the scrape_pac function over list of urls --------------------------------

pac_all <- map_dfr(urls, scrape_pac)

# write data -------------------------------------------------------------------

write_csv(pac_all, path = here::here("opensecrets/data/", "pac-all.csv"))
