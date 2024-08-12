library(tidyverse, warn.conflicts = FALSE)
library(future, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)
library(furrr, warn.conflicts = FALSE)
library(agclimtools, warn.conflicts = FALSE)
options(dplyr.summarise.inform = FALSE)

Data_AgGrids <- function(file_path){
  
  print(file_path)
  
  path_split <- str_split(file_path, pattern = "/", simplify = TRUE)
  
  name_split <- str_split(path_split[,3], pattern = "_", simplify = TRUE)
  
  lat = as.numeric(name_split[,2])
  lon = as.numeric(name_split[,3])
  
  df1 <-read_binary(paste0("/weka/data/lab/adam/data/metdata/VIC_ext_maca_v2_binary_westUSA/", file_path), num_vars = 8) %>% 
    mutate(Week = lubridate::week(ymd(date)),
           Year = lubridate::year(ymd(date)),
           Month = lubridate::month(ymd(date)),
           DOY = lubridate::yday(ymd(date))) %>% 
    mutate(lat = lat,
           lon = lon) %>% distinct() %>% na.omit()
  
  ## Obtaining the Tmax and Tmin for each grid across each month
  ## df1 <- df1 %>% mutate(lat_lon=paste("data","_",lat,"_",lon))
  ## df$lat_lon = gsub(" ", "", df$lat_lon)
  df1 <- df1 %>% group_by(Year, DOY, lat, lon) %>% dplyr::mutate(Tavg=(tmax+tmin)/2)%>% distinct()  
  
  df8 <- rep() ## masterfile
  i=1
  j=1
  Tb = 0
  Tc = 30
  df2 <- read.csv("/home/supriya.savalkar/Planting_Date/Scripts/Wheat_PD_EP.csv")
  
  df1 <- df1 %>% dplyr::select("date", "Month", "Year", "DOY","lat","lon","tmin","tmax", "Tavg" )
  df1 <- df1 %>% dplyr::mutate(GDD = ifelse(Tavg < Tb, Tb, ifelse(Tb<Tavg & Tavg<Tc, Tavg-Tb, Tc-Tb)))
  
  ## Testing the for loop for the entire dataframe that is needed
  
  n <- length(unique(df2$PD_ID))
  
  for (i in 1: n) {
    df3 <- df1 %>% dplyr::filter(DOY >= (df2$Wheat_PD[i]))
    df3 <- df3 %>% dplyr::group_by(lat,lon, Year) %>% mutate(GDD_cum=cumsum(GDD))
    df3 <- df3 %>% dplyr::filter(GDD_cum <= 1800)
    df3 <- df3 %>% dplyr::mutate(Pheno_Stage=case_when(0<=GDD_cum & GDD_cum<=110 ~'Emergence/Root_growth',
                                                       110<GDD_cum & GDD_cum<=440 ~'Tillering/Shoot_growth',
                                                       440<GDD_cum & GDD_cum<=670 ~'Jointing/Leaf_inititation',
                                                       670<GDD_cum & GDD_cum<=1110 ~'Heading/Terminal_Spikelet',
                                                       1100<GDD_cum & GDD_cum<=1300 ~'Flowering/Anthesis',
                                                       1300<GDD_cum & GDD_cum<=1675 ~'Milking_Dough/Grainfill',
                                                       GDD_cum>1675 ~'Maturity/Grainfill'))
    df3 <- df3 %>% dplyr::group_by(lat, lon, Year) %>% dplyr::mutate(Crop_cycle =max(DOY)+1-min(DOY))
    df3 <- df3 %>% dplyr::group_by(lat, lon) %>% dplyr::mutate(Crop_cycle_avg =mean(Crop_cycle)) %>% distinct()
    df3$PD <- (df2$PD_ID[i])
    
    df4 <- df1 %>% 
      dplyr::select("lat","lon","date","Month", "Year", "DOY", "tmin", "tmax") %>% 
      dplyr::filter(DOY >= (df2$Wheat_PD[i]-1)) %>%
      dplyr::group_by(lon, lat) %>%
      rename(tmax=tmax, tmin=tmin) %>%
      nest() %>% dplyr::mutate(data=map2(data,lat,add_hourly_temps, 0:23)) %>% unnest(data)
    
    df5 <- df3 %>% left_join(df4)
    
        df5 <- df5 %>% dplyr::mutate(Temp_category_2 = if_else(Pheno_Stage=='Emergence/Root_growth' & (temp<=-17.2),'LL',
                                                 if_else(Pheno_Stage=='Emergence/Root_growth' & (-17.23<temp & temp<=4.23),'CL',
                                                 if_else(Pheno_Stage=='Emergence/Root_growth' & (4.23<temp & temp<=8.23),'SOL1',
                                                 if_else(Pheno_Stage=='Emergence/Root_growth' & (8.23<temp & temp<=12.23),'SOL2',
                                                 if_else(Pheno_Stage=='Emergence/Root_growth' & (12.23<temp & temp<=16.33),'SOL3',
                                                 if_else(Pheno_Stage=='Emergence/Root_growth' & (16.33<temp& temp<=18.07),'OT',
                                                 if_else(Pheno_Stage=='Emergence/Root_growth' & (18.07<temp & temp<=22.79),'SOH',
                                                 if_else(Pheno_Stage=='Emergence/Root_growth' & (22.79<temp & temp<=47.5),'CH',
                                                 if_else(Pheno_Stage=='Emergence/Root_growth' & (temp>47.5),'LH',
                                                 if_else(Pheno_Stage=='Tillering/Shoot_growth' & (temp<=-17.2),'LL',
                                                 if_else(Pheno_Stage=='Tillering/Shoot_growth' & (-17.2<temp & temp<=5.26),'CL',
                                                 if_else(Pheno_Stage=='Tillering/Shoot_growth' & (5.26<temp & temp<=9.17),'SOL1',
                                                 if_else(Pheno_Stage=='Tillering/Shoot_growth' & (9.17<temp & temp<=13.08),'SOL2',
                                                 if_else(Pheno_Stage=='Tillering/Shoot_growth' & (13.08<temp & temp<=17),'SOL3',
                                                 if_else(Pheno_Stage=='Tillering/Shoot_growth' & (17<temp& temp<=20.8),'OT',
                                                 if_else(Pheno_Stage=='Tillering/Shoot_growth' & (20.8<temp & temp<=20.9),'SOH',
                                                 if_else(Pheno_Stage=='Tillering/Shoot_growth' & (20.9<temp & temp<=47.5),'CH',
                                                 if_else(Pheno_Stage=='Tillering/Shoot_growth' & (temp>47.5),'LH',
                                                 if_else(Pheno_Stage=='Jointing/Leaf_inititation' & (temp<=-17.2),'LL',
                                                 if_else(Pheno_Stage=='Jointing/Leaf_inititation' & (-17.2<temp & temp<=2.02),'CL',
                                                 if_else(Pheno_Stage=='Jointing/Leaf_inititation' & (2.02<temp & temp<=7.76),'SOL1',
                                                 if_else(Pheno_Stage=='Jointing/Leaf_inititation' & (7.76<temp & temp<=13.50),'SOL2',
                                                 if_else(Pheno_Stage=='Jointing/Leaf_inititation' & (13.50<temp & temp<=19.25),'SOL3',
                                                 if_else(Pheno_Stage=='Jointing/Leaf_inititation' & (19.25<temp& temp<=21.75),'OT',
                                                 if_else(Pheno_Stage=='Jointing/Leaf_inititation' & (21.75<temp & temp<=22.55),'SOH',
                                                 if_else(Pheno_Stage=='Jointing/Leaf_inititation' & (22.55<temp & temp<=47.5),'CH',
                                                 if_else(Pheno_Stage=='Jointing/Leaf_inititation' & (temp>47.5),'LH',
                                                 if_else(Pheno_Stage=='Heading/Terminal_Spikelet' & (temp<=-17.2),'LL',
                                                 if_else(Pheno_Stage=='Heading/Terminal_Spikelet' & (-17.2<temp & temp<=2.99),'CL',
                                                 if_else(Pheno_Stage=='Heading/Terminal_Spikelet' & (2.99<temp & temp<=6.56),'SOL1',
                                                 if_else(Pheno_Stage=='Heading/Terminal_Spikelet' & (6.56<temp & temp<=10.13),'SOL2',
                                                 if_else(Pheno_Stage=='Heading/Terminal_Spikelet' & (10.13<temp & temp<=13.7),'SOL3',
                                                 if_else(Pheno_Stage=='Heading/Terminal_Spikelet' & (13.7<temp& temp<=18.3),'OT',
                                                 if_else(Pheno_Stage=='Heading/Terminal_Spikelet' & (18.3<temp & temp<=20),'SOH',
                                                 if_else(Pheno_Stage=='Heading/Terminal_Spikelet' & (20<temp & temp<=47.5),'CH',
                                                 if_else(Pheno_Stage=='Heading/Terminal_Spikelet' & (temp>47.5),'LH','NIL')))))))))))))))))))))))))))))))))))))
    
    df5 <- df5 %>% dplyr::mutate(Temp_category = if_else(Pheno_Stage=='Flowering/Anthesis' & (temp<=-17.2),'LL',
                                                 if_else(Pheno_Stage=='Flowering/Anthesis' & (-17.2<temp & temp<=11.12),'CL',
                                                 if_else(Pheno_Stage=='Flowering/Anthesis' & (11.12<temp & temp<=14.82),'SOL1',
                                                 if_else(Pheno_Stage=='Flowering/Anthesis' & (14.82<temp & temp<=18.52),'SOL2',
                                                 if_else(Pheno_Stage=='Flowering/Anthesis' & (18.52<temp & temp<=21.25),'SOL3',
                                                 if_else(Pheno_Stage=='Flowering/Anthesis' & (21.25<temp& temp<=24.75),'OT',
                                                 if_else(Pheno_Stage=='Flowering/Anthesis' & (24.75<temp & temp<=27),'SOH',
                                                 if_else(Pheno_Stage=='Flowering/Anthesis' & (27<temp & temp<=47.5),'CH',
                                                 if_else(Pheno_Stage=='Flowering/Anthesis' & (temp>47.5),'LH',
                                                 if_else(Pheno_Stage=='Milking_Dough/Grainfill' & (temp<=-17.2),'LL',
                                                 if_else(Pheno_Stage=='Milking_Dough/Grainfill' & (-17.2<temp & temp<=14.45),'CL',
                                                 if_else(Pheno_Stage=='Milking_Dough/Grainfill' & (14.45<temp & temp<=17.79),'SOL1',
                                                 if_else(Pheno_Stage=='Milking_Dough/Grainfill' & (17.79<temp & temp<=21.13),'SOL2',
                                                 if_else(Pheno_Stage=='Milking_Dough/Grainfill' & (21.13<temp & temp<=24.47),'SOL3',
                                                 if_else(Pheno_Stage=='Milking_Dough/Grainfill' & (24.47<temp& temp<=27.53),'OT',
                                                 if_else(Pheno_Stage=='Milking_Dough/Grainfill' & (27.53<temp & temp<=30),'SOH',
                                                 if_else(Pheno_Stage=='Milking_Dough/Grainfill' & (30<temp & temp<=47.5),'CH',
                                                 if_else(Pheno_Stage=='Milking_Dough/Grainfill' & (temp>47.5),'LH',
                                                 if_else(Pheno_Stage=='Maturity/Grainfill' & (temp<=-17.2),'LL',
                                                 if_else(Pheno_Stage=='Maturity/Grainfill' & (-17.2<temp & temp<=14.45),'CL',
                                                 if_else(Pheno_Stage=='Maturity/Grainfill' & (14.45<temp & temp<=17.79),'SOL1',
                                                 if_else(Pheno_Stage=='Maturity/Grainfill' & (17.79<temp & temp<=21.13),'SOL2',
                                                 if_else(Pheno_Stage=='Maturity/Grainfill' & (21.13<temp & temp<=24.47),'SOL3',
                                                 if_else(Pheno_Stage=='Maturity/Grainfill' & (24.47<temp& temp<=27.53),'OT',
                                                 if_else(Pheno_Stage=='Maturity/Grainfill' & (27.53<temp & temp<=30),'SOH',
                                                 if_else(Pheno_Stage=='Maturity/Grainfill' & (30<temp & temp<=47.5),'CH',
                                                 if_else(Pheno_Stage=='Maturity/Grainfill' & (temp>47.5),'LH', df5$Temp_category_2))))))))))))))))))))))))))))

    df5 <- df5 %>% dplyr::mutate(hour24=hour+1) %>% dplyr::mutate(hour_diff=hour24-hour) %>% 
      dplyr::group_by(Year, lat, lon, PD, Pheno_Stage) %>% 
      dplyr::mutate(Hour_stage=sum(hour_diff)) %>%
      dplyr::group_by(Year, lat, lon, PD, Pheno_Stage, Temp_category) %>%
      dplyr::mutate(Hour_temp_category=sum(hour_diff)) %>% 
      dplyr::mutate(Fraction=Hour_temp_category/Hour_stage*100)
    
    df6 <- df5 %>%
      dplyr::select(Year, lat, lon, PD, Pheno_Stage,Hour_stage, Hour_temp_category, Temp_category, Fraction) %>%
      distinct()
    
    # df6 <- df6 %>% dplyr::group_by(lat,lon, PD, Pheno_Stage, Temp_category) %>% 
    #   dplyr::mutate(Mean_fract=mean(Fraction)) %>% dplyr::ungroup() %>% dplyr::select(lat,lon, PD, Pheno_Stage, Temp_category,Mean_fract) %>%
    #   dplyr::distinct()
    
    df6 <- df6 %>% mutate(lat = lat,
                          lon = lon,
                          model = path_split[, 1],
                          climate_proj = path_split[, 2])
    
    df7 <- rbind(df8,df6)
    df8 <- df7
  }
  df9 <- rbind(df10, df8)
  df10 <- df9
}

