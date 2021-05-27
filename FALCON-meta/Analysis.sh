#!/bin/bash
#
gunzip reads_1.fa.gz reads_2.fa.gz VDB_w_SARS2.fa.gz
#
FALCON -v -F -m 18:500:1:5/10 -c 60 -n 8 -t 5000 -Z -y complexity.com -x out.txt reads_1.fa:reads_2.fa VDB_w_SARS2.fa
FALCON-filter -v -F -t 0.5 -o positions.pos complexity.com
FALCON-filter-visual -v -F -o draw.map positions.pos
#
