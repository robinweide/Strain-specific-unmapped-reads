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
        print $values[3];
        #print "cd ".$values[3]."\n";
        chdir($values[3]);
        
        $all = 'all.fastq';
        if (-e $all) {
                print "All.fastq Exists!";
        }
        else{
                `bedtools bamtofastq \-i $values[0] \-fq all\.fastq`;
        }
        `grep \-o \"$values[1]\[\^    \]\*\" nY\_\*\.fastq \| sort \| uniq \| sed \'s\/\^\@\/\/\' \> nameA\.lst`;
        `seqtk subseq all\.fastq name\.lst \> ready\_for\_denovo\.fastq`;
        print $values[3]." is done\n";
        chdir "..";
}