# ------------------------------------------------------------------------------
# 01-scrape-pac-2020.R: scrape information for 2020 contributions
# ------------------------------------------------------------------------------

# load packages ----------------------------------------------------------------

library(tidyverse) # 1.3.0
library(rvest)     # 0.3.5
library(here)      # 0.1

# define url -------------------------------------------------------------------

url_2020 <- "https://www.opensecrets.org/political-action-committees-pacs/foreign-connected-pacs?cycle=2020"

# read the page ----------------------------------------------------------------

page <- read_html(url_2020)

# extract the table ------------------------------------------------------------

pac_2020 <-  page %>%
  # select node .DataTable (identified using the SelectorGadget)
  html_node(".DataTable") %>%
  # parse table at node td into a data frame
  #   table has a head and empty cells should be filled with NAs
  html_table("td", header = TRUE, fill = TRUE) %>%
  # convert to a tibble
  as_tibble()

# rename variables -------------------------------------------------------------

pac_2020 <- pac_2020 %>%
  # rename columns
  rename(
    name = `PAC Name (Affiliate)` ,
    country_parent = `Country of Origin/Parent Company`,
    total = Total,
    dems = Dems,
    repubs = Repubs
  )

# fix name ---------------------------------------------------------------------

pac_2020 <- pac_2020 %>%
  # remove extraneous whitespaces from the name column
  mutate(name = str_squish(name))

# write file -------------------------------------------------------------------

write_csv(pac_2020, here::here("opensecrets/data/", "pac-2020.csv"))
