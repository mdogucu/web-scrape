# ------------------------------------------------------------------------------
# 02-scrape-pac-function.R: function to scrape information for all contributions
# ------------------------------------------------------------------------------

# load packages ----------------------------------------------------------------

library(tidyverse) # 1.3.0
library(rvest)     # 0.3.5
library(here)      # 0.1

# function: scrape_pac ---------------------------------------------------------

scrape_pac <- function(url) {
  
  # read the page
  page <- read_html(url)
  
  # exract the table
  pac <-  page %>%
    # select node .DataTable (identified using the SelectorGadget)
    html_node(".DataTable") %>%
    # parse table at node td into a data frame
    #   table has a head and empty cells should be filled with NAs
    html_table("td", header = TRUE, fill = TRUE) %>%
    # convert to a tibble
    as_tibble()
  
  # rename variables
  pac <- pac %>%
    # rename columns
    rename(
      name = `PAC Name (Affiliate)` ,
      country_parent = `Country of Origin/Parent Company`,
      total = Total,
      dems = Dems,
      repubs = Repubs
    )
  
  # fix name
  pac <- pac %>%
    # remove extraneous whitespaces from the name column
    mutate(name = str_squish(name))
  
  # add year
  pac <- pac %>%
    # extract last 4 characters of the URL and save as year
    mutate(year = str_sub(url, -4))
  
  # return data frame
  pac
  
}

# test function ----------------------------------------------------------------

url_2020 <- "https://www.opensecrets.org/political-action-committees-pacs/foreign-connected-pacs?cycle=2020"
pac_2020_fn <- scrape_pac(url_2020)

url_2018 <- "https://www.opensecrets.org/political-action-committees-pacs/foreign-connected-pacs?cycle=2018"
pac_2018 <- scrape_pac(url_2018)

url_1998 <- "https://www.opensecrets.org/political-action-committees-pacs/foreign-connected-pacs?cycle=1998"
pac_1998 <- scrape_pac(url_1998)

# write files -------------------------------------------------------------------

write_csv(pac_2020_fn, here::here("opensecrets/data/", "pac-2020-fn.csv"))
write_csv(pac_2018, here::here("opensecrets/data/", "pac-2018.csv"))
write_csv(pac_1998, here::here("opensecrets/data/", "pac-1998.csv"))
