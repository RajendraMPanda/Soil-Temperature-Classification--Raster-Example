library(rlist)
library(raster)
library(ggplot2)
library(dplyr)
library(rlang)
library(plotly)
library(reshape2)
library(hrbrthemes)
library(pracma)
library(ptw)
library(shiny)
library(shinydashboard)
library(leaflet)
library(sf)
#Increase memory limit
options(shiny.maxRequestSize = 300*1024^5) 

# Load list of raster layers with maximum air temperature values
r1 <- list.files("DataPath", pattern = ".tif$", full.names = T)
# Stacking multiple rasters
rs1 <- stack(r1) 

# To calculate maximum air temperature per each pixel
TMAX <- calc(rs1, fun = mean, na.rm = T)
#Save files
writeRaster(TMAX, file.path("DataPath"), driver = "GeoTiff", overwrite = TRUE)

# Load raster layers of minimum air temperature values
r2 <- list.files("DataPath", pattern = ".tif$", full.names = T)
rs2 <- stack(r2) 
# To calculate minimum temperature at each pixel
TMIN <- calc(rs2, fun = mean, na.rm = T)
writeRaster(TMIN, file.path("DataPath"), driver = "GeoTiff", overwrite = TRUE)

#To calculate mean of maximum and minimum air temperature
MAAT <- stack(TMIN, TMAX)
MAAT <- calc(MAAT, fun = mean, na.rm = T)
writeRaster(MAAT, file.path("DataPath"), driver = "GeoTiff", overwrite = TRUE)

# Add some increments to available mean air temperature
MAST <- MAAT + 1
#writeRaster(MAST, file.path("DataPath"), driver = "GeoTiff", overwrite = TRUE)
#To read raster
#MAST <- raster("S:/UGA-project/Output/MAST.grd")
# Create data frame for five class matrix
reclass_df <- c(-Inf, 0, 1,
                0, 8, 2,
                8, 15, 3,
                15, 22, 4,
                22, Inf, 5)
# View details
view(reclass_df)
# Creates matrix 
reclass_m <- matrix(reclass_df,
                    ncol = 3,
                    byrow = TRUE)
view(reclass_m)
# reclassify the raster using the matrix
classified_Temp <- reclassify(MAST, reclass_m)

# view pixel values for each class
barplot(classified_Temp, main = "Number of pixels in each class")
# Create dataframe for two class matrix 
reclass_df2 <- c(8, 15, 1,
                15, 22, 2
)
# Creates matrix 
reclass_m2 <- matrix(reclass_df2,
                    ncol = 3,
                    byrow = TRUE)
# reclassify the raster using the matrix
classified_Temp2 <- reclassify(MAST, reclass_m)
# Reclassified data into two class map on basis of bar plot info
plot(classified_Temp2,
     legend = FALSE,
     col = c("palegoldenrod", "palegreen2"), axes = TRUE,
     main = "Classified Soil Temperature")

legend("bottom",
       legend = c("Mesic", "Thermic"),
       fill = c("palegoldenrod", "palegreen2"),
       border = FALSE,
       bty = "n") # turn off legend border

# Crop to shapefile extent
# Load shapefile
OK <- read_sf("DataPath/_extent.shp")
OK_STR <- mask(classified_Temp2, mask=OK)
plot(OK_STR)

#Alternate options
classified_OK_STR <- reclassify(OK_STR, reclass_m2)

# plot customised classified maps for the masked area 
plot(classified_OK_STR,
     legend = FALSE,
     col = c("palegoldenrod", "palegreen2"), axes = TRUE,
     main = "Classified Soil Temperature")

legend("left",
       legend = c("Mesic", "Thermic"),
       fill = c("palegoldenrod", "palegreen2"),
       border = FALSE,
       bty = "n") # turn off legend border


