#!/bin/bash
#SBATCH --job-name=modisco_avg
#SBATCH --mem=128G
#SBATCH --cpus-per-task=4
#SBATCH --time=4-0
#SBATCH --partition=engreitz
#SBATCH --qos=high_p
#SBATCH --array=0
#SBATCH --output=%x_%j.log
#SBATCH --error=%x_%j.log

# 08.run_modisco.sh
# Purpose: Run TF-MoDISco on fold-averaged contribution scores (step 06/07).
#          One SLURM array job per dataset; produces ONE modisco result per
#          dataset per score type (rather than one per fold), which is then
#          used for the unified motif compendium.
#
# Why run on averaged scores:
#   Averaging contribution scores across folds before MoDISco improves
#   signal-to-noise ratio, so the discovered patterns are more reproducible
#   and biologically meaningful. This is the standard approach in the
#   Greenleaf lab ChromBPNet pipeline.
#
# score_types below: only "profile" is (re-)run here since counts modisco
# results already exist; add "counts" back to redo/extend.
#
# Partition/GPU/QOS: modisco motifs (tfmodisco-lite) is CPU-only, so this
# runs on the engreitz partition (no GPU request) with --qos=high_p. The
# default QOS on any partition caps walltime at 2 days for this account
# regardless of what sh_part's per-partition ceiling shows; --qos=high_p
# (7-day MaxWall, granted to the engreitz account) is required to actually
# get more than 2 days, which some datasets need.
#
# Input:  results/contrib_scores/{dataset}/{dataset}_average_shaps.{score_type}.h5  (step 06/07)
# Output: ${averaged_dir}/{dataset}/modisco/
#             modisco_{score_type}_results.h5
#             {score_type}_report/
#
# Usage:
#   export DATASET_DIR=/path/to/igvf_tf_collab/<dataset>
#   sbatch 08.run_modisco.sh            # dataset 0
#
# Prerequisites: 06.average_contrib_scores.sh must have completed.

SCRIPT_DIR="${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
source "${SCRIPT_DIR}/config.sh"

dataset="${datasets[${SLURM_ARRAY_TASK_ID}]}"
[[ -z "${dataset}" ]] && { echo "No dataset at array index ${SLURM_ARRAY_TASK_ID}, exiting."; exit 0; }

score_types=("profile")  # counts modisco already done; add "counts" here to redo/extend

mkdir -p "${log_dir}"
for score_type in "${score_types[@]}"; do
    mkdir -p "${averaged_dir}/${dataset}/modisco/${score_type}_report"
done

ml devel
ml system
ml cairo
ml pango/1.40.10

source "${CONDA_INIT}"
conda activate "${CONDA_ENV}"

for score_type in "${score_types[@]}"; do
    echo "[$(date)] Dataset ${dataset}: running MoDISco on averaged ${score_type} scores..."

    modisco motifs \
        -i "${averaged_dir}/${dataset}/${dataset}_average_shaps.${score_type}.h5" \
        -n 500000 \
        -o "${averaged_dir}/${dataset}/modisco/modisco_${score_type}_results.h5" \
        -w 500 \
        -v

    modisco report \
        -i "${averaged_dir}/${dataset}/modisco/modisco_${score_type}_results.h5" \
        -o "${averaged_dir}/${dataset}/modisco/${score_type}_report" \
        -s "${averaged_dir}/${dataset}/modisco/${score_type}_report" \
        -m "${ref_db_meme}"

    echo "[$(date)] Dataset ${dataset}: ${score_type} MoDISco complete"
done
