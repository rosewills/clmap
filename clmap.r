library(tigris)
library(ggplot2)
library(dplyr)
library(stringr)
library(data.table)
library(sf)
library(usmap)

options(tigris_use_cache = TRUE)

clCSV  <- "datasets/2024-fmr-counties.csv"
regData <- read_sf('2018-county-spfile/cb_2018_us_county_500k.shp')
cregIDs <- c("PA", "DE", "MD", "VA", "WV", "GA")
mregIDs <- fips(cregIDs)
cregCol  <- "state"
cIDCol  <- "fips"
cclCol  <- "fmr_0"
mregCol <- "STATEFP"
mIDCol  <- "GEOID"

clData <- data.table(read.csv(clCSV, header=T, check.names = FALSE))
regSearch <- paste0("(", paste(cregIDs, collapse = "|"), ")")
print(regSearch)
print(mregIDs)
clData <- clData %>% filter(str_detect(.data[[cregCol]], regSearch))
regData <- regData %>% filter(.data[[mregCol]] %in% mregIDs)
# clData[[cIDCol]] <- as.character(clData[[cIDCol]])

# for(id in mregIDs) {
#   print(id)
#   # stData <- zctas(year = 2000, state = mregIDs, cb = TRUE)
#   # stData <- counties(state = id)
#   if (exists("regData")) {
#     regData <- bind_rows(stData, regData)
#   } else {
#     regData <- stData
#   }
# }

nrow(regData)
nrow(clData)
unique(clData[[cregCol]])

usStates <- states(progress_bar = FALSE)
basemap <- usStates %>% filter(STUSPS %in% cregIDs)

mgData <- merge(regData, clData, by.x=c(mIDCol), by.y=c(cIDCol))
colnames(mgData)

ggplot() +
  geom_sf(data = basemap) +
  geom_sf(data = mgData, aes(fill = .data[[cclCol]]), linewidth = 0.1) +
  scale_fill_gradientn(colors = c("blue", "cornsilk", "red")) +
  theme_void()

# read_sf('spfile/cb_2018_us_county_500k.shp') %>%
#   filter(STATEFP %in% c(17, 18, 26, 55)) %>%
#   ggplot() +
#   geom_sf(aes(fill = STATEFP))

ggsave(filename="testmap.pdf")
