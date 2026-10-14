#!/bin/bash

#SBATCH --nodes=1
#SBATCH --job-name=to-sharepoint
#SBATCH --output=logs_slurm/%j.out
#SBATCH --error=logs_slurm/%j.err
#SBATCH --time=1:00:00          
#SBATCH --cpus-per-task=3
#SBATCH --mem=6G
#SBATCH --qos=cpu-normal
#SBATCH -p acpu

source ~/.bashrc

# script written by Claude AI, 9/Sep/26			 
# thread: https://claude.ai/chat/757340ed-043a-47e8-93b5-e20bc1b1b23f


set -euo pipefail

dry_run=false
if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "--dry-run" ) ]]; then
    echo "Usage: sbatch transfer_to_sharepoint_fastq_v3.sh [--dry-run]" >&2
    exit 1
fi
if [[ "${1:-}" == "--dry-run" ]]; then
    dry_run=true
fi

# load modules
module purge
module load rclone

REMOTE="onedrive_csu:Databases/Novogene NGS sequencing/LOKYA/DELLA design04 Enriched lib 091426/data/"
LOCAL="./della_enriched_library_lokya"

MT_FLAGS="--multi-thread-streams=4 --multi-thread-cutoff=200M"
rclone_flags=(-P $MT_FLAGS)
if [[ "$dry_run" == true ]]; then
    rclone_flags+=(--dry-run)
    echo "Dry run enabled; no files will be transferred."
fi


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
rclone copy "$LOCAL" "$REMOTE" "${rclone_flags[@]}"

echo "transfer complete at $(date '+%Y-%m-%d %H:%M:%S %Z')"
