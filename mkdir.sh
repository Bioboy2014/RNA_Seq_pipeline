#!/bin/bash

# FASTQ directories
mkdir -p FASTQ/{trimmed/unpaired,untrimmed};

# Analysis directory
mkdir -p Analysis/{fastqc,tophat,rnaseqc,htseqcount,cuffdiff,fastqc,rnaseqc,wigFiles,deseq}

# Trimmomatic directory
mkdir -p Analysis/scripts/{fastqc,tophat,rnaseqc,htseqcount,cuffdiff,fastqc,rnaseqc,wigFiles,deseq};

