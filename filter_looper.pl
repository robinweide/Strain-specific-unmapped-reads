#!/usr/bin/perl
use strict;
use File::Basename;
# print("input-file \t shellscript_to_use");
open(INFILE, "$ARGV[0]");

my @QUERY = <INFILE>;
close INFILE;

# open(TOOL, "$ARGV[1]");
# my $TOOL = <TOOL>;
# close TOOL;

foreach my $QUERY (@QUERY){
        chomp $QUERY;
        my $Qname = basename($QUERY);
        my @values = split(/\t/,$QUERY);
        chomp $values[3];
        print $values[3];
        system("sh ~/github/Strain-specific-unmapped-reads/map-based_filtering-Celera,Ychr,ViPro.sh $QUERY");
        print $values[0]." is done\n";
}