models <- list.dirs("/weka/data/lab/adam/data/metdata/VIC_ext_maca_v2_binary_westUSA/", full.names = FALSE, recursive = FALSE)

## lat_lon_csv <- read.csv("/home/supriya.savalkar/Planting_Date/Scripts/Ag_Grids_Kamiak.csv")
lat_lon_csv <- read.csv("/home/supriya.savalkar/Planting_Date/Scripts/Ag_Grids_WestUSA.csv")
##states <- unique(lat_lon_csv$State)
states <- unique(lat_lon_csv$lat_lon)

args = commandArgs(trailingOnly=TRUE)
a_loc <- states[as.numeric(args[1])]
print(args)
print(a_loc)

# lat_lon_state <- lat_lon_csv %>%
#   dplyr::filter(State == a_loc)

lat_lon_state <- lat_lon_csv %>%
  dplyr::filter(lat_lon %in% a_loc)

#state <- unique(lat_lon_state$State)
#county <- unique(lat_lon_county$NAME.x)
state <- unique(lat_lon_state$lat_lon)
file_name <- lat_lon_state$lat_lon
climate_proj <- c("rcp45")

file_path <- expand_grid(models, climate_proj, file_name) %>%
  mutate(file_path = paste(models, climate_proj, file_name, sep = "/")) %>%
  pull(file_path)

existing_file_paths <- file_path[file.exists(file.path("/weka/data/lab/adam/data/metdata/VIC_ext_maca_v2_binary_westUSA/", file_path))]

df10<-rep()

df <- future_map_dfr(existing_file_paths, Data_AgGrids)

## This creates the database, OP stands for output and IP stands for input.
## write_csv(df, paste0("/weka/data/project/agaid/supriya/Planting_Date/Future/West_US/RCP45/Wheat/",state,".csv"))
saveRDS(df, paste0("/weka/data/project/agaid/supriya/Planting_Date/Future/West_US/RCP45/Wheat/",state,".rds"))
