#Analysis

library(tidyverse)
library(sp)
library(sf)
library(tmap)
library(shiny)
library(ggmap)
library(leaflet)
library(mapview)
library(maps)
library(mapdata)
library(colorspace)
library(rgdal)
library(rworldmap)
library(htmlwidgets)

#Loading the datasets I will use to make plots and maps

nonstate_violence <- read.csv("~/plsc31101-final-project/Data/NSV_Actor-Year.csv", stringsAsFactors = F)
nonstate_violence2 <- read.csv("~/plsc31101-final-project/Data/NSV2_Actor.csv", stringsAsFactors = F)
wom_nonstate_violence_filtered <- read.csv("~/plsc31101-final-project/Data/Wom_NSV_Filtered.csv", stringsAsFactors = F)
nsv_top_5 <- read.csv("~/plsc31101-final-project/Data/Top5_NSV.csv", stringsAsFactors = F)
UCDP_ged_top5_2 <- read.csv("~/plsc31101-final-project/Data/Top5_Geo_UCDP.csv", stringsAsFactors = F)
UCDPG_ME_tomap <- read.csv("~/plsc31101-final-project/Data/UCDPG_ME.csv", stringsAsFactors = F)

#Creating a dataframe with the top 10 most violent actor-years in the wom_nonstate_violence dataframe

ten_violent <- nonstate_violence[order(-nonstate_violence$best_fatality_estimate),] %>%
  head(10)

#Plotting top 10 most violent actor-years by fatalities, colored by region

plot_violent_ay <- ggplot(data = ten_violent, aes(x = factor(actor_year, levels = actor_year[order(best_fatality_estimate)]), y = best_fatality_estimate, fill = region)) +
  geom_col() +
  xlab("Actor Year") +
  ylab("Best Estimate of Civilian Deaths") +
  ggtitle("Top 10 Most Violent Actor-Years For Civilians") +
  theme(axis.text.x=element_text(angle=45, hjust=1))

#Saving the plot as a PDF

ggsave(filename="10_Most_Violent_Actor_Years.pdf", plot=plot_violent_ay, scale=, width=, height=)

#Making a dataframe with the top 10 most sexually violent actor-years in the wom_nonstate_violence dataframe

ten_sv <- nonstate_violence[order(-nonstate_violence$sv_prev),] %>%
  head(10)

#Plotting top 10 most sexually violent actor-years by severity consensus, colored by country

plot_sv_ay <- ggplot(data = ten_sv, aes(x = factor(actor_year, levels = actor_year[order(sv_prev)]), y = sv_prev, fill = location)) +
  geom_col() +
  xlab("Actor Year") +
  ylab("Composite Sexual Violence Prevalence") +
  ggtitle("Top 10 Most Sexually Violent Actor-Years") +
  theme(axis.text.x=element_text(angle=45, hjust=1))

#Saving the plot as a PDF

ggsave(filename="10_Most_Sexually_Violent_Actor_Years.pdf", plot=plot_sv_ay, scale=, width=, height=)

#Creating a simplified dataset to visualize total deaths by group

simp_nonstate_violence <- nonstate_violence %>%
  group_by(actor_id, actor_name) %>%
  summarize(total_deaths_best = sum(best_fatality_estimate))

simp_nonstate_violence <- simp_nonstate_violence[order(-simp_nonstate_violence$total_deaths_best),]

#Plotting that dataset

plot_simp_nsv <- ggplot(data = simp_nonstate_violence, aes(x = factor(actor_id, levels = actor_id[order(total_deaths_best)]), y = total_deaths_best, fill = total_deaths_best)) +
  geom_col() +
  scale_fill_gradient(low = "maroon", high = "red") +
  xlab("Actor") +
  ylab("Best Civilian Fatality Estimate") +
  ggtitle("Actors Ordered by Violence") +
  theme(axis.text.x=element_text(angle=45, hjust=1))

#Only useful for seeing the distribution - impossible to see the actor names

#Saving plot as PDF

ggsave(filename="Groups_Organized_By_Violence.pdf", plot=plot_simp_nsv, scale=, width=, height=)

##Visualizing Total Civilian Deaths by Region

geo_nonstate_violence <- nonstate_violence %>%
  group_by(region) %>%
  summarize(geo_fatalities = sum(best_fatality_estimate))

plot_geo_nsv <- ggplot(data = geo_nonstate_violence, aes(x = factor(region, levels = region[order(geo_fatalities)]), y = geo_fatalities, fill = region)) +
  geom_col() +
  xlab("Region (NA = Multiple)") +
  ylab("Best Estimate of Civilian Fatalities") +
  ggtitle("Most Violent Regions Toward Civilians, 1989-2015")

