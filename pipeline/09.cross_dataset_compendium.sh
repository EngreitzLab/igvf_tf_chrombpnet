#!/bin/bash
#SBATCH --job-name=cross_dataset_compendium
#SBATCH --mem=64G
#SBATCH --cpus-per-task=16
#SBATCH --time=6:00:00
#SBATCH --partition=normal,engreitz
#SBATCH --output=%x_%j.log
#SBATCH --error=%x_%j.log

# 09.cross_dataset_compendium.sh
# Purpose: Build a single non-redundant motif compendium by pooling MoDISco
#          results across all four datasets in this collaboration:
#            igvf3_cardiomyocyte, igvf6_definitive_endoderm,
#            igvf11_h7_hesc, igvf_endothelial (d3 iPSC-EC)
#
# This script does NOT require DATASET_DIR; it operates at the collaboration
# root and hardcodes the four per-dataset MoDISco H5 paths.
#
# Input:  Per-dataset fold-averaged MoDISco H5s (step 08 for each dataset)
# Output (inside ${collab_dir}/results/compendium/modisco_compiled/):
#   modisco_compiled.h5         - clustered motifs for FiNeMo (cross-dataset)
#   modisco_compendium.meme     - MEME format
#   modisco_compendium.mc       - pickled MotifCompendium object
#   modisco_compendium_meta.tsv - per-motif annotations + cluster IDs
#   modisco_config.tsv          - dataset -> H5 path mapping used for this run
#
# Prerequisites: step 08 must have completed for all four datasets.
#
# Usage (submit from pipeline/ directory):
#   cd /oak/stanford/groups/engreitz/Users/opushkar/igvf_tf_collab/pipeline
#   sbatch 10.cross_dataset_compendium.sh

SCRIPT_DIR="${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
collab_dir="$(dirname "${SCRIPT_DIR}")"

out_dir="${collab_dir}/results/compendium/modisco_compiled"
log_dir="${collab_dir}/results/logs"
mkdir -p "${out_dir}" "${log_dir}"

# Shared settings (mirrors config.sh values)
CONDA_INIT="/home/groups/engreitz/Software/anaconda3/etc/profile.d/conda.sh"
motif_compendium_conda="/home/groups/engreitz/Users/opushkar/.conda/envs/motif_compendium"
ref_db_meme="/oak/stanford/groups/engreitz/Data/motif/MotifCompendium-Database-Human.meme.txt"
motif_compendium_threshold="0.95"

# Per-dataset MoDISco H5 paths
declare -A h5_map=(
    [igvf3_cardiomyocyte]="${collab_dir}/igvf3_cardiomyocyte/results/contrib_scores/igvf3_cardiomyocyte/modisco/modisco_counts_results.h5"
    [igvf6_definitive_endoderm]="${collab_dir}/igvf6_definitive_endoderm/results/contrib_scores/igvf6_definitive_endoderm/modisco/modisco_counts_results.h5"
    [igvf11_h7_hesc]="${collab_dir}/igvf11_h7_hesc/results/contrib_scores/igvf11_h7_hesc/modisco/modisco_counts_results.h5"
    [igvf_endothelial]="${collab_dir}/igvf_endothelial/results/contrib_scores/modisco/modisco_counts_results.h5"
)

# Build config TSV
config_tsv="${out_dir}/modisco_config.tsv"
echo "# dataset    modisco_h5" > "${config_tsv}"

for dataset in igvf3_cardiomyocyte igvf6_definitive_endoderm igvf11_h7_hesc igvf_endothelial; do
    h5="${h5_map[$dataset]}"
    if [[ -f "${h5}" ]]; then
        echo -e "${dataset}\t${h5}" >> "${config_tsv}"
        echo "  [OK]   ${dataset}: ${h5}"
    else
        echo "  [WARN] ${dataset}: H5 not found, skipping: ${h5}" >&2
    fi
done

n_found=$(grep -c "^[^#]" "${config_tsv}" || true)
echo "[$(date)] Config TSV: ${config_tsv} (${n_found}/4 datasets)"

if [[ "${n_found}" -eq 0 ]]; then
    echo "ERROR: no MoDISco H5s found. Run 08.run_modisco.sh for each dataset first." >&2
    exit 1
fi

# Run MotifCompendium clustering + annotation
source "${CONDA_INIT}"
conda activate "${motif_compendium_conda}"

echo "[$(date)] Running MotifCompendium across ${n_found} datasets (threshold=${motif_compendium_threshold})..."

python "${SCRIPT_DIR}/motif_compendium.py" \
    --config    "${config_tsv}" \
    --out-dir   "${out_dir}" \
    --ref-db    "${ref_db_meme}" \
    --threshold "${motif_compendium_threshold}" \
    --cpus      "${SLURM_CPUS_PER_TASK:-16}"

if [[ ! -f "${out_dir}/modisco_compiled.h5" ]]; then
    echo "ERROR: modisco_compiled.h5 not produced. Check the log above." >&2
    exit 1
fi

echo "[$(date)] Cross-dataset compendium complete."
echo "  Compiled H5  : ${out_dir}/modisco_compiled.h5"
echo "  Annotations  : ${out_dir}/modisco_compendium_meta.tsv"
echo "  MEME         : ${out_dir}/modisco_compendium.meme"
