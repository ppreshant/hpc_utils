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

# source this file to help load modules (needed in non-interactive sessions)
source ~/.bashrc

# load modules
module load rclone

# script written by Claude AI, 9/Sep/26			 
# thread: https://claude.ai/chat/757340ed-043a-47e8-93b5-e20bc1b1b23f

set -euo pipefail

# --------- change these directories as needed ---------------------------------
REMOTE="onedrive_csu:Databases/Novogene NGS sequencing/Madison/4NCMLibrary_Novogene"
LOCAL="./stage" # stage data here before simplifying directories
FINAL="./clean"
# ------------------------------------------------------------------------------
mkdir -p "$LOCAL"
mkdir -p "$FINAL"

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
rclone copy "$REMOTE" "$LOCAL" --include "*.fq.gz" -P $MT_FLAGS

##############################################
# Step 2: grab MD5 manifests from each library folder
##############################################
echo "== Transferring MD5 manifests =="
rclone copy "$REMOTE" "$LOCAL" --include "*.txt" -P

##############################################
# Step 3: verify checksums, but only for .fq.gz entries.
# The manifests only ever covered the originally-uploaded compressed files;
# raw .fq copies extracted separately by your collaborator have no valid
# reference here, so we don't check those.
##############################################
echo "== Verifying .fq.gz checksums =="
find "$LOCAL" -iname "*.txt" | while read -r md5file; do
    dir=$(dirname "$md5file")
    echo "  checking $dir"
    while read -r expected fname; do
        [[ "$fname" == *.fq.gz ]] || continue
        target="$dir/$fname"
        if [[ -f "$target" ]]; then
            actual=$(md5sum "$target" | awk '{print $1}')
            if [[ "$actual" == "$expected" ]]; then
                echo "    [ok]   $fname"
            else
                echo "    [FAIL] $fname  expected=$expected got=$actual"
            fi
        fi
    done < "$md5file"
done

##############################################
# Step 4: bulk-compress raw .fq files already sitting locally
##############################################
# echo "== Compressing raw .fq files with pigz =="
# find "$LOCAL" -type f -name "*.fq" | while read -r f; do
#    echo "  compressing $f"
#    pigz -p "${SLURM_CPUS_PER_TASK:-8}" -f "$f"
# done

##############################################
# Step 5: flatten the directory structure - pull compressed files out of their internal dirs
# (e.g. LIB/foo/foo_R1.fq.gz -> LIB2/foo_R1.fq.gz) ; clean empty dirs
##############################################
mv "$LOCAL"/*/*.fq.gz $FINAL/

find "$LOCAL" -mindepth 1 -type d -empty -delete

echo "moved files into flatted dir:"
echo $FINAL
echo ""
echo "Done. Review [FAIL] lines above for anything needing re-download."
