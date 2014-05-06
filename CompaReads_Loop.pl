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
        `awk \'BEGIN\{P\=1\}\{if\(P\=\=1\|\|P\=\=2\)\{gsub\(\/\^\[\@\]\/\,\"\>\"\)\;print\}\; if\(P\=\=4\)P\=0\; \P\+\+\}\' $values[1] \> $values[0].fa`;
      				foreach my $hoi (@QUERY){
      				chomp $hoi;
      				my @valus = split(/\t/,$hoi);
        			chomp $valus[0];
        			if ($valus[0] == $values[0]){next};
					`awk \'BEGIN\{P\=1\}\{if\(P\=\=1\|\|P\=\=2\)\{gsub\(\/\^\[\@\]\/\,\"\>\"\)\;print\}\; if\(P\=\=4\)P\=0\; \P\+\+\}\' $valus[1] \> $valus[0].fa`;
					`\/home\/robin\/bin\/compareads\-2\.0\.2\/compare\_reads \-a $values[0].fa -b $valus[0].fa -k 39 -t 2`;
					 }

        



        # print $values[3]." is done\n";
        # chdir "..";
}