rm !(*.gz)
gunzip *
sed -i 's,chrom=,chrom=chr,g' *
sed -i 's,chrMT,chrM,g' *
gzip *
