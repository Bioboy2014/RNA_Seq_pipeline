#!/bin/bash
shopt -s extglob
rm !(*.gz)
gunzip *
sed -i 's,chrom=,chrom=chr,g' *
sed -i 's,chrom=chrMT,chrom=chrM,g' *
sed -i 's,_duplicates_standard_len_mode_3,,g' *
gzip *
rename "_mode_3_standard" "" *
