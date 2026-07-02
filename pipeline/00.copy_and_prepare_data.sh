#!/bin/bash
#SBATCH --job-name=copy_peaks_fragments
#SBATCH --mem=10G
#SBATCH --time=2:00:00
#SBATCH --partition=normal,engreitz
#SBATCH --output=%x_%j.log
#SBATCH --error=%x_%j.log

fragments_in="/oak/stanford/groups/engreitz/Projects/IGVF-E2GPillarProject/QC_pseudobulks/multiome_data";
peaks_in="/oak/stanford/groups/engreitz/Users/kaybrand/scE2G_preprint/scE2G/results/uniformly_processed";

out_path="/oak/stanford/groups/engreitz/Users/opushkar/igvf_tf_collab";

datasets=( "igvf6" "igvf11" "igvf3" );
clusters=( "definitive_endoderm" "h7" "h9_cardio_cardiomyocte_d8" );
target_ids=( "igvf6_definitive_endoderm" "igvf11_h7_hesc" "igvf3_cardiomyocyte" );

for i in "${!datasets[@]}"
do
    dataset="${datasets[$i]}"
    cluster="${clusters[$i]}"
    target_id="${target_ids[$i]}"

    mkdir -p ${out_path}/${target_id}/data/peaks;
    mkdir -p ${out_path}/${target_id}/data/fragments;
    
    cp ${peaks_in}/${dataset}/${cluster}/Peaks/macs2_peaks.narrowPeak.sorted.candidateRegions.bed \
        ${out_path}/${target_id}/data/peaks/${target_id}_all_peaks.bed

    cp ${fragments_in}/${dataset}/${cluster}/atac_fragments_${dataset}_${cluster}.tsv.gz \
        ${out_path}/${target_id}/data/fragments/${target_id}_atac_fragments.tsv.gz
    
    zcat ${out_path}/${target_id}/data/fragments/${target_id}_atac_fragments.tsv.gz | \
        grep -P '^chr([1-9]|1[0-9]|2[0-2]|X|Y|M)\t' | \
        gzip > ${out_path}/${target_id}/data/fragments/${target_id}_atac_fragments_main_chrs.tsv.gz
done

# mkdir -p ${out_path}/genome;

# # download reference data
# wget https://www.encodeproject.org/files/GRCh38_no_alt_analysis_set_GCA_000001405.15/@@download/GRCh38_no_alt_analysis_set_GCA_000001405.15.fasta.gz \
#     -O ${out_path}/genome/hg38.fa.gz
# yes n | gunzip ${out_path}/genome/hg38.fa.gz

# # download reference chromosome sizes 
# wget https://www.encodeproject.org/files/GRCh38_EBV.chrom.sizes/@@download/GRCh38_EBV.chrom.sizes.tsv \
#     -O ${out_path}/genome/hg38.chrom.sizes

# # download reference blacklist regions 
# wget https://www.encodeproject.org/files/ENCFF356LFX/@@download/ENCFF356LFX.bed.gz \
#     -O ${out_path}/genome/blacklist.bed.gz

# # Expand the blacklist by 1057 bp on each side (half of the 2114 bp input window)
# # so that no training window overlaps a blacklisted region
# bedtools slop \
#     -i "${out_path}/genome/blacklist.bed.gz" \
#     -g "${out_path}/genome/hg38.chrom.sizes" \
#     -b 1057 > "${out_path}/genome/blacklist_slop.bed"
