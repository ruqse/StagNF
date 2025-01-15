#!/bin/bash



module load conda
source conda_init.sh && conda activate /proj/naiss2023-23-521/private/Faruk/CONDA_ENVs/StagNFenv
module load bioinfo-tools Nextflow
export NXF_HOME=/crex/proj/naiss2023-23-521/nobackup/Analyses/tools/nextflow && export PATH=${NXF_HOME}:${PATH} && export NXF_TEMP=$SNIC_TMP

