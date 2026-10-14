#!/usr/bin/env bash

#SBATCH --nodes=1
#SBATCH --job-name=merge-lanes-fastq
#SBATCH --output=logs_slurm/%j.out
#SBATCH --error=logs_slurm/%j.err
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=6G
#SBATCH --qos=cpu-normal
#SBATCH -p acpu

# Merge Novogene lane-split fastq.gz files into per-sample R1/R2_001.fastq.gz
# Assumes filenames like: SAMPLE_CKDLxxxx-1A_FLOWCELL_L2_1.fq.gz
# Run from inside the directory containing all the raw fastq.gz files.
# written by Claude AI, 9/Sep/26
# link: https://claude.ai/chat/ee4af6e9-5d59-4d55-850d-698abc663105

# usage: ./merge_lanes_fastq.sh [experiment_name]

set -euo pipefail

## Directory staging -------------------
# set base path for directories
base_dir="/scratch/alpine/$USER/data_staging"
# cd base_dir || { echo "Error: Could not change to base directory $base_dir"; exit 1; }
  # why CD? maybe temporary files are created here; so using scratch space is better than the home directory.

# directory to convert 
expt_dir="$1"
# check if the directory exists
if [ ! -d "$base_dir/archive/$expt_dir" ]; then
    echo "Error: Directory $base_dir/archive/$expt_dir does not exist."
    exit 1
fi


# input and output dirs
indir="$base_dir/archive/$expt_dir"          # directory with raw files
outdir="$base_dir/$expt_dir"  # where merged files will go
mkdir -p "$outdir"


## Actual merging ----------------------------------------
# Get unique sample names (text before first underscore)
samples=$(find "$indir" -type f -name '*_L*_[12].fq.gz' -exec basename {} \; | sed -E 's/_.*//' | sort -u) \
    && { echo "No input files found in $indir"; exit 1; }

for sample in $samples; do
    for read_num in 1 2; do
        outfile="$outdir/${sample}_R${read_num}_001.fastq.gz"
        # collect all lanes for this sample+read, sorted for consistent lane order
        files=$(find "$indir" -type f -name "${sample}_*_L*_${read_num}.fq.gz" | sort)

        if [ -z "$files" ]; then
            echo "WARNING: no files found for sample=$sample read=$read_num"
            continue
        fi

        echo "Merging into $outfile:"
        printf '  %s\n' $files

        # already gzipped, so raw concat of the .gz files is valid gzip too
        cat $files > "$outfile"
    done
done

echo "Done. Merged files in $outdir/"
