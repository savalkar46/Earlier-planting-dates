library(tidyverse, warn.conflicts = FALSE)
library(future, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)
library(furrr, warn.conflicts = FALSE)
library(agclimtools, warn.conflicts = FALSE)
options(dplyr.summarise.inform = FALSE)

Wheat <- list.files("/weka/data/project/agaid/supriya/Planting_Date/Future/RCP45/Wheat")
Path <- "/weka/data/project/agaid/supriya/Planting_Date/Future/RCP45/Wheat"
Masterfile <- rep()
i=1
length(Wheat)
## This helps to loop in all the binary files do the median and mean on the date and plot
## This needs to be modified for the RCP 4.5 and RCP 8.5
for (i in 1:length(Wheat)) {
  OP_Grid <- readRDS(paste0(Path,"/", Wheat[i]))
  OP_Grid$Grid_ID <- Wheat[i]
  OP_Grid <- OP_Grid |> subset(Year>=2045 & Year<=2075)
  OP_Grid <- OP_Grid |> group_by(lat, lon, PD, Pheno_Stage, Temp_category, model, climate_proj ) |> 
    mutate(Med_Frac=median(Fraction),
           Mean_Frac=mean(Fraction)) |> ungroup() |> 
    group_by(lat, lon, PD, Pheno_Stage, Temp_category, climate_proj ) |> 
    mutate(Median_Frac=median(Med_Frac),
           Mean_Fract=mean(Mean_Frac),
           Mean_Med_Frac=median(Mean_Frac)) |> ungroup() |>
    dplyr::select(lat, lon, PD, Pheno_Stage, Temp_category, Median_Frac, Mean_Fract, Mean_Med_Frac, climate_proj, Grid_ID) |> 
    distinct()
  OP_Grid$Case <- "Wheat_Overlap_2045_2075"
  Masterfile2 <- rbind(Masterfile,OP_Grid)
  Masterfile <- Masterfile2
}
saveRDS(Masterfile, paste0("/weka/data/project/agaid/supriya/Planting_Date/Extracted/Wheat_RCP45_OL_2045_2075_V02.rds"))