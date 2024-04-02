library(tigris)
library(ggplot2)
library(dplyr)
library(stringr)
library(data.table)

options(tigris_use_cache = TRUE)

clCSV  <- "2024-fmr-sa-fixed2.csv"
clData <- data.table(read.csv(clCSV, header=T, check.names = FALSE))
states <- c("PA", "DE", "MD", "VA")
stateSearch <- paste0("(", paste(states, collapse = "|"), ")")
print(stateSearch)
clData <- clData %>% filter(str_detect(state, stateSearch))
# clData <- clData %>% filter(state %in% states)
# clData <- clData[state == "DE" | state == "PA-NJ-DE-MD" | state == "PA" | state == "MD" | state == "WV-MD" | state == "DC-VA-MD"]
clData$zip_code <- as.character(clData$zip_code)
# deData$"0BR" <- as.integer(deData$"0BR")

for(code in states) {
  print(code)
  stzc <- zctas(year = 2000, state = code, cb = TRUE)
  if (exists("zipcodes")) {
    zipcodes <- bind_rows(stzc, zipcodes)
  } else {
    zipcodes <- stzc
  }
}

# dezc <- zctas(year = 2000, state = "DE", cb = TRUE)
# mdzc <- zctas(year = 2000, state = "MD", cb = TRUE)
# pazc <- zctas(year = 2000, state = "PA", cb = TRUE)
# vazc <- zctas(year = 2000, state = "VA", cb = TRUE)

# zipcodes <- bind_rows(dezc, mdzc, pazc, vazc)

nrow(zipcodes)
nrow(clData)
unique(clData$state)

us_states <- states(progress_bar = FALSE)
basemap <- us_states %>% filter(STUSPS %in% states)

clzc <- merge(zipcodes, clData, by.x=c("NAME"), by.y=c("zip_code"))

ggplot() +
  geom_sf(data = basemap) +
  geom_sf(data = clzc, aes(fill = BR1), linewidth = 0.1) +
  scale_fill_gradientn(colors = c("blue", "cornsilk", "red"),
                       values = c(0, 0.03, 1), guide = "none") +
  theme_minimal()

ggsave(filename="testmap.pdf")
