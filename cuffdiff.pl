#!/usr/bin/perl

##################################
# Generates the cuffdiff script. #
# Usage: cuffdiff.pl genome      # 
# e.g. cuffdiff.pl hg19          #
#                                # 
# Author: Alexis Blanchet-Cohen  #
##################################

use strict;
use warnings;

my $hostname;
my $numberProcessors;

my $genome;
my $genomesFolder;
my $genomePath;
my $stranded;

my $sampleName;
my @group1;
my @group2;

my @comparison_group1;
my @comparison_group2;


# Check the number of arguments.
if ($#ARGV+1 != 3) {
  print "Wrong number of arguments.\n";
  print "Usage: cuffdiff.pl genome stranded|unstranded numberProcessors\n";
  print "e.g. cuffdiff.pl GRCm38 stranded 6\n";
  exit;
}

# Read the command line argument.
$genome = $ARGV[0];
$stranded = $ARGV[1];
$numberProcessors = $ARGV[2];

# Determine if the server is Guillimin or Gen01.
# Set the folder paths accordingly.
$hostname=`hostname`;
chomp($hostname);
if($hostname eq "gen01.ircm.priv") {
  $genomesFolder = "/stockage/genomes";
}
else {
  $genomesFolder = "/sb/project/afb-431/genomes";
}

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
elsif ($genome eq "umd3") {
  $genomePath = "$genomesFolder/Bos_taurus/Ensembl/UMD3.1";
} 
else {
  print "genome: " . $genome;
  print "Usage: cuffdiff.pl genome \n";
  print "e.g. cuffdiff.pl hg19 \n";
  exit;  
}

`mkdir cuffdiff`;
chdir("cuffdiff");

#########################
# Read the design file. #
#########################

# Open the design file
open my $design_file, "../design.txt";

# Read the 1st line. Store the labels and calculate the number of comparisons.
my $firstLine = <$design_file>;
chomp($firstLine);
my @labels = split('\t', $firstLine);
shift(@labels);
my $numberComparisons = scalar(@labels);

for(my $i=0; $i<$numberComparisons; $i++)
{
  # Reset the file pointer to the beginning of the file
  seek $design_file, 0, 0;

  @group1 = ();
  @group2 = ();	

  while (<$design_file>) {
  	if($. != 1) {
      chomp($_);
      my @fields = split('\t', $_);

      if($fields[$i+1] eq "1") {
 	    push(@group1, $fields[0]);
 	  }   	
 	  if($fields[$i+1] eq "2") {
 	    push(@group2, $fields[0]);
 	  }
 	}	 
  }
 
  push @comparison_group1, [@group1];
  push @comparison_group2, [@group2];

}

close $design_file;

############
# Cuffdiff #
############

for(my $i=0; $i<$numberComparisons; $i++)
{

  my @fields = reverse(split(',', $labels[$i]));	

  @group1=@{$comparison_group1[$i]};
  @group2=@{$comparison_group2[$i]};
  
  # Make output directory for each comparison.
  `mkdir -p "../../cuffdiff/$fields[1]_vs_$fields[0]"`;
  
  my $cuffdiff_handle = ">$fields[1]_vs_$fields[0].sh";

  open (CUFFDIFF, $cuffdiff_handle) or die "Unable to open $cuffdiff_handle";

# Print queue header for Guillimin
if($hostname ne "gen01.ircm.priv") {
  print CUFFDIFF "#!/bin/bash" . "\n";
  print CUFFDIFF "#PBS -l nodes=1:ppn=$numberProcessors" . "\n";
  print CUFFDIFF "#PBS -l walltime=3:00:00:00" . "\n";
  print CUFFDIFF "#PBS -o \$PBS_JOBNAME.sh_output" . "\n";
  print CUFFDIFF "#PBS -e \$PBS_JOBNAME.sh_error" . "\n";
  print CUFFDIFF "#PBS -V" . "\n";
  print CUFFDIFF "#PBS -N cuffdiff_$fields[0]_vs_$fields[1]" . "\n";
  print CUFFDIFF "#PBS -A afb-431-ab" . "\n\n";

  print CUFFDIFF "cd \$PBS_O_WORKDIR\n\n";

  print CUFFDIFF "export OMP_NUM_THREADS=$numberProcessors" . "\n\n";
}
  
  print CUFFDIFF "cuffdiff -p $numberProcessors";
  print CUFFDIFF " -L ";

  # Print the labels
  print CUFFDIFF $fields[0] . "," . $fields[1];

  print CUFFDIFF " -u -b $genomePath/Sequence/WholeGenomeFasta/genome.fa --max-bundle-frags 1000000";
  if ($stranded eq "stranded")
  {
     print CUFFDIFF " --library-type fr-firststrand"; 
  }
  print CUFFDIFF " -o ../../cuffdiff/$fields[1]_vs_$fields[0] $genomePath/Annotation/Genes/genes.gtf ";

  # Cycle through all the sample names in group 2 to print the paths to the BAM files.
  for (my $j = 0; $j< scalar(@group2); $j++) {
    $sampleName=$group2[$j];
    print CUFFDIFF "../../tophat/$sampleName/accepted_hits.bam";
    if($j != scalar(@group2)-1)
    {
      print CUFFDIFF ",";
    }
  }
  
  print CUFFDIFF " ";

  # Cycle through all the sample names in group 1 to print the paths to the BAM files.
  for (my $j = 0; $j< scalar(@group1); $j++) {
    $sampleName=$group1[$j];
    print CUFFDIFF "../../tophat/$sampleName/accepted_hits.bam";
    if($j != scalar(@group1)-1)
    {
      print CUFFDIFF ",";
    }
  }

  # Send the output to a file if running on Gen01.
  if($hostname eq "gen01.ircm.priv") {
    print CUFFDIFF " &> $fields[0]_vs_$fields[1].sh_output";
  }

  close(CUFFDIFF);

}

`submitJobs.py`;


