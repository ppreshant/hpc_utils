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

REMOTE="onedrive_csu:Databases/Novogene NGS sequencing/LOKYA/DELLA design04 Enriched lib 091426/"
LOCAL="./della_enriched_library_lokya"

MT_FLAGS="--multi-thread-streams=4 --multi-thread-cutoff=200M"


##############################################
# Step 0: Check the destination directory contents
##############################################
echo "== list of directories =="
rclone lsd "$REMOTE"


##############################################
# Step 1: bulk-transfer all pre-compressed .fq.gz files
# (preserves the library subfolder structure automatically)
##############################################
echo "== Transferring .fq.gz files =="
rclone copy "$LOCAL" "$REMOTE" --include "*.fq.gz" -P $MT_FLAGS

echo "transfer complete at $(date '+%Y-%m-%d %H:%M:%S %Z')"
