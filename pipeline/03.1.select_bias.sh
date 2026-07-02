#!/bin/bash

datasets_path="/oak/stanford/groups/engreitz/Users/opushkar/igvf_tf_collab"
SCRIPT_DIR="${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

export DATASET_DIR="${datasets_path}/igvf11_h7_hesc"
source "${SCRIPT_DIR}/config.sh"
source "${CONDA_INIT}"
conda activate "${CONDA_ENV}"

python "${SCRIPT_DIR}/select_bias_model.py" \
    --core-path /oak/stanford/groups/engreitz/Users/opushkar/igvf_tf_collab \
    --biases 05 06 07 08 09 1\
    --folds 0 1 2 3 4 \
    --dataset igvf11_h7_hesc \
    --peak-type all

# export DATASET_DIR="${datasets_path}/igvf_endothelial"
# source "${SCRIPT_DIR}/config.sh"
# source "${CONDA_INIT}"
# conda activate "${CONDA_ENV}"

# python "${SCRIPT_DIR}/select_bias_model.py" \
#     --core-path /oak/stanford/groups/engreitz/Users/opushkar/igvf_tf_collab \
#     --biases 05 06 07 08 \
#     --folds 0 1 2 3 4 \
#     --dataset igvf_endothelial \
#     --peak-type all

# export DATASET_DIR="${datasets_path}/igvf3_cardiomyocyte"
# source "${SCRIPT_DIR}/config.sh"
# source "${CONDA_INIT}"
# conda activate "${CONDA_ENV}"

# python "${SCRIPT_DIR}/select_bias_model.py" \
#     --core-path /oak/stanford/groups/engreitz/Users/opushkar/igvf_tf_collab \
#     --biases 05 06 07 08 \
#     --folds 0 1 2 3 4 \
#     --dataset igvf3_cardiomyocyte \
#     --peak-type all

# export DATASET_DIR="${datasets_path}/igvf6_definitive_endoderm"
# source "${SCRIPT_DIR}/config.sh"
# source "${CONDA_INIT}"
# conda activate "${CONDA_ENV}"

# python "${SCRIPT_DIR}/select_bias_model.py" \
#     --core-path /oak/stanford/groups/engreitz/Users/opushkar/igvf_tf_collab \
#     --biases 05 06 07 08 \
#     --folds 0 1 2 3 4 \
#     --dataset igvf6_definitive_endoderm \
#     --peak-type all

