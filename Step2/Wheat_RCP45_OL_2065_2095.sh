#!/bin/bash
#SBATCH --partition=rajagopalan,stockle,cahnrs,cahnrs_bigmem,cahnrs_gpu,kamiak # Partition (like a queue in PBS)
#SBATCH --job-name=Wheat_RCP45_OL_2065_2095 # Job Name
#SBATCH --output=R_%j.out
#SBATCH --error=R_%j.err
#SBATCH --time=5-00:00:00    # Wall clock time limit in Days-HH:MM:SS
#SBATCH --nodes=1            # Node count required for the job
#SBATCH --mem=20GB
#SBATCH --ntasks-per-node=1  # Number of tasks to be launched per Node
#SBATCH --cpus-per-task=1    # Number of threads per task (OMP threads)

echo
echo "--- We are now in $PWD, running an R script ..."
echo
# Load R on compute node
module load r/4.1.0

Rscript --vanilla /home/supriya.savalkar/Planting_Date/Extract_Scripts/Extract_July2023/Wheat_RCP45_OL_2065_2095.R