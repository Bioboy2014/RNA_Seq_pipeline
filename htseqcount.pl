#!/usr/bin/perl

#######################################################
# Generates the htseqcount scripts.                   #
# Usage: htseqcount.pl genomeName stranded|unstranded # 
# e.g. htseqcount.pl hg19 unstranded                  #
#                                                     # 
# Author: Alexis Blanchet-Cohen                       #
#######################################################

use strict;
use warnings;

my $genome;
my $genomePath;

my $stranded;

my @sampleNames;
my $sampleName;

my $htseqcountScriptName;

my $hostname;
my $host;

my $genomesFolder = "/stockage/genomes";

# Check the number of arguments.
if ($#ARGV+1 != 2) {
  print "Wrong number of arguments.\n";
  print "Usage: htseqcount.pl genome stranded|unstranded\n";
  print "e.g. htseqcount.pl hg19 stranded\n";
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
  print "Usage: htseqcount.pl hg19 stranded|unstranded numberProcessors\n";
  print "e.g. htseqcount.pl hg19 stranded 12\n";
  exit;  
}

`mkdir htseqcount`;
chdir("htseqcount");

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
# htseqcount #
##############

`mkdir ../../htseqcount`;

# Cycle through all the sample names.
for (my $i = 0; $i < scalar(@sampleNames)/2; $i++) {

  $sampleName=$sampleNames[$i*2];

  $htseqcountScriptName = "htseqcount_" . $sampleName;
  my $htseqcountScriptName_handle = ">" . $htseqcountScriptName . ".sh";

  open (HTSEQCOUNT, $htseqcountScriptName_handle) or die "Unable to open HTSEQCOUNTScriptName";

  print HTSEQCOUNT "samtools sort -n ../../tophat/$sampleName/accepted_hits.bam ../../tophat/$sampleName/accepted_hits_sorted_by_read_name";

  print HTSEQCOUNT "\n\n";

  print HTSEQCOUNT "samtools view ../../tophat/$sampleName/accepted_hits_sorted_by_read_name.bam | htseq-count";

  if ($stranded eq "stranded") {
    print HTSEQCOUNT " --stranded=reverse";
  }
  elsif ($stranded eq "stranded") {
    print HTSEQCOUNT " --stranded=no";
  }

  print HTSEQCOUNT " --minaqual 1";
  
  print HTSEQCOUNT " --mode=intersection-strict - $genomePath/Annotation/Genes/genes.gtf > ../../htseqcount/$sampleName.txt";

  print HTSEQCOUNT " 2> $htseqcountScriptName\.sh_error";

  print HTSEQCOUNT "\n\n";

  print HTSEQCOUNT "rm accepted_hits_sorted_by_read_name.bam";

  close(HTSEQCOUNT)
}

`submitJobs.py`;
