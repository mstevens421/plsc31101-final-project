#Load, Merge, and Clean Datasets

library(tidyverse)
library(readxl)
library(doBy)

#Loading the SVAC & UCDP data

SVAC <- read_excel(path = "~/plsc31101-final-project/Data/SVAC_conflictyears_1989-2015_2.xlsx", sheet = 1)
UCDP_1side <- read.csv("~/plsc31101-final-project/Data/ucdp-onesided-191_2.csv", stringsAsFactors = F)

#Filtering the SVAC and UCDP data so they only cover nonstate actors and the same time period (1989-2015)

SVACnonstate <- SVAC[SVAC$actor_type == 3 | SVAC$actor_type == 6, ]

UCDPnonstate <- UCDP_1side[UCDP_1side$is_government_actor == 0, ]

UCDP_ns_ltd <- UCDPnonstate[UCDPnonstate$year <= 2015, ]

UCDP_ns_ltd <- UCDP_ns_ltd %>%
  mutate(region = as.numeric(region))

#Merging the filtered SVAC and UCDP dataframes

nonstate_violence <- UCDP_ns_ltd %>%
  left_join(SVACnonstate, by = c("actor_id" = "actorid_new", "actor_name" = "actor", "year", "region", "location"))

#Replacing all -99 values with NA

nonstate_violence[nonstate_violence == -99] <- NA

#Replacing all n/a values with NA

nonstate_violence[nonstate_violence == "n/a"] <- NA
nonstate_violence[nonstate_violence == "n/a, n/a"] <- NA

#Dropping irrelevant columns: dropping "version" because I can say what version of the UCDP data I used in my codebook, and dropping the "interm" and "postc" columns (from the SVAC dataset) because I already opted to only use conflict years, and dropping "is_government_actor" because I filtered for nonstate actors. Additionally, I am opting to use the UCDP location data, so I am dropping superfluous columns "gwnoloc1-4" (from the SVAC).

nonstate_violence <- nonstate_violence %>%
  select(-c(version, interm, postc, is_government_actor, gwnoa, gwnoloc, gwnoloc2, gwnoloc3, gwnoloc4))

#Renaming columns to be more specific: "type" column from the SVAC, which says what type of conflict it is, becomes "conflict_type", "incomp" from the SVAC, which says what the conflict is over, becomes "conflict_issue", and "form" from the SVAC, which says what form of sexual violence is perpetrated, becomes "form_sv".

nonstate_violence <- nonstate_violence %>%
  rename(conflict_type = type, conflict_issue = incomp, form_sv = form)

#Replacing region numbers with region names for ease of plotting

as.character(nonstate_violence$region)

nonstate_violence$region[nonstate_violence$region == "1"] <- "Europe"
nonstate_violence$region[nonstate_violence$region == "2"] <- "Middle East"
nonstate_violence$region[nonstate_violence$region == "3"] <- "Asia"
nonstate_violence$region[nonstate_violence$region == "4"] <- "Africa"
nonstate_violence$region[nonstate_violence$region == "5"] <- "Americas"

#Creating a new column for actor-year
nonstate_violence$actor_year <- paste(nonstate_violence$actor_name, nonstate_violence$year)

#Writing CSV file of nonstate_violence (Actor-Year) dataset
write.csv(nonstate_violence, file = "NSV_Actor-Year.csv")

#######

#Making a column of sexual violence prevalence by adding the severity scores across all three sources - if three sources are in agreement about there being severe sexual violence, the group gets a higher score. (Flawed, but working with what I've got)

nonstate_violence$sv_prev <- (nonstate_violence$state_prev + nonstate_violence$ai_prev + nonstate_violence$hrw_prev)

##Collapsing the Actor-Year Dataset into an Actor Dataset

#Figuring out how many unique actors are in the dataset: 190

length(unique(nonstate_violence$actor_id))

#Collapsing dataset into actor instead of actor-year
nonstate_violence2 <- nonstate_violence %>%
  group_by(actor_id, region, actor_name) %>%
  summarize(Total_Fatalities = sum(best_fatality_estimate), Total_SV = sum(sv_prev))