#Saving plot as PDF

ggsave(filename="Violence_by_Region.pdf", plot=plot_geo_nsv, scale=, width=, height=)

#Finding and plotting number of unique actors per region (NA = the transnational groups I can't figure out what to do with)
nsv_unique <- nonstate_violence2 %>%
  group_by(region) %>%
  mutate(unique_actors = sum(n_distinct(actor_id)))

nsv_unique <- nsv_unique %>%
  group_by(region) %>%
  summarize(total_actors = max(unique_actors))

plot_region_actors <- ggplot(data = nsv_unique, aes(x = factor(region, levels = region[order(total_actors)]), y = total_actors, fill = region)) +
  geom_col() +
  xlab("Region (NA = Multiple)") +
  ylab("Total Nonstate Actors") +
  ggtitle("Total Nonstate Actors per Region, 1989-2015")

#Saving plot as PDF
ggsave(filename = "Groups_By_Region.pdf", plot=plot_region_actors, scale=, width=, height=)


#Plotting distribution of female group membership
total_women_plot <- ggplot(wom_nonstate_violence_filtered, aes(x=cat4_prevalence_high)) +
  geom_histogram(binwidth=1, color = "black", fill = "light blue") +
  xlab("Levels of Female Armed Group Participation (High Estimate)") +
  ylab("Number of Groups") +
  ggtitle("Levels of Female Armed Group Participation")

#Saving plot as PDF
ggsave(filename = "Total_Women.pdf", plot=total_women_plot, scale=, width=, height=)

#Plotting regional distribution of female group membership
region_wom <-ggplot(wom_nonstate_violence_filtered, aes(x=cat4_prevalence_high))+
  geom_histogram(binwidth=1, color="black", fill="light blue")+
  facet_wrap(region ~ .) +
  xlab("Levels of Female Armed Group Participation (High Estimate)") +
  ylab("Number of Groups") +
  ggtitle("Levels of Female Armed Group Participation by Region")

#Saving plot as PDF
ggsave(filename = "Total_Women_Region.pdf", plot=region_wom, scale=, width=, height=)

##Map time!

#First, a world map with all of the events coded

new_map <- getMap(resolution = "low")
all_events_map <- plot(new_map, asp = 1) +
  points(UCDP_ged$lon, UCDP_ged$lat, col = "red", cex = .6)

#Not very useful, huh? Gonna save it anyway

jpeg("all_events_map.jpeg", width = 2000, height = 2000)
plot(new_map, asp = 1) +
  points(UCDP_ged$lon, UCDP_ged$lat, col = "red", cex = .6)
dev.off()

#Next, I'll map all incidences of one sided violence by the top 4 groups in the Middle East (minus Syria, because the UCDP_ged dataset doesn't include it)
all_events_map_ME <- plot(new_map, xlim = c(15, 40), ylim = c(10, 60), asp = 1) +
  points(UCDPG_ME_tomap$longitude, UCDPG_ME_tomap$latitude, col = "red", cex = .6)

#Saving the map as a JPEG
jpeg("all_events_map_ME.jpeg", width = 1000, height = 1000)
plot(new_map, xlim = c(15, 40), ylim = c(10, 60), asp = 1) +
  points(UCDPG_ME_tomap$longitude, UCDPG_ME_tomap$latitude, col = "red", cex = .6)


##Interactive maps!!!

#Here is one just of the top 4 groups in the Middle East
UCDP_map_ME <- st_as_sf(UCDPG_ME_tomap, coords = c("longitude", "latitude"), crs = 4326)

Map_ME <-mapview(UCDP_map_ME, zcol = "actor_name", legend = TRUE)

Map_ME

#Now to make an interactive map with all event data from the top 5 groups in each region (4 for Middle East, see above)

UCDP_map_all <- st_as_sf(UCDP_ged_top5_2, coords = c("longitude", "latitude"), crs = 4326)

#Map of Violent Events By Actor
Map_All <- mapview(UCDP_map_all, zcol = "actor_name", legend = TRUE, layer.name = "Violent Events by Actor")

Map_All

#Map of Violent Events by Civilian Deaths
Map_All_deaths <- mapview(UCDP_map_all, zcol = "best", legend = TRUE, cex = "best", layer.name = "Violent Events by Civilian Deaths")

Map_All_deaths

#Saving the HTML of the smallest interactive map (the larger ones crashed my computer)
mapshot(Map_ME, file = paste0(getwd(), "/map_ME.html"))








