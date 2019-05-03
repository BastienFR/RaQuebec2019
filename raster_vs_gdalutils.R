



library(raster)
library(gdalUtils)
library(magrittr)
library(tictoc)

mainPath <- "C:/Users/DXD9163/Desktop/RaQuebec"

base.rast <- list.files(paste0(mainPath, "/data/landsat/nord"), pattern = ".TIF$", full.names = T) %>% 
  grep("B2|B3|B4|B5",., value = T)


#### Changer la projection
###  Avec Raster:

ras.brut.ras <- stack(base.rast)

epsg32198 <- "+proj=lcc +lat_1=60 +lat_2=46 +lat_0=44 +lon_0=-68.5 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

tic("time to reproject Landsat image with Raster")
ras.32198.ras <- projectRaster(ras.brut.ras, crs = CRS(epsg32198))
toc()



###  Avec gdalUtils:

tic("time to reproject Landsat image with gdalUtils")
ras.32198.ras <- vector(mode = "list", length = length(base.rast))
for(i in base.rast){
 gdalwarp(srcfile = i,
          dstfile = paste0(mainPath, "/temp_files/", basename(i)),
          t_srs = epsg32198,
          overwrite = T
          )
}
toc()




#### Changer la projection, l'origine et la résolution

### Raster
tic("time to morph Landsat image with Raster")
ras.32198.ras <- projectRaster(ras.brut.ras, crs = CRS(epsg32198))

gabarit <- raster(nrows=12169, ncols=12007, xmn=-295600, xmx=-55460, ymn=264340, ymx=507720, 
                  crs=CRS(epsg32198), resolution=c(20,20))

ras.32198.ras_resamp <- resample(ras.32198.ras, 
                                 gabarit, 
                                 filename = paste0(mainPath, "/temp_files/", "morph_utils_", basename(base.rast)[1]),
                                 bylayer=TRUE)

toc()


### gdalUtils
tic("time to morph Landsat image with gdalUtils")
for(i in base.rast){
  gdalwarp(srcfile = i,
           dstfile = paste0(mainPath, "/temp_files/", "morph_utils_", basename(i)),
           t_srs = epsg32198,
           tap=T,
           tr=c(20,20),
           overwrite = T
  )
}

toc()

temp <- raster(paste0(mainPath, "/temp_files/", "morph_", basename(i)))


#### adding crop

library(sf)
dist_elec <- st_read("data/vdq-districtelectoral.shp") %>% 
  st_transform(crs=32198)


### raster
tic("time to crop Landsat image with Raster")


ras.32198.crop <- crop(ras.32198.ras_resamp, dist_elec)
ras.32198.mask <- mask(ras.32198.crop, st_zm(dist_elec))
toc()
### gdalUtils



#### adding crop et masque



#######  test avec mosaique landsat du CFL

file.mos <- "data/landsat/Mosaique_2018/Qc_landsat2018_30m_federal_lcc.tif"


#### Changer la projection
###  Avec Raster:

mos.brut.ras <- stack(file.mos)[[1]]

epsg3798 <- "+proj=lcc +lat_1=50 +lat_2=46 +lat_0=44 +lon_0=-70 +x_0=800000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"

rasterOptions(tmpdir="d://") 

tic("time to reproject the Landsat mosaique image with Raster")
mos.3798.ras <- projectRaster(mos.brut.ras, crs = CRS(epsg3798))    # 27722.9 secondes
toc(log = TRUE)



###  Avec gdalUtils:

tic("time to reproject Landsat mosaique image with gdalUtils")
gdalwarp(srcfile = here::here(file.mos),
         dstfile = here::here(paste0("/temp_files/", basename(file.mos))),
         t_srs = epsg3798,
         overwrite = T
)
toc(log=TRUE)

ras.32198.ras <- vector(mode = "list", length = length(base.rast))
for(i in base.rast){
  gdalwarp(srcfile = i,
           dstfile = paste0(mainPath, "/temp_files/", basename(i)),
           t_srs = epsg3798,
           overwrite = T
  )
}
toc()


tic.log(format = F)


