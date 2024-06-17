#!/bin/bash

# activate conda/mamba environment with the following packages installed before invoking script:
# bowtie2, bbmap, pandas, samtools, trimmomatic

workdir="$1" # e.g. /active/ma_s/Ethan/HPC/FrontiersMtb_2024-06/build_compendium.0

/bin/sh "$workdir"/split_accessions.sh \
    8 \
    16GB \
    8 \
    "$workdir"/Mtb_0_sorted_H37Rv.tsv \
    "$workdir"/work_dir_NCBI \
    48:30:00 \
    GCF_000195955.2_ASM19595v2_genomic \
    GCF_000195955.2_ASM19595v2_genomic.gtf \
    $CONDA_PREFIX/opt/bbmap*/resources/adapters.fa \
    gene \
    _NCBI

/bin/sh "$workdir"/split_accessions.sh \
    8 \
    16GB \
    12 \
    "$workdir"/Mtb_0_sorted_H37Rv.tsv \
    "$workdir"/work_dir_AllandRv \
    48:30:00 \
    H37Rv_Alland \
    H37Rv_Alland.gtf \
    $CONDA_PREFIX/opt/bbmap*/resources/adapters.fa \
    transcript \
    _AllandRv