# ------------------------------------------------------------------------------
# 04-analyze.R: clean and visualize
# ------------------------------------------------------------------------------

# load packages ----------------------------------------------------------------

library(tidyverse) # 1.3.0
library(scales)    # 1.1.0

# load data --------------------------------------------------------------------

pac_all <- read_csv(here::here("opensecrets/data/", "pac-all.csv"))

# ------------------------------------------------------------------------------
# data cleaning
# ------------------------------------------------------------------------------

# fix country_parent -----------------------------------------------------------

pac_all <- pac_all %>%
  # separate country_parent column into two columns at /
  #  where there is more than /, merge extra components in the second column 
  separate(country_parent, into = c("country", "parent"), sep = "/", extra = "merge")

# fix dollar amounts -----------------------------------------------------------
# using a custom function: parse_currency

parse_currency <- function(x){
  x %>% 
    # remove dollar sign
    str_remove("\\$") %>%
    # remove all occurences of commas
    str_remove_all(",") %>%
    # convert to numeric
    as.numeric()
}

pac_all <- pac_all %>%
  mutate(
    total = parse_currency(total),
    dems = parse_currency(dems),
    repubs = parse_currency(repubs)
  )

# write data -------------------------------------------------------------------

write_csv(pac_all, path = here::here("opensecrets/data/", "pac-all-clean.csv"))

# ------------------------------------------------------------------------------
# data visualization
# ------------------------------------------------------------------------------

# UK contributions to democrats and republicans --------------------------------

pac_all %>%
  # UK contributions up to 2018 (since 2020 isn't finished at the time of analysis)
  filter(
    country == "UK",
    year < 2020
  ) %>%
  # group by year
  group_by(year) %>%
  # calculate total contributions to Democratic and Republican campaigns
  summarise(
    Democrat = sum(dems),
    Republican = sum(repubs)
  ) %>%
  # convert from wide to long data
  #  column names go under a new column called party
  #  cell values go under a new column called amount
  pivot_longer(cols = c(Democrat, Republican), names_to = "party", values_to = "amount") %>%
  # begin plot
  ggplot(aes(x = year)) +
  geom_line(aes(y = amount, group = party, color = party)) +
  scale_color_manual(values = c("blue", "red")) +
  scale_y_continuous(labels = dollar_format(scale = 0.000001, suffix = "M")) +
  scale_x_continuous(breaks = seq(2000, 2016, 4)) +
  labs(
    x = "Year",
    y = "Amount",
    color = "Party",
    title = "Contribution to US politics from UK-Connected PACs",
    subtitle = "By party, over time"
  ) +
  theme_minimal()
