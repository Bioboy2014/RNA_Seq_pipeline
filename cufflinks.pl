#!/usr/bin/perl

####################################
# Generates the cufflinks script.  #
# Usage: cufflinks.pl genome       # 
# e.g. cufflinks.pl hg19           #
#                                  # 
# Author: Alexis Blanchet-Cohen    #
#################################### 

use strict;
use warnings;

my $stranded;

my $numberProcessors = 1;

my $genome;
my $genomesFolder;
my $toolsFolder;

my @sampleNames;
my $sampleName;

# Check the number of arguments.
if ($#ARGV+1 != 2) {
  print "Wrong number of arguments.\n";
  print "Usage: cufflinks.pl hg19 stranded|unstranded\n";
  print "e.g. cufflinks.pl hg19 stranded\n";
  exit;
}

# Read the command line argument.
$genome = $ARGV[0];
$stranded = $ARGV[1];


$genomesFolder = "/stockage/genomes";
$toolsFolder = "/usr/local/tools";

#Set the path to the genome and annotations
if($genome eq "hg19") { 
  $genomesFolder = "$genomesFolder/Homo_sapiens/UCSC/hg19";
}
elsif($genome eq "GRCh37") { 
  $genomesFolder = "$genomesFolder/Homo_sapiens/Ensembl/GRCh37";
}
elsif ($genome eq "mm10") {
  $genomesFolder = "$genomesFolder/Mus_musculus/UCSC/mm10";
}
elsif ($genome eq "GRCm38") {
  $genomesFolder = "$genomesFolder/Mus_musculus/Ensembl/GRCm38";
}
elsif ($genome eq "sacCer3") {
  $genomesFolder = "$genomesFolder/Saccharomyces_cerevisiae/UCSC/sacCer3";
}
elsif ($genome eq "dm3") {
  $genomesFolder = "$genomesFolder/Drosophila_melanogaster/UCSC/dm3";
}
elsif ($genome eq "umd3") {
  $genomesFolder = "$genomesFolder/Bos_taurus/Ensembl/UMD3.1";
}  
else {
  print "genome: " . $genome;
  print "Usage: cufflinks.pl genome \n";
  print "e.g. cufflinks.pl hg19\n";
  exit;  
}

# Store all the sample directories' names in tophat.
@sampleNames = `ls ../../tophat`;

#############
# Cufflinks #
#############

# Cycle through all the sample names.
for (my $i = 0; $i< scalar @sampleNames; $i++) {

  $sampleName=$sampleNames[$i];
  chomp($sampleName);

  # Make the sample directory for the Cufflinks output
  `mkdir -p ../../cufflinks/$sampleName`;

  my $cufflinksScriptName = "cufflinks_$sampleName";

  open (CUFFLINKS, ">$cufflinksScriptName.sh") or die "Unable to open >$cufflinksScriptName.sh";

  print CUFFLINKS "cufflinks -p $numberProcessors";
  print CUFFLINKS " --max-bundle-frags 1000000 -u";
  if ($stranded eq "stranded") {
    print CUFFLINKS " --library-type fr-firststrand";
  }  
  print CUFFLINKS " -b $genomesFolder/Sequence/WholeGenomeFasta/genome.fa";
  print CUFFLINKS " -G $genomesFolder/Annotation/Genes/genes.gtf";
  print CUFFLINKS " -o ../../cufflinks/$sampleName ../../tophat/$sampleName/accepted_hits.bam"; 

  print CUFFLINKS " 1> $cufflinksScriptName.sh_output 2> $cufflinksScriptName.sh_error"; 


  close(CUFFLINKS);
}

