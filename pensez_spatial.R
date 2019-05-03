library(raster)
library(magrittr)
library(here)
library(dplyr)

## raster
base.rast <- list.files(here("data/landsat/nord"),
                        pattern = ".TIF$", 
                        full.names = T) %>% 
  grep("B2|B3|B4|B5",., value = T)

ras.brut.ras <- stack(base.rast)


rasterOptions(maxmemory=5e+06) # pour forcer le raster sur disque

pryr::mem_change({
NDVI <- (ras.brut.ras[[3]] - ras.brut.ras[[2]]) / (ras.brut.ras[[3]] + ras.brut.ras[[2]])

#rs4 <- calc(ras.brut.ras, fun=function(x){(x[3]-x[4])/(x[3]+x[4])})



#summary(NDVI)
clas_mat <- cbind(from = seq(-1, 0.8, .2),
                  to = seq(-0.8, 1, .2),
                  become = 1:10)

cla_NDVI <- reclassify(NDVI, clas_mat)

})

plot(cla_NDVI, main = "raster")


## DF


pryr::mem_change({
df_ras <- values(ras.brut.ras[[2:3]]) %>% 
  as.data.frame() %>% 
  setNames(c("B3", "B4"))

df_NDVI <- mutate(df_ras, ndvi = (B4-B3)/(B4+B3))
df_cla_NDVI <- mutate(df_NDVI, cla = cut(ndvi, seq(-1,1,0.2)),
                      cla = as.numeric(cla))
})

cla_NDVI_dplyr <- NDVI
values(cla_NDVI_dplyr) <- df_cla_NDVI$cla


plot(cla_NDVI_dplyr, main = "dplyr")


