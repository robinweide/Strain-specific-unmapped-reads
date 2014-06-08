#!/usr/bin/perl
use strict;
use File::Basename;
# print("input\-file \t shellscript_to_use");
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
        chomp $values[0];
        # `mkdir $values[0]` or die;
        # print $values[0]." has begun\n";
        #print "cd ".$values[3]."\n";
        # chdir($values[0]);
      	foreach my $hoi (@QUERY){
      		chomp $hoi;
            my $Qnam = basename($hoi);
      		my @valus = split(/\t/,$hoi);
        	chomp $valus[0];
        	if ($valus[0] eq $values[0]){next};
			`\/home\/robin\/bin\/compareads\-2\.0\.2\/compare\_reads \-a $values[0] -b $valus[0] -k 39 -t 2  \&\> $Qname\_in\_$Qnam\.compa\-out`;
			`\/home\/robin\/bin\/compareads\-2\.0\.2\/extract\_reads $values[0] $Qname\_in\_$Qnam\.bv`;
		}

        



        # print $values[3]." is done\n";
        # chdir "..";
}

