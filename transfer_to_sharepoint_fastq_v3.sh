#!/bin/bash

#SBATCH --nodes=1
#SBATCH --job-name=novogene_dl
#SBATCH --output=novogene_dl_%j.out
#SBATCH --error=novogene_dl_%j.err
#SBATCH --time=2:00:00          
#SBATCH --cpus-per-task=8
#SBATCH --mem=6G
#SBATCH --qos=cpu-normal
#SBATCH -p acpu

source ~/.bashrc

# load modules
module purge
module load rclone

# script written by Claude AI, 9/Sep/26			 
# thread: https://claude.ai/chat/757340ed-043a-47e8-93b5-e20bc1b1b23f


set -euo pipefail

REMOTE="onedrive_csu:Databases/Novogene NGS sequencing/LOKYA/TheoAptz/lane_files_fastq_gz/"
LOCAL="./theoAptz_lokya/"

mkdir -p "$LOCAL"

MT_FLAGS="--multi-thread-streams=4 --multi-thread-cutoff=200M"


##############################################
# Step 0: Check the directories being transferred
##############################################
echo "== list of directories =="
rclone lsd "$REMOTE"


##############################################
# Step 1: bulk-transfer all pre-compressed .fq.gz files
# (preserves the library subfolder structure automatically)
##############################################
echo "== Transferring .fq.gz files =="
rclone copy "$LOCAL" "$REMOTE" -P $MT_FLAGS
