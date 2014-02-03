#!/usr/bin/perl

################################################################
# Generates the reorderIndex and the RNA-SeQC scripts.         #
# Usage: rnaseqc.pl genome numberProcessors                    # 
# e.g. rnaseqc.pl GRCm38                                       #
# All the applications are single threaded.                    #
#                                                              # 
# Author: Alexis Blanchet-Cohen                                #
################################################################

use strict;
use warnings;

my $genome;
my $genomePath;
my $GENOMES = "/stockage/genomes";
my $TOOLS = "/usr/local/tools";

my @sampleNames;
my $sampleName;

# Check the number of arguments.
if ($#ARGV+1 != 1) {
  print "Wrong number of arguments.\n";
  print "Usage: rnaseqc.pl genome \n";
  print "e.g. rnaseqc.pl GRCm38\n";
  exit;
}

# Read the command line argument.
$genome = $ARGV[0];

#Set the path to the genome and annotations
if($genome eq "GRCh37") { 
  $genomePath = "$GENOMES/Homo_sapiens/Ensembl/GRCh37";
}
elsif($genome eq "hg19") { 
  $genomePath = "$GENOMES/Homo_sapiens/UCSC/hg19";
}
elsif ($genome eq "NCBIM37") {
  $genomePath = "$GENOMES/Mus_musculus/Ensembl/NCBIM37";
}
elsif ($genome eq "GRCm38") {
  $genomePath = "$GENOMES/Mus_musculus/Ensembl/GRCm38";
}
elsif ($genome eq "mm10") {
  $genomePath = "$GENOMES/Mus_musculus/UCSC/mm10";
}
elsif ($genome eq "sacCer3") {
  $genomePath = "$GENOMES/Saccharomyces_cerevisiae/UCSC/sacCer3";
}
elsif ($genome eq "dm3") {
  $genomePath = "$GENOMES/Drosophila_melanogaster/UCSC/dm3";
} 
elsif ($genome eq "umd3") {
  $genomePath = "$GENOMES/Bos_taurus/Ensembl/UMD3.1";
} 
else {
  print "genome: " . $genome;
  print "Usage: reorderIndex.pl genome \n";
  print "e.g. reorderIndex.pl GRCm38 \n";
  exit;  
}

`mkdir rnaseqc`;
chdir("rnaseqc");

#############
# RNA-SeQC #
#############

# Create the output directory
`mkdir ../../rnaseqc`;

# Store all the sample directories' names in tophat/reference.
@sampleNames = `ls ../../tophat`;

open (RNASEQC, '>rnaseqc.sh') or die "Unable to open rnaseqc.sh";

# picard tools reorder. samtools index.
# Cycle through all the sample names.
for (my $i = 0; $i< scalar @sampleNames; $i++) {

  $sampleName=$sampleNames[$i];
  chomp($sampleName);
 
  # Reorder 
  print RNASEQC "java -jar";
  print RNASEQC " $TOOLS/picard-tools-1.96/ReorderSam.jar";
  print RNASEQC " I=../../tophat/$sampleName/accepted_hits.bam";
  print RNASEQC " OUTPUT=../../tophat/$sampleName/$sampleName\_sorted_accepted_hits.bam";
  print RNASEQC " REFERENCE=$genomePath/Sequence/WholeGenomeFasta/genome.fa &> ReorderSam_$sampleName.sh_error";
  print RNASEQC "\n\n";

  # Index
  print RNASEQC "samtools index";
  print RNASEQC " ../../tophat/$sampleName/$sampleName\_sorted_accepted_hits.bam 1> samtools_index_$sampleName.sh_output 2> samtools_index_$sampleName.sh_error";
  print RNASEQC "\n\n";
  
}

#RNA-SeQC

print RNASEQC "java -jar $TOOLS/RNA-SeQC_v1.1.7.jar";

print RNASEQC " -o ../../rnaseqc/ -r $genomePath/Sequence/WholeGenomeFasta/genome.fa";
print RNASEQC " -t $genomePath/Annotation/Genes/genes.gtf";
print RNASEQC " -s sampleFile.txt 1> rnaseqc.sh_output 2> rnaseqc.sh_error";
  
close(RNASEQC);

# SampleFile.txt
open (SAMPLEFILE, '>sampleFile.txt') or die "Unable to open sampleFile.txt";
print SAMPLEFILE "Sample\tID\tBam File\tNotes\n";
# Cycle through all the sample names.
for (my $i = 0; $i< scalar @sampleNames; $i++) {
  $sampleName=$sampleNames[$i];
  chomp($sampleName);
  print SAMPLEFILE "$sampleName";
  print SAMPLEFILE "\t../../tophat/$sampleName/$sampleName\_sorted_accepted_hits.bam";
  print SAMPLEFILE "\t$sampleName";
  print SAMPLEFILE "\n";
}
close(SAMPLEFILE);


# Make files executable
`submitJobs.py`;
