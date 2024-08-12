import numpy as np
import pandas as pd
import pyreadr
import scipy.stats
from scipy.stats import wasserstein_distance

## load the files
wheat_mod =  pyreadr.read_r('/weka/data/project/agaid/supriya/Planting_Date/Tradeoff/Wheat/Wheat_Hist_Dist_Input.rds')

## correcting the format
Wheat = wheat_mod[None]

# Optimal vector
optimal = np.array([0, 0, 0, 100, 0, 0, 0])

# Initialize an empty list to store DataFrames
#data_tables_list = []
col_=['LL', 'CL', 'SOL', 'OT', 'SOH', 'CH', 'LH']

## create a new column for distance and set it to default value
Wheat['dist'] = -666

## select the columns that are needed
col_=['LL', 'CL', 'SOL', 'OT', 'SOH', 'CH', 'LH']
## loop through each row to get the distance from optimal
for idx in Wheat.index:
    # Vector with percentage changes by growth stage
    future = Wheat.loc[idx, col_]

    dist = wasserstein_distance(np.arange(7), np.arange(7), optimal, future)  # Calculate Euclidean distance
    Wheat.loc[idx, "dist"] = dist
	
## Save the file as rds
pyreadr.write_rds('/weka/data/project/agaid/supriya/Planting_Date/Tradeoff/Wheat/Wheat_Historic_Wasserstein.rds', Wheat)