#PROBLEM: transnational armed groups (IS, Al Qaeda) show up multiple times

#Writing CSV file of nonstate_violence2 (Actor) dataset

write.csv(nonstate_violence2, file = "NSV2_Actor.csv")

#Loading the WARD
WARD <- read_excel(path = "~/plsc31101-final-project/Data/ward_1_3_2.xlsx", sheet = 1)

#Making sure there are compatible keys between the WARD and the nonstate_violence2 datasets
WARD <- WARD %>%
  mutate(gwnoa = as.numeric(gwnoa))

#Merging the WARD and the nonstate_violence2 datasets
wom_nonstate_violence <- nonstate_violence2 %>%
  left_join(WARD, by = c("actor_id" = "sidebid"))

#Filtering out the groups with no data for percentage of members who are women
wom_nonstate_violence_filtered <- wom_nonstate_violence %>%
  select(actor_id, region, actor_name, Total_Fatalities, Total_SV, cat4_prevalence_high) %>%
  filter(cat4_prevalence_high == 0 | cat4_prevalence_high == 1 | cat4_prevalence_high == 2 | cat4_prevalence_high == 3)

#Writing CSV of wom_nonstate_violence_filtered

write.csv(wom_nonstate_violence_filtered, file = "Wom_NSV_Filtered.csv")

##Preparing for geocoded data

#Finding the top 5 most violent groups in each region in order to filter the UCDP geocoded data by these groups so that we can do cooler maps than just continent or country!

find_top5 <- function(i){
  nsvi <- nonstate_violence2 %>%
    select(region, actor_name, Total_Fatalities, actor_id) %>%
    filter(region == i)
  nsvi$top5 <- rank(-nsvi$Total_Fatalities)
  nsvi_5 <- head(nsvi[order(nsvi$top5), ], 5)
  return(nsvi_5)
}

nsv_top_5 <- find_top5("Asia") %>%
  full_join(find_top5("Middle East")) %>%
  full_join(find_top5("Europe")) %>%
  full_join(find_top5("Africa")) %>%
  full_join(find_top5("Americas"))

#Writing a CSV of the top 25 deadliest groups

write.csv(nsv_top_5, file = "Top5_NSV.csv")

#######
##Geocoded data

#Loading, cleaning, and merging geocoded data from UCDP
UCDP_ged <- read.csv("~/plsc31101-final-project/Data/ged191_2.csv", stringsAsFactors = F)

#Filtering data to only the one-sided violence
UCDP_ged_1side <- UCDP_ged[UCDP_ged$side_b == "Civilians", ]

#Merging the dataframe with the top 5 deadliest groups from each region with the geocoded data of their violence against civilians
UCDP_ged_top5 <- nsv_top_5 %>%
  left_join(UCDP_ged_1side, by = c("region", "actor_name" = "side_a"))

#Eliminating the Syrian insurgents column (UCDP ged doesn't have info on Syria)

UCDP_ged_top5_2 <- UCDP_ged_top5 %>%
  filter(actor_name != "Syrian insurgents")

#Writing a CSV of the geocoded data on the top 5 deadliest groups from each region (minus Syria)

write.csv(UCDP_ged_top5_2, file = "Top5_Geo_UCDP.csv")

#Making a dataframe to allow me to map all incidences of one sided violence by the top 4 groups in the Middle East (minus Syria, because the UCDP_ged dataset doesn't include it)

UCDP_ged_top5ME <- find_top5("Middle East") %>%
  left_join(UCDP_ged_1side, by = c("region", "actor_name" = "side_a"))

#Dropping Syrian Insurgents because the UCDP geo dataset doesn't cover Syria
UCDP_ged_top4_ME <- UCDP_ged_top5ME %>%
  filter(actor_name !="Syrian insurgents")

#Filtering dataset to just have variables we need for this part of the project
UCDPG_ME_tomap <- UCDP_ged_top4_ME %>%
  select(region, actor_name, latitude, longitude, geom_wkt, priogrid_gid, country, deaths_civilians)

#Writing a CSV of this dataframe
write.csv(UCDPG_ME_tomap, file = "UCDPG_ME.csv")

