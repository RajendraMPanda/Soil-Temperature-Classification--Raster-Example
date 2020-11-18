options(shiny.maxRequestSize = 300*1024^5) 
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
# Load shapefile
OK <- read_sf("S:/UGA-project/OK_SHP/oklahoma_extent.shp")
# Load raster layers
r1 <- list.files("S:/UGA-project/ppt/ppt2002", pattern = ".tif$", full.names = T)
# Stacking multiple rasters
ras1 <- stack(r1) 

# To calculate annual max temperature
PPTN <- calc(ras1, fun = mean, na.rm = T)
writeRaster(PPTN, file.path("S:/UGA-project/Output/PPT/PPT2002"), driver = "GeoTiff", overwrite = TRUE)

# Load raster layers
r2 <- list.files("S:/UGA-project/tmin/tmin2016", pattern = ".tif$", full.names = T)
ras2 <- stack(r2) 
# To calculate annual min temperature
Tmin <- calc(ras2, fun = mean, na.rm = T)
writeRaster(Tmin, file.path("S:/UGA-project/Output/TMIN/Tmin2016"), driver = "GeoTiff", overwrite = TRUE)

#To calculate annual mean temperature
MAAT <- stack(Tmin, Tmax)
MAAT <- calc(MAAT, fun = mean, na.rm = T)
writeRaster(MAAT, file.path("S:/UGA-project/Output/MAAT/MAAT2016"), driver = "GeoTiff", overwrite = TRUE)

#Temp <- list.files("S:/UGA-project/Output")
MAST <- MAAT + 1
#writeRaster(MAST, file.path("S:/UGA-project/Output/MAST"), driver = "GeoTiff", overwrite = TRUE)
#To read raster
#MAST <- raster("S:/UGA-project/Output/MAST.grd")

reclass_df <- c(-Inf, 0, 1,
                0, 8, 2,
                8, 15, 3,
                15, 22, 4,
                22, Inf, 5)
reclass_df

reclass_m <- matrix(reclass_df,
                    ncol = 3,
                    byrow = TRUE)

# reclassify the raster using the reclass object - reclass_m
classified_Temp <- reclassify(MAST, reclass_m)

# view reclassified data
barplot(classified_Temp, main = "Number of pixels in each class")reclass_df <- c(8, 15, 1,
                15, 22, 2
)

# assign all pixels that equal 0 to NA or no data value
#chm_classified[chm_classified == 0] <- NA

# plot reclassified data on basis of bar plot info
plot(classified_Temp,
     legend = FALSE,
     col = c("palegoldenrod", "palegreen2"), axes = TRUE,
     main = "Classified Soil Temperature")

legend("bottom",
       legend = c("Mesic", "Thermic"),
       fill = c("palegoldenrod", "palegreen2"),
       border = FALSE,
       bty = "n") # turn off legend border

# Crop using extent, rasterize polygon and finally, create poly-raster
#          **** This is the code that you are after ****  

OK_STR <- mask(classified_Temp, mask=OK)

# Plot results
plot(OK_STR)
classified_OK_STR <- reclassify(OK_STR, reclass_m)

# plot reclassified data
plot(classified_OK,
     legend = FALSE,
     col = c("palegoldenrod", "palegreen2"), axes = TRUE,
     main = "Classified Soil Temperature")

legend("left",
       legend = c("Mesic", "Thermic"),
       fill = c("palegoldenrod", "palegreen2"),
       border = FALSE,
       bty = "n") # turn off legend border


