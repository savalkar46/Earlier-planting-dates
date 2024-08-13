# Earlier-planting-dates
This repository has the codes to replicate the analysis for any code for the paper: Earlier planting in a future climate fails to replicate historical production conditions for US spring wheat. To replicate all the results of the paper one will have to go through the four steps.

Step 1: This folder contains the codes which are used for preprocessing the historical and future GCM data. The codes fix the growth stage as per growing degree day accumulation and use growth-stage specific temperature thresholds to determine exposure to a wide range of temperatures.

Step 2: This folder contains the codes that are used to determine the mean fraction of temperature exposure for historical and future time frames. The future time frame is further divided into three sun time frames 2040s, 2060s, and 2080s.

Step 3: This folder contains the codes that are used to determine the Wasserstein distance between future temperature exposure for every growth stage, time frame, emission scenario, and planting dates (traditional and advanced) and the historical temperature exposure for traditional planting dates. 

Step 4: This folder contains the code that is used to create the plots which are in the paper.



