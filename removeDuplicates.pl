#!/usr/bin/perl

###########################################
# Generates the removeDuplicates script.  #
# Usage: removeDuplicates.pl genome       # 
# e.g. removeDuplicates.pl hg19           #
#                                         # 
# Author: Alexis Blanchet-Cohen           #
########################################### 

use strict;
use warnings;

my $stranded;

my @sampleNames;
my $sampleName;

# Store all the sample directories' names in tophat.
@sampleNames = `ls ../../tophat`;

`mkdir samtoolsSort`;

#############
# removeDuplicates #
#############

# Cycle through all the sample names.
for (my $i = 0; $i< scalar @sampleNames; $i++) {

  $sampleName=$sampleNames[$i];
  chomp($sampleName);

  my $samtoolsSortScriptName = "samtoolsSort_$sampleName";
  my $removeDuplicatesScriptName = "removeDuplicates_$sampleName";

  open (samtoolsSort, ">samtoolsSort/$samtoolsSortScriptName.sh") or die "Unable to open >$samtoolsSortScriptName.sh";
  open (removeDuplicates, ">$removeDuplicatesScriptName.sh") or die "Unable to open >$removeDuplicatesScriptName.sh";

  print samtoolsSort "samtools sort -o ../../../tophat/$sampleName/accepted_hits.bam sorted_$sampleName 1> ../../../tophat/$sampleName/sorted.bam 2> $samtoolsSortScriptName.sh_error";

  print removeDuplicates "java -jar /usr/local/tools/picard-tools-1.96/MarkDuplicates.jar INPUT=../../tophat/$sampleName/sorted.bam OUTPUT=../../tophat/$sampleName/duplicates_removed.bam REMOVE_DUPLICATES=TRUE METRICS_FILE=metrics.txt &> $removeDuplicatesScriptName.sh_error";

  close(removeDuplicates);
}

