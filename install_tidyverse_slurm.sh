#!/bin/bash

#SBATCH --nodes=1
#SBATCH --job-name=install-tidyverse
#SBATCH --output=logs_slurm/%j.out
#SBATCH --error=logs_slurm/%j.err
#SBATCH --time=0:20:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=3G
#SBATCH --qos=cpu-normal
#SBATCH -p acpu


module load miniforge
mamba create -n tidyverse -y r-base r-tidyverse

mamba list r-tidyverse