#!/usr/bin/perl

######################################
# Generates the findPeaks scripts.   #
# Usage: findPeaks.pl                # 
#                                    # 
# Author: Alexis Blanchet-Cohen      #
######################################

use strict;
use warnings;

my @sampleNames;
my $sampleName;

my $findPeaksScriptName;

my $toolsFolder = "/usr/local/tools";

`mkdir wigFiles`;
chdir("wigFiles");

# Create output directory
`mkdir ../../wigFiles`;

# Recover the sample names.
open (MYFILE, '../sampleNames.txt');

while (<MYFILE>) {
	chomp($_);
	next if /^\s*$/; # Skip blank lines. 
	my @fields = split('\t', $_);
	push(@sampleNames,$fields[1]);	 
}

close (MYFILE); 


#############
# Wig files #
#############

# Cycle through all the sample names.
for (my $i = 0; $i < scalar(@sampleNames)/2; $i++) {

  $sampleName=$sampleNames[$i*2];

  $findPeaksScriptName = "findPeaks_" . $sampleName;
  my $findPeaksScriptName_handle = ">$findPeaksScriptName.sh";

  open (FINDPEAKS, $findPeaksScriptName_handle) or die "Unable to open $findPeaksScriptName";

  print FINDPEAKS "java -jar $toolsFolder/VancouverShortR-4.0.16/fp4/FindPeaks.jar";
  print FINDPEAKS " -wig_step_size 10 -aligner sam -dist_type 3 -name $sampleName"; 
  print FINDPEAKS " -input ../../tophat/$sampleName/accepted_hits.bam -output ../../wigFiles ";
  print FINDPEAKS " 1> $findPeaksScriptName.sh_output 2> $findPeaksScriptName.sh_error";
  
  print FINDPEAKS "\n\n";
  
  print FINDPEAKS "\n\n";    
  
  close(FINDPEAKS)
}

`submitJobs.py`;
