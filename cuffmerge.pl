#!/usr/bin/perl

####################################
# Generates the Cuffmerge script.  #
# Usage: cuffmerge.pl genomeName   # 
# e.g. cuffmerge.pl hg19           #
#                                  # 
# Author: Alexis Blanchet-Cohen    #
####################################

use strict;
use warnings;

my $hostname;
my $host;

my $genome;
my $genomesFolder;

my $numberProcessors = 12;

my @sampleNames;
my $sampleName;

my $cuffmergeScriptName;

# Check the number of arguments.
if ($#ARGV+1 != 1) {
  print "Wrong number of arguments.\n";
  print "Usage: cuffmerge.pl hg19\n";
  print "e.g. cuffmerge.pl hg19\n";
  exit;
}

# Read the command line argument.
$genome = $ARGV[0];

# Determine if the server is Guillimin or Gen01.
$hostname=`hostname`;
chomp($hostname);
if($hostname eq "gen01.ircm.priv") {
  $host = "gen01";
}
else {
 $host = "guillimin";
}

#Set the genomes folder according to the host.
if ($host eq "gen01") {
  $genomesFolder = "/stockage/genomes";
}
else {
  $genomesFolder = "/sb/project/afb-431/genomes";
}

#Set the path to the genome and annotations
if($genome eq "hg19") { 
  $genomesFolder = "$genomesFolder/Homo_sapiens/UCSC/hg19";
}
elsif ($genome eq "mm10") {
  $genomesFolder = "$genomesFolder/Mus_musculus/UCSC/mm10";
}
elsif ($genome eq "sacCer3") {
  $genomesFolder = "$genomesFolder/Saccharomyces_cerevisiae/UCSC/sacCer3";
}
elsif ($genome eq "dm3") {
  $genomesFolder = "$genomesFolder/Drosophila_melanogaster/UCSC/dm3";
} 
else {
  print "genome: " . $genome;
  print "Usage: cuffmerge.pl genome \n";
  print "e.g. cuffmerge.pl hg19 \n";
  exit;  
}


##############################
# Generate assembly_list.txt #
##############################

# Cycle through all the sample names.
# for (my $i = 0; $i < scalar(@samplesNames); $i++) {
# 
#   $sampleName=$sampleNames[$i];
# 
# }

####################
# Cuffmerge script #
####################

$cuffmergeScriptName = "cuffmerge";
my $cuffmergeScriptName_handle = ">$cuffmergeScriptName.sh";

open (CUFFMERGE, $cuffmergeScriptName_handle) or die "Unable to open $cuffmergeScriptName";

print CUFFMERGE "#!/bin/bash" . "\n";
print CUFFMERGE "#PBS -l nodes=1:ppn=$numberProcessors" . "\n";
print CUFFMERGE "#PBS -l walltime=1:00:00:00" . "\n";
print CUFFMERGE "#PBS -o \$PBS_JOBNAME" . ".shput" . "\n";
print CUFFMERGE "#PBS -e \$PBS_JOBNAME" . ".sh_error" . "\n";
print CUFFMERGE "#PBS -V" . "\n";
print CUFFMERGE "#PBS -N $cuffmergeScriptName" . "\n";
print CUFFMERGE "#PBS -A afb-431-ab" . "\n\n";

print CUFFMERGE "cd \$PBS_O_WORKDIR\n\n";

print CUFFMERGE "export OMP_NUM_THREADS=$numberProcessors" . "\n\n";

print CUFFMERGE "cuffmerge -p 12 -g $genomesFolder/Annotation/Genes/genes.gtf -s $genomesFolder/Sequence/WholeGenomeFasta/genome.fa -o ../../cuffmerge assemblies.txt";

close(CUFFMERGE)