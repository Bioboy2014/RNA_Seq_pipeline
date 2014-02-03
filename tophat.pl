#!/usr/bin/perl

#####################################################
# Generates the Tophat scripts.                     #
# Usage: tophat.pl genomeName stranded|unstranded   # 
# e.g. tophat.pl hg19 unstranded                    #
#                                                   # 
# Author: Alexis Blanchet-Cohen                     #
#####################################################

use strict;
use warnings;

my $genome;
my $genomePath;

my $numberProcessors;
my $stranded;
my $trimmed;

my @sampleNames;
my $sampleName;

my @fileNames;
my $fileNameR1;
my $fileNameR2;

my $tophatScriptName;

my $hostname;
my $host;

my $genomesFolder = "/stockage/genomes";

# Check the number of arguments.
if ($#ARGV+1 != 4) {
  print "Wrong number of arguments.\n";
  print "Usage: tophat.pl hg19 stranded|unstranded trimmed|untrimmed numberProcessors\n";
  print "e.g. tophat.pl hg19 stranded trimmed 12\n";
  exit;
}

# Read the command line argument.
$genome = $ARGV[0];
$stranded = $ARGV[1];
$trimmed = $ARGV[2];
$numberProcessors = $ARGV[3];

#Set the path to the genome and annotations
if($genome eq "GRCh37") { 
  $genomePath = "$genomesFolder/Homo_sapiens/Ensembl/GRCh37";
}
elsif($genome eq "hg19") { 
  $genomePath = "$genomesFolder/Homo_sapiens/UCSC/hg19";
}
elsif ($genome eq "NCBIM37") {
  $genomePath = "$genomesFolder/Mus_musculus/Ensembl/NCBIM37";
}
elsif ($genome eq "GRCm38") {
  $genomePath = "$genomesFolder/Mus_musculus/Ensembl/GRCm38";
}
elsif ($genome eq "mm10") {
  $genomePath = "$genomesFolder/Mus_musculus/UCSC/mm10";
}
elsif ($genome eq "sacCer3") {
  $genomePath = "$genomesFolder/Saccharomyces_cerevisiae/UCSC/sacCer3";
}
elsif ($genome eq "dm3") {
  $genomePath = "$genomesFolder/Drosophila_melanogaster/UCSC/dm3";
} 
elsif ($genome eq "BDGP5.25") {
  $genomePath = "$genomesFolder/Drosophila_melanogaster/Ensembl/BDGP5.25";
} 
elsif ($genome eq "ce10") {
  $genomePath = "$genomesFolder/Caenorhabditis_elegans/UCSC/ce10";
} 
elsif ($genome eq "umd3") {
  $genomePath = "$genomesFolder/Bos_taurus/Ensembl/UMD3.1";
} 
else {
  print "genome: " . $genome;
  print "Usage: tophat.pl hg19 stranded|unstranded trimmed|untrimmed numberProcessors\n";
  print "e.g. tophat.pl hg19 stranded trimmed 12\n";
  exit;  
}

`mkdir tophat`;
chdir("tophat");

# Recover the filenames and the corresponding filenames.
open (MYFILE, '../sampleNames.txt');

while (<MYFILE>) {
	chomp($_);
	next if /^\s*$/; # Skip blank lines. 
	my @fields = split('\t', $_);
	push(@fileNames,$fields[0]);
	push(@sampleNames,$fields[1]);	 
}

close (MYFILE); 

##########
# TopHat #
##########

# Cycle through all the sample names.
for (my $i = 0; $i < scalar(@fileNames)/2; $i++) {

  $sampleName=$sampleNames[$i*2];

  $fileNameR1 = $fileNames[$i*2];
  $fileNameR2 = $fileNames[$i*2+1];

  # Make the sample directory for the TopHat output
  `mkdir -p ../../tophat/$sampleName`;

  $tophatScriptName = "tophat_" . $sampleName;
  my $tophatScriptName_handle = ">" . $tophatScriptName . ".sh";

  open (TOPHAT, $tophatScriptName_handle) or die "Unable to open $tophatScriptName";

  print TOPHAT "tophat2 --rg-library \"L\" --rg-platform \"ILLUMINA\" --rg-platform-unit \"X\" --rg-sample \"$sampleName\" --rg-id \"runX\"";
  if ($genome eq "ce10") {
    print TOPHAT " --min-intron-length 30 --max-intron-length 30000";
  }
  print TOPHAT " --no-novel-juncs -p $numberProcessors"; 
  if ($stranded eq "stranded") {
    print TOPHAT " --library-type fr-firststrand";
  }
  print TOPHAT " -G $genomePath/Annotation/Genes/genes.gtf";  
  print TOPHAT " -o ../../tophat/$sampleName";
  print TOPHAT " $genomePath/Sequence/Bowtie2Index/genome";
  if ($trimmed eq "untrimmed") {
    print TOPHAT " ../../../FASTQ/untrimmed/$fileNameR1";
    print TOPHAT " ../../../FASTQ/untrimmed/$fileNameR2";
  } 
  else {
    print TOPHAT " ../../../FASTQ/trimmed/$fileNameR1";
    print TOPHAT " ../../../FASTQ/trimmed/$fileNameR2";  
  } 

  print TOPHAT " &> $tophatScriptName\.sh_output";


  close(TOPHAT)
}

`submitJobs.py`;
