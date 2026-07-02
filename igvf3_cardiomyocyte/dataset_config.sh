#!/bin/bash
# dataset_config.sh - igvf3_cardiomyocyte
# Sourced by config.sh after results_path and data_path are set.
# DATASET_DIR is also available (set before running any pipeline script).

# Experiment parameters
# TODO: replace "sample" with actual condition/timepoint labels
peak_type="all"
datasets=( "igvf3_cardiomyocyte" )
bias_dataset="igvf3_cardiomyocyte"

# Use folds=( "0" ) for a quick single-fold test run
folds=( "0" "1" "2" "3" "4" )

# Input data
# Verify fragment file naming matches: ${dataset}_fragments.tsv.gz
fragments_path="${DATASET_DIR}/data/fragments"
folds_dir="/oak/stanford/groups/engreitz/Users/opushkar/igvf_tf_collab/folds"

# Reference genome files
genome_path="/oak/stanford/groups/engreitz/Users/opushkar/igvf_tf_collab/genome"
genome_fa="${genome_path}/hg38.fa"
chrom_sizes="${genome_path}/hg38.chrom.sizes"
blacklist="${genome_path}/blacklist.bed.gz"

# Bias model configuration (steps 03-04)
bias_factors=( "0.5" "0.6" "0.7" "0.8" )
bias_suffixes_sweep=( "_05" "_06" "_07" "_08" )

# Per-fold bias model selection (fill in after running 04.select_bias.sh)
declare -A fold_bias_suffix=(
    [0]="_08"
    [1]="_08"
    [2]="_06"
    [3]="_08"
    [4]="_07"
)
