#!/usr/bin/env python

"""Aligns reads in FASTQ files to reference genome."""

import argparse
import subprocess
import sys
import glob

__author__ = 'Alexis Blanchet-Cohen'
__date__ = '2013-01-10' 

# Parse arguments
parser = argparse.ArgumentParser(description='Aligns reads in FASTQ files to reference genome.')
parser.add_argument("-g", "--genome", help="reference genome")
parser.add_argument("-s", "--stranded", help="strandedness", default="yes")
parser.add_argument("-t", "--trimmed", help="FASTQ files trimmed", default="no")
parser.add_argument("-p", "--processors", help="number of processes")
args = parser.parse_args()

#Set the path to the genome and annotations
if(args.genome == "GRCh37"): 
    args.genomePath = "/stockage/genomes/Homo_sapiens/Ensembl/GRCh37"

elif(args.genome == "hg19"): 
    args.genomePath = "/stockage/genomes/Homo_sapiens/UCSC/hg19"

elif(args.genome == "NCBIM37"):
    args.genomePath = "/stockage/genomes/Mus_musculus/Ensembl/NCBIM37"

elif(args.genome == "GRCm38"):
    args.genomePath = "/stockage/genomes/Mus_musculus/Ensembl/GRCm38"

elif(args.genome == "mm10"):
    args.genomePath = "/stockage/genomes/Mus_musculus/UCSC/mm10"

elif(args.genome == "sacCer3"):
    args.genomePath = "/stockage/genomes/Saccharomyces_cerevisiae/UCSC/sacCer3"

elif(args.genome == "dm3"):
    args.genomePath = "/stockage/genomes/Drosophila_melanogaster/UCSC/dm3"

elif(args.genome == "BDGP5.25"):
    args.genomePath = "/stockage/genomes/Drosophila_melanogaster/Ensembl/BDGP5.25"

elif(args.genome == "ce10"):
    args.genomePath = "/stockage/genomes/Caenorhabditis_elegans/UCSC/ce10"
 
elif(args.genome == "umd3"):
    args.genomePath = "/stockage/genomes/Bos_taurus/Ensembl/UMD3.1"

else:
    sys.exit("The genome " + args.genome + " does not exist")    

os.mkdir("tophat")
os.chdir("tophat");

# Recover the filenames and the corresponding filenames.
sampleNamesFile = open ("../sampleNames.txt");

fileNames = []
sampleNames = []

for line in sampleNamesFile:
    line = line.rstrip()      # Remove trailing whitespace.
    if line:                  # Only process non-empty lines.
        fields = line.split('\t');
        fileNames.append(fields[0])
        samplesNames.append(fields[1]

sampleNamesFile.close()

##########
# TopHat #
##########

# Cycle through all the sample names.
for i in range(0,fileNames.length()/2):

    sampleName=sampleNames[i*2];

    fileNameR1 = fileNames[i*2];
    fileNameR2 = fileNames[i*2+1];

    # Make the sample directory for the TopHat output
    os.mkdirs("../../tophat/" + sampleName);

    tophatScript = open(tophatScriptName, "w")

    tophatScript.write("tophat2 --rg-library \"L\" --rg-platform \"ILLUMINA\" --rg-platform-unit \"X\" --rg-sample \"" + sampleName + "\" --rg-id \"runX\"");

    if (args.genome == "ce10"):
        tophatScript.write(" --min-intron-length 30 --max-intron-length 30000");

    tophatScript.write(" --no-novel-juncs -p " + args.processors); 

    if (stranded == "stranded"):
        tophatScript.write(" --library-type fr-firststrand");

    tophatScript.write(" -G args.genomePath/Annotation/Genes/genes.gtf");  
    tophatScript.write(" -o ../../tophat/" + sampleName);
    tophatScript.write(" args.genomePath/Sequence/Bowtie2Index/genome");

    if (args.trimmed == "untrimmed"):
        tophatScript.write(" ../../../FASTQ/untrimmed/" + fileNameR1);
        tophatScript.write(" ../../../FASTQ/untrimmed/" + fileNameR2);
        
    else:
        tophatScript.write(" ../../../FASTQ/trimmed/" + fileNameR1);
        tophatScript.write(" ../../../FASTQ/trimmed/" + fileNameR2);  

    tophatScript.write(TOPHAT " &> " + tophatScriptName + ".sh_output");

    tophatScript.close()

subprocess.call("submitJobs.py");
