#!/bin/bash
#SBATCH --partition=rajagopalan,stockle,cahnrs,cahnrs_bigmem,cahnrs_gpu,kamiak
#SBATCH --requeue
#SBATCH --job-name=Data_AgGrids # Job Name
#SBATCH --output=R_%A_%a.out
#SBATCH --error=R_%A_%a.err
#SBATCH --time=7-00:00:00    # Wall clock time limit in Days-HH:MM:SS
#SBATCH --mem=5GB 
#SBATCH --nodes=1            # Node count required for the job
#SBATCH --ntasks-per-node=1  # Number of tasks to be launched per Node
#SBATCH --ntasks=1           # Number of tasks per array job
#SBATCH --cpus-per-task=1    # Number of threads per task (OMP threads)
#SBATCH --array=0-15028

echo
echo "--- We are now in $PWD, running an R script ..."
echo

# Load R on compute node
module load r/4.1.0

cd /home/supriya.savalkar/Planting_Date/Scripts_Future_Rerun_June2023/
echo "I am Slurm job ${SLURM_JOB_ID}, array job ${SLURM_ARRAY_JOB_ID}, and array task ${SLURM_ARRAY_TASK_ID}."
Rscript --vanilla ./GCM_RCP85_Wheat.R ${SLURM_ARRAY_TASK_ID}