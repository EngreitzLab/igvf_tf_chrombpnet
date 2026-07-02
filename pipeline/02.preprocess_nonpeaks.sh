#!/bin/bash
#SBATCH --job-name=preprocess_nonpeaks
#SBATCH --mem=100G
#SBATCH --time=6:00:00
#SBATCH --partition=normal,engreitz
#SBATCH --output=%x_%j.log
#SBATCH --error=%x_%j.log

# 02.preprocess_nonpeaks.sh
# Purpose: Generate GC-matched negative (non-peak) regions for each
#          dataset x fold combination using 'chrombpnet prep nonpeaks'.
#

SCRIPT_DIR="${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
source "${SCRIPT_DIR}/config.sh"

source "${CONDA_INIT}"
conda activate "${CONDA_ENV}"

set -euo pipefail

for dataset in "${datasets[@]}"; do
    for fold in "${folds[@]}"; do
        out_prefix="${data_path}/${dataset}/output_${peak_type}_fold_${fold}"
        negatives_file="${out_prefix}_negatives.bed"

        if [[ -f "${negatives_file}" ]]; then
            echo "Found existing negatives for ${dataset} fold_${fold}, skipping..."
            continue
        fi

        echo "Generating negatives for ${dataset} fold_${fold}..."
        chrombpnet prep nonpeaks \
            -g "${genome_fa}" \
            -p "${data_path}/${dataset}_${peak_type}_peaks_no_blacklist.narrowPeak" \
            -c "${chrom_sizes}" \
            -fl "${folds_dir}/fold_${fold}.json" \
            -br "${blacklist}" \
            -o "${out_prefix}"

        echo "  -> written to ${negatives_file}"
    done
done

echo "Done: 02.preprocess_nonpeaks.sh"
