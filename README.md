## Short Description

In order to explore issues related to women's participation in armed, non-state groups, violence against civilians, and the use of sexual violence in conflict, I first merged the Sexual Violence in Armed Conflict dataset (SVAC, 1989-2015), and the UCDP One-sided Violence Dataset (1989-2018). Later, I added in the UCDP Georeferenced Event Dataset (UCDP GED, 1988-2018, minus Syria) and the Women in Armed Rebellion Dataset (WARD, 1964-2014). This project focused on visualizations of the combined datasets, particularly the creation of three interactive maps.

## Dependencies

1. R, 3.6.1
2. RStudio, Version 1.2.5001

#### Files/

1. Narrative.Rmd: Provides a 3-5 page narrative of the project, main challenges, solutions, and results.
2. Narrative.pdf: A knitted pdf of 00_Narrative.Rmd. 
3. Stevens_PLSC31101_presentation.pptx: My lightning talk slides.
4. map1.mov: a screen-grab of me interacting with my first interactive map.
5. map2.mov: a screen-grab of me interacting with my second interactive map.

#### Code/
1. 01_merge-data.R: Loads, cleans, and merges the raw SVAC dataset, the UCDP 1 sided conflict and geocoded event datasets, and the WARD in various useful ways, producing a series of CSV files that are used to create analyses in the subsequent R script.
2. 02_analysis.R: Conducts descriptive analysis of the data, producing the visualizations found in the Results directory.

#### Data/

1. SVAC_conflictyears_1989-2015_2.xlsx: The Sexual Violence in Armed Conflict (SVAC) dataset for conflict years, latest version available here: http://www.sexualviolencedata.org/dataset/. Archived version available here: http://www.sexualviolencedata.org/archive/. I used version 2.0 (updated in November 2019) and since taken offline due to a coding error regarding the classification of conflict, interim, and post-conflict years, but did not have time to update my project based on this.
2. ucdp-onesided-191_2.csv: Contains UCDP data on one-sided violence (violence committed by armed groups against civilians). It is downloadable here: https://ucdp.uu.se/downloads/. I used version 19.1.
3. ward_1_3_2.xlsx: The Women in Armed Rebellion Dataset, downloadable here: https://reedmwood.com/home-page/women-in-armed-rebellion-dataset-ward/. I used version 1.3.
4. ged191_2.csv: The UCDP Georeferenced Event Dataset (GED), version 19.1. Available here: https://ucdp.uu.se/downloads/.
--
5. NSV_Actor-Year.csv: a dataset combining elements of the UCDP one-sided violence dataset with the SVAC dataset. It only contains information on nonstate actors during active conflicts, and is formatted as actor-year.
6. NSV2_Actor.csv: a dataset combining elements of the UCDP one-sided violence dataset with the SVAC dataset. It is formatted as actor, rather than actor-year.
7. Wom_NSV_Filtered.csv: a dataset combining the NSV2_Actor dataset with the WARD, and filtering to only those groups for which data on female membership is available.
8. Top5_NSV.csv: a dataset composed of the top 5 most violent groups (by best estimate of civilian casualties) from each region. It was made by manipulating the NSV2_Actor dataset.
9. Top5_Geo_UCDP.csv: a dataset merging the Top5_NSV dataset with the UCDP GED. While this has "Top5" in the name, it does not contain one of the Middle East's top five groups (Syrian insurgents) because the UCDP GED does not have data on Syria.
10. UCDPG_ME.csv: a dataset of merged UCDP GED and Top5_NSV data filtered to just contain data on the Middle East's top 4 most violent groups.

#### Results/

1. 10_Most_Violent_Actor_Years.pdf: a bar chart of the top 10 most violent actor-years for civilians, made out of the combined SVAC/UCDP one-sided violence datasets (saved as NSV_Actor-Year.csv) colored by region.
2. 10_Most_Sexually_Violent_Actor_years.pdf: a bar chart of the top 10 most sexually violent actor-years for civilians, made out of the combined SVAC/UCDP one-sided violence datasets (saved as NSV_Actor-Year.csv) colored by location.
3. Groups_Organized_By_Violence.pdf: a bar chart showing the distribution of the best estimate of total civilian deaths across all groups in the combined SVAC/UCDP one-sided violence datasets (though using a simplified version of the dataset saved as NSV_Actor-Year.csv).
4. Violence_By_Region.pdf: a bar chart of violence by region made out of the combined SVAC/UCDP one-sided violence datasets (saved as NSV_Actor-Year.csv) colored by region. 
5. Groups_By_Region.pdf: a bar chart showing the number of nonstate actors per region made out of the combined SVAC/UCDP one-sided violence datasets (saved as NSV2_Actor.csv).
6. Total_Women.pdf: a histogram showing the number of groups with different percentages of women (0 = No evidence, 1 = Low evidence - less than 5 percent, 2 = moderate evidence - 5-20 percent, and 3 = high evidence - more than 20 percent).
7. Total_Women_Region.pdf: the same histogram but separated and plotted by region.
8. all_events_map.jpeg: all violent events in the UCDP GED dataset mapped onto a world map.
9. all_events_map_ME.jpeg: a static map of all of the UCDP GED events in the Middle East
10. map_ME_tmp7d58f9.html: an interactive map of the top four most violent groups in the Middle East between 1989 and 2015, colored by group.
11. map_All_tmp52f071: an interactive map of the top five most violent groups in each region (four for the Middle East) between 1989 and 2015, colored by group.

**PLEASE NOTE: The Map_All_deaths interactive map is not present because it was so large that making HTML files out of it continually crashed my computer**

## More Information

Madeleine Stevens
Political Science PhD Student, University of Chicago
mistevens@uchicago.edu

