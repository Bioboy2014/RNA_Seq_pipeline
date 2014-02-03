#!/usr/bin/perl

###################################################
# Generates the dexseq scripts.                   #
# Usage: dexseq.pl genomeName stranded|unstranded # 
# e.g. dexseq.pl hg19 unstranded                  #
#                                                 # 
# Author: Alexis Blanchet-Cohen                   #
###################################################

use strict;
use warnings;

my $genome;
my $genomePath;

my $stranded;

my @sampleNames;
my $sampleName;

my $dexseqScriptName;

my $hostname;
my $host;

my $genomesFolder = "/stockage/genomes";

# Check the number of arguments.
if ($#ARGV+1 != 2) {
  print "Wrong number of arguments.\n";
  print "Usage: dexseq.pl genome stranded|unstranded\n";
  print "e.g. dexseq.pl hg19 stranded\n";
  exit;
}

# Read the command line argument.
$genome = $ARGV[0];
$stranded = $ARGV[1];

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
elsif ($genome eq "umd3") {
  $genomePath = "$genomesFolder/Bos_taurus/Ensembl/UMD3.1";
} 
else {
  print "genome: " . $genome;
  print "Usage: dexseq.pl hg19 stranded|unstranded numberProcessors\n";
  print "e.g. dexseq.pl hg19 stranded 12\n";
  exit;  
}

`mkdir dexseqcount`;
chdir("dexseqcount");

# Recover the filenames and the corresponding filenames.
open (MYFILE, '../sampleNames.txt');

while (<MYFILE>) {
	chomp($_);
	next if /^\s*$/; # Skip blank lines. 
	my @fields = split('\t', $_);
	push(@sampleNames,$fields[1]);	 
}

close (MYFILE); 

##############
# dexseq #
##############

`mkdir ../../dexseqcount`;

# Cycle through all the sample names.
for (my $i = 0; $i < scalar(@sampleNames)/2; $i++) {

  $sampleName=$sampleNames[$i*2];

  $dexseqScriptName = "dexseq_" . $sampleName;
  my $dexseqScriptName_handle = ">" . $dexseqScriptName . ".sh";

  open (dexseqHandle, $dexseqScriptName_handle) or die "Unable to open dexseqScriptName";

  print dexseqHandle "samtools view ../../tophat/$sampleName/samtoolsSortN.bam | python /stockage/lib64/R/R-3.0.2/DEXSeq/python_scripts/dexseq_count.py --paired=yes";

  if ($stranded eq "stranded") {
    print dexseqHandle " --stranded=reverse";
  }
  elsif ($stranded eq "stranded") {
    print dexseqHandle " --stranded=no";
  }
  
  print dexseqHandle " $genomePath/Annotation/Genes/dexseq.gtf - ../../dexseqcount/$sampleName.txt";

  print dexseqHandle " 2> $dexseqScriptName\.sh_error";


  close(dexseqHandle)
}

`submitJobs.py`;
