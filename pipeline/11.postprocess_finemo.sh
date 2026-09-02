#!/bin/bash
#SBATCH --job-name=finemo_postprocess
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --time=4:00:00
#SBATCH --partition=normal,engreitz
#SBATCH --array=0
#SBATCH --output=%x_%j.log
#SBATCH --error=%x_%j.log

# 11.postprocess_finemo.sh
# Purpose: Generate the Fi-NeMo report for a dataset's unified hit calls:
#            finemo report - compute per-motif instance-CWM vs input-CWM
#                             similarity (cwm_similarity in motif_report.tsv)
#
# Input (from step 10):
#   {finemo_unified_dir}/{dataset}_{peak_type}/hits.tsv
#   {finemo_unified_dir}/{dataset}_{peak_type}/intermediate_inputs.npz
#
# Output:
#   {finemo_unified_dir}/{dataset}_{peak_type}/finemo_report/motif_report.tsv
#   (consumed by analysis/0.2.finemo_hit_qc.py)
#
# Usage (submit from pipeline/, DATASET_DIR must be exported):
#   DATASET_DIR=/path/to/igvf_tf_collab/igvf3_cardiomyocyte sbatch 11.postprocess_finemo.sh
#
# Prerequisites: 10.run_finemo_unified.sh must have completed for this dataset.

SCRIPT_DIR="${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
source "${SCRIPT_DIR}/config.sh"

dataset="${datasets[${SLURM_ARRAY_TASK_ID}]}"
[[ -z "${dataset}" ]] && { echo "No dataset at array index ${SLURM_ARRAY_TASK_ID}, exiting."; exit 0; }

out_dir="${finemo_unified_dir}/${dataset}_${peak_type}"
hits_tsv="${out_dir}/hits.tsv"
finemo_npz="${out_dir}/intermediate_inputs.npz"
report_dir="${out_dir}/finemo_report"

if [[ -f "${report_dir}/motif_report.tsv" ]]; then
    echo "[${dataset}] Already post-processed, skipping."
    exit 0
fi

if [[ ! -f "${hits_tsv}" ]]; then
    echo "ERROR: ${hits_tsv} not found. Run 10.run_finemo_unified.sh first." >&2
    exit 1
fi

if [[ ! -f "${finemo_npz}" ]]; then
    echo "ERROR: ${finemo_npz} not found. Run 10.run_finemo_unified.sh first." >&2
    exit 1
fi

ml biology samtools

source "${CONDA_INIT}"
conda activate "${finemo_conda}"

# Compute cwm_similarity for each motif by comparing the average CWM
# reconstructed from called instances against the input (modisco) CWM.
echo "[$(date)] [${dataset}] Running finemo report..."
finemo report \
    -r "${finemo_npz}" \
    -H "${out_dir}" \
    -o "${report_dir}"

motif_report="${report_dir}/motif_report.tsv"
if [[ ! -f "${motif_report}" ]]; then
    echo "ERROR: ${motif_report} not produced. Check finemo report output above." >&2
    exit 1
fi
echo "[$(date)] [${dataset}] Report done: ${motif_report}"
