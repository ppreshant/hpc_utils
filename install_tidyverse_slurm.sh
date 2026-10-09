#!/bin/bash

#SBATCH --nodes=1
#SBATCH --job-name=post-process-dimsum
#SBATCH --output=logs_slurm/post_%j.out
#SBATCH --error=logs_slurm/post_%j.err
#SBATCH --time=0:20:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=3G
#SBATCH --qos=cpu-normal
#SBATCH -p acpu


module load miniforge
mamba create -n tidyverse -y r-base r-tidyverse

mamba list r-tidyverse