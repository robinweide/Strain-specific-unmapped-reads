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
my $all = '';

foreach my $QUERY (@QUERY){
        chomp $QUERY;
        my $Qname = basename($QUERY);
        my @values = split(/\t/,$QUERY);
        chomp $values[3];
        print $values[3]."\n";
        #print "cd ".$values[3]."\n";
        
       
# CELERA-mapping


       `sed  \'\/\^\@$values[1]\/ s\/\[\:\/\]\[12\]\$\/\/\' \/data\_fedor12\/robin\/Q\_C\_Y\_C\/$values[3]\/1\_\* \| grep \-o \"\@$values[1]\[\^\ \  \]\*\" \| sort \| uniq \| sed \'s\/\^\@\/\/\' \| sed \'s\/\[\:\/\]\[12\]\$\/\/\' \| sort \| uniq \| wc \-l \| awk \'\{print \$1\*2\}\'`;
 print "\n";

  
}