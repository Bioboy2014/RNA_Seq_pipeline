#!/usr/bin/perl

#######################################
# Generates the fastqc scripts.       #
# Usage: fastqc.pl numberProcessors   # 
#                                     # 
# Author: Alexis Blanchet-Cohen       #
#######################################

use strict;
use warnings;

# Create output directory
`mkdir ../../fastqc`;

##########
# FASTQC #
##########

# Create script directories
`mkdir untrimmed`;
`mkdir trimmed`;

# Create output directories
`mkdir -p ../../fastqc/untrimmed`;
`mkdir -p ../../fastqc/trimmed`;

# Store all the FASTQ filenames in the FASTQ/untrimmed directory.
my @FASTQfilenames=`ls ../../../FASTQ/untrimmed/* | xargs -n1 basename`;

#fastqcuntrimmed.sh

foreach (@FASTQfilenames)  {

  my $FASTQfilename = $_;
  chomp($FASTQfilename);
  
  my $fastqcScript = "fastqc_" . $FASTQfilename . "_untrimmed.sh";
  my $fastqcScriptHandle = ">untrimmed/$fastqcScript";

  open (FASTQCUNTRIMMED, $fastqcScriptHandle) or die "Unable to open $fastqcScriptHandle";
  print FASTQCUNTRIMMED "fastqc --noextract -o ../../../fastqc/untrimmed";

  print FASTQCUNTRIMMED " ../../../../FASTQ/untrimmed/" . $FASTQfilename;
  
  print FASTQCUNTRIMMED " 1> $fastqcScript\_output 2> $fastqcScript\_error";

  close(FASTQCUNTRIMMED);
}



#fastqctrimmed.sh

foreach (@FASTQfilenames)  {

  my $FASTQfilename = $_;
  chomp($FASTQfilename);
  
  my $fastqcScript = "fastqc_" . $FASTQfilename . "_trimmed.sh";
  my $fastqcScriptHandle = ">trimmed/$fastqcScript";

  open (FASTQCTRIMMED, $fastqcScriptHandle) or die "Unable to open $fastqcScriptHandle";
  print FASTQCTRIMMED "fastqc --noextract -o ../../../fastqc/trimmed";

  print FASTQCTRIMMED " ../../../../FASTQ/trimmed/" . $FASTQfilename;
  
  print FASTQCTRIMMED " 1> $fastqcScript\_output 2> $fastqcScript\_error";

  close(FASTQCTRIMMED);
}

`chmod u+x trimmed/*.sh`;
`chmod u+x untrimmed/*.sh`;
 
