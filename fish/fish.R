library(ggplot2)
library(dplyr)
library(tidyverse)
library(readxl)

install.packages("here")
install.packages("kableExtra")

library(here)
library(kableExtra)

#resetting RStudio Environment
rm(list = ls())

setwd('~/Documents/r_projects/fish')

fish <- read_csv("fish.csv")
kelp_abur <- read_excel(("kelp_fronds.xlsx"), sheet = "abur")

# Filter rows by matching a single character string

fish_garibaldi <- fish %>% 
  filter(common_name == "garibaldi")

fish_mohk <- fish %>% 
  filter(site == "mohk")

# Filter rows based on numeric conditions

fish_over50 <- fish %>% 
  filter(total_count >= 50)

# Filter to return rows that match this OR that OR that

fish_3sp <- fish %>% 
  filter(common_name == "garibaldi" | 
           common_name == "blacksmith" | 
           common_name == "black surfperch")


fish_3sp <- fish %>% 
  filter(common_name %in% c("garibaldi", "blacksmith", "black surfperch"))

fish_gar_2016 <- fish %>% 
  filter(year == 2016 | common_name == "garibaldi")

# Filter to return observations that match this AND that

aque_2018 <- fish %>% 
  filter(year == 2018, site == "aque")
aque_2018

# Use the ampersand (&) to add another condition "and this must be true":

aque_2018 <- fish %>% 
  filter(year == 2018 & site == "aque")

# Written as sequential filter steps:

aque_2018 <- fish %>% 
  filter(year == 2018) %>% 
  filter(site == "aque")

low_gb_wr <- fish %>% 
  filter(common_name %in% c("garibaldi", "rock wrasse"), 
         total_count <= 10)

fish_bl <- fish %>% 
  filter(str_detect(common_name, pattern = "black"))

fish_it <- fish %>% 
  filter(str_detect(common_name, pattern = "it"))
# blacksmITh and senorITa remain!

# Example full_join
abur_kelp_fish <- kelp_abur %>% 
  full_join(fish, by = c("year", "site")) 

# Example left join
kelp_fish_left <- kelp_abur %>% 
  left_join(fish, by = c("year","site"))

# Example inner join
kelp_fish_injoin <- kelp_abur %>% 
  inner_join(fish, by = c("year", "site"))

# filter and join in a sequence

my_fish_join <- fish %>% 
  filter(year == 2017, site == "abur") %>% 
  left_join(kelp_abur, by = c("year", "site")) %>% 
  mutate(fish_per_frond = total_count / total_fronds)

#  An HTML table with kable() and kableExtra

kable(my_fish_join)

my_fish_join %>% 
  kable() %>% 
  kable_styling(bootstrap_options = "striped", 
                full_width = FALSE)
