#!/bin/bash
#
#Run for the control sample with SARS-CoV-2:
#
TAG="VERO";
#
# Download:
rm -f sars_cov2_vero.fastq;
wget https://zenodo.org/record/3722580/files/sars_cov2_vero.fastq
#
# To reduce sample size:
gto_fastq_to_fasta < sars_cov2_vero.fastq > sars_cov2_vero.fasta
#
rm -f sars_cov2_vero.fastq;
#
# Run FALCON-meta:
FALCON -v -F -l 47 -c 70 -n 8 -t 5000 -Z -y complexity_$TAG.com -x out_$TAG.txt sars_cov2_vero.fasta VDB_w_SARS2.fa
FALCON-filter -v -F -t 0.5 -o positions_$TAG.pos complexity_$TAG.com
FALCON-filter-visual -v -F -o draw_$TAG.map positions_$TAG.pos
#
