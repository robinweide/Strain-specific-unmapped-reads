#!/usr/bin/perl
use strict;
use File::Basename;
open(INFILE, "$ARGV[0]"); # list of samples-fastq's to compare

my @QUERY = <INFILE>;
close INFILE;

foreach my $QUERY (@QUERY){
        chomp $QUERY;
        my $Qname = basename($QUERY);
        my @values = split(/\t/,$QUERY);
        chomp $values[0];
      	foreach my $hoi (@QUERY){
      		chomp $hoi;
      		my @valus = split(/\t/,$hoi);
        	chomp $valus[0];
        	if ($valus[0] eq $values[0]){next};
			`\/bin\/compareads\-2\.0\.2\/compare\_reads \-a $values[0] -b $valus[0] -k 25 -t 2  \&\> $values[0]\_in\_$valus[0].compa\-out`;
			`\/bin\/compareads\-2\.0\.2\/extract\_reads $values[0] $values[0]\_in\_$valus[0]\.bv`;
		}
}
