#!/usr/bin/perl

use strict;
use warnings;

my $hostname;
my $host;
my $toolsFolder;

my @files;
my $fileR1;
my $fileR2;

$toolsFolder = "/usr/local/tools";

open (TRIMMOMATIC, '>trimmomatic.sh') or die "Unable to write to trimmomatic.sh";

# Store all the FASTQ filenames in the FASTQ/untrimmed directory.
@files=` ls ../../../FASTQ/untrimmed/* | xargs -n1 basename`;

# Cycle through all the pairs of FASTQ files.
for (my $i = 0; $i< scalar @files; $i+=2) {
  $fileR1=$files[$i];
  chomp($fileR1);
  $fileR2=$files[$i+1];
  chomp($fileR2);

  print TRIMMOMATIC "java -jar $toolsFolder/Trimmomatic-0.30/trimmomatic-0.30.jar PE -threads 12 -phred33";
  print TRIMMOMATIC " ../../../FASTQ/untrimmed/";
  print TRIMMOMATIC $fileR1;
  print TRIMMOMATIC " ../../../FASTQ/untrimmed/";
  print TRIMMOMATIC $fileR2;
  print TRIMMOMATIC " ../../../FASTQ/trimmed/";
  print TRIMMOMATIC $fileR1;
  print TRIMMOMATIC " ../../../FASTQ/trimmed/unpaired/";
  print TRIMMOMATIC $fileR1;
  print TRIMMOMATIC " ../../../FASTQ/trimmed/";
  print TRIMMOMATIC $fileR2;
  print TRIMMOMATIC " ../../../FASTQ/trimmed/unpaired/";
  print TRIMMOMATIC $fileR2;  
  print TRIMMOMATIC " ILLUMINACLIP:/usr/local/tools/Trimmomatic-0.30/adapters/TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36";
  if($i == 0) {
    print TRIMMOMATIC " 1> trimmomatic.sh_output 2> trimmomatic.sh_error";
  }
  else {
    print TRIMMOMATIC " 1>> trimmomatic.sh_output 2>> trimmomatic.sh_error";
  }
  print TRIMMOMATIC "\n\n";
}

close(TRIMMOMATIC);

`chmod u+x *.sh`;