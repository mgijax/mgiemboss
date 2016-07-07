#!/bin/env perl
#
# Given a fasta file, this script reformat the 
# header line of each sequence to exclude the version
# number from the accession ID
#
# Input: Fasta file
# Output: Fasta file
#
# Author: lnh
# Date: 3/2016
#

if(@ARGV<1){
  print "Usage: ./program fasta_file\n";
  exit(1);
}

my $fasta_file=$ARGV[0];
chomp($fasta_file);

if(! -f $fasta_file){
  print "$fasta_file does not exist\n";
  exit(1);
}
open(IN,"$fasta_file");
if(!IN){
  print "Could not open file $fasta_file : $!\n";
  exit(1); 
}
open(OUT,">$fasta_file.new");
while($line=<IN>){
      chomp($line);
      $line=~s/^(\>\w+)\.(\d+)\s+/$1 Version:$2 /;
      print OUT "$line\n";
}

close(IN);
close(OUT);
#
# swap the files
`mv $fasta_file $fasta_file.old`;
`mv $fasta_file.new $fasta_file`;
`rm $fasta_file.old`;

print "Program complete\n";
exit(0);
