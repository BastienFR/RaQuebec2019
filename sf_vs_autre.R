

###  simplication de couche


### sf

library(sf)
library(here)


ua <- st_read("data/UNITE_AMENAGEMENT.shp") %>% 
  st_transform(32198)


system.time(ua_simple <- st_simplify(ua, dTolerance = 10))

st_write(ua_simple, "temp_files/ua_simple_sf.shp")
file.size("temp_files/ua_simple_sf.shp")

mapview::npts(ua)
mapview::npts(st_read("data/ua_simple_sf.shp"))
mapview::npts(ua_simple)


### qgis3
library("RQGIS3")
set_env("C:/OSGeo4W64")
qgis_session_info()

find_algorithms(search_term = "generalize")
get_usage(alg = "grass7:v.generalize")

ua_simple_rqgis = run_qgis(alg = "grass7:v.generalize",
               input = here("data/UNITE_AMENAGEMENT_32198.shp"),
               output = here("temp_files/ua_simple_grass.shp"),
               error = here("temp_files/ua_simple_grass_error.shp"),
               type="1",
               threshold = "10",
               load_output = TRUE
)

file.size("temp_files/ua_simple_sf.shp")
file.size("temp_files/test_simple_grass.shp")

mapview::npts(ua)
mapview::npts(ua_simple)
mapview::npts(ua_simple_rqgis$output)


plot(ua_simple[,1])
plot(ua_simple_rqgis$output[,1])




## CP

system.time(cp <- st_read("C:/Users/DXD9163/Desktop/symplifyPC/CP_032018.shp") )
system.time(cp_simple <- st_simplify(cp, dTolerance = 0.0001))

st_write(cp_simple, "temp_files/cp_simple_sf.shp")
file.size("temp_files/cp_simple.shp")

mapview::npts(cp)
mapview::npts(cp_simple)

  
##### qgis3
library("RQGIS3")
set_env("C:/OSGeo4W64")


find_algorithms(search_term = "generalize")
get_usage(alg = "grass7:v.generalize")

systeme.time(cp_simple_grass = run_qgis(alg = "grass7:v.generalize",
               input = "C:/Users/DXD9163/Desktop/symplifyPC/CP_032018.shp",
               output = here("temp_files/cp_simple_grass.shp"),
               error = here("temp_files/cp_simple_grass_error.shp"),
               type="1",
               threshold = "0.0001",
               load_output = TRUE
               )
)

mapview::npts(cp)
mapview::npts(cp_simple)
mapview::npts(cp_simple_grass$output)




##### qgis2
library("RQGIS")
set_env("C:/OSGeo4W64")


find_algorithms(search_term = "generalize")
get_usage(alg = "grass7:v.generalize")



out = run_qgis(alg = "grass7:v.generalize",
               #input = here("data/UNITE_AMENAGEMENT_32198.shp"),
               #input = st_read("data/UNITE_AMENAGEMENT.shp") %>% as_Spatial(),
               input = ua_simple,
               #input = "data/munic_s.shp",
               output = here("temp_files/test_simple_grass.shp"),
               error = here("temp_files/test_simple_grass_error.shp"),
               threshold = "1",
               load_output = TRUE
)

params = get_args_man(alg = "grass7:v.generalize")


params$input <- here("data/UNITE_AMENAGEMENT_32198.shp")
params$input <- st_read("data/UNITE_AMENAGEMENT.shp") %>% as_Spatial()
params$output <- here("temp_files/ua_simple_grass.shp")
params$threshold <- "1.0"

out2 = run_qgis(alg = "grass7:v.generalize",
                params = params,
                load_output = TRUE)


####################

find_algorithms(search_term = "buffer")
get_usage(alg = "native:buffer")

 get_args_man(alg = "native:buffer")

out.buf = run_qgis(alg = "native:buffer",
                   INPUT = here("data/munic_s.shp"),
                   OUTPUT = here("temp_files/ua_buf_grass.shp"),
               DISTANCE = "1000",
               load_output = TRUE
)

####################


get_usage(alg = "grass7:v.buffer")

params.buf = get_args_man(alg = "grass7:v.buffer")

out.buf = run_qgis(alg = "grass7:v.buffer",
                   #input = here("data/munic_s.shp"),
                   input = ger,
                   output = here("temp_files/ua_buf_grass.shp"),
                   distance = "10",
                   type = "2",
                   load_output = TRUE
)


####################

find_algorithms(search_term = "buffer")
get_usage(alg = "saga:fixeddistancebuffer")

get_args_man(alg = "saga:fixeddistancebuffer")

out.buf = run_qgis(alg = "saga:fixeddistancebuffer",
                   SHAPES = here("data/UNITE_AMENAGEMENT_32198.shp"),
                   BUFFER = here("temp_files/ua_buf_grass.shp"),
                   DIST_FIELD_DEFAULT = "1",
                   load_output = TRUE
)

####################



library("raster")
library("rgdal")

# download German administrative areas 
ger = getData(name = "GADM", country = "DEU", level = 1)

params = get_args_man(alg = "native:centroids")
params$INPUT = "data/munic_s.shp"
params$INPUT = ger
params$OUTPUT = file.path(tempdir(), "ger_coords.shp")
out = run_qgis(alg = "native:centroids",
               params = params,
               load_output = TRUE)

plot(out)
