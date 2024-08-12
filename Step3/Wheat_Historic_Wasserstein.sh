#!/bin/bash
#SBATCH --partition=rajagopalan,stockle,cahnrs,cahnrs_bigmem,cahnrs_gpu,kamiak # Partition (like a queue in PBS)
#SBATCH --job-name=Distance # Job Name
#SBATCH --output=Py_%j.out
#SBATCH --error=Py_%j.err
#SBATCH --time=2-00:00:00    # Wall clock time limit in Days-HH:MM:SS
#SBATCH --nodes=1            # Node count required for the job
#SBATCH --mem=100GB
#SBATCH --ntasks-per-node=1  # Number of tasks to be launched per Node
#SBATCH --cpus-per-task=1    # Number of threads per task (OMP threads)

echo
echo "--- We are now in $PWD, running an R script ..."
echo
# Load R on compute node
module load anaconda3 

python /home/supriya.savalkar/Planting_Date/Tradeoff/Wheat/Distance/Wheat_Historic_Wasserstein.py