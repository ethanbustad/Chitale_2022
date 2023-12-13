# Chitale_2022
RNAseq Analysis Code used in P Chitale, Nature Communications 2022

Jason H. Yang Lab @ Rutgers New Jersey Medical School

Author: Avi Shah

Date: Nov 3, 2022

https://github.com/as2654/rna-seq-tb0 

These scripts is used to process RNA sequencing reads from NCBI SRA for the compendium analyses published in P Chitale, Nature Communications 2022. This work was performed on Rutgers' Amarel high performance computing cluster.

Running split_accessions.sh with the correct parameters will take all the rows in the given TSV while, which should correspond to SRA accessions. For each SRR sequencing run under that accession, and for whether that run is paired-end or single-end, a call is made  to the appropriate script to get the counts for a given reference.
