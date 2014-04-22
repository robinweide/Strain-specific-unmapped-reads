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
        chomp $values[3];
        print $values[3];
        #print "cd ".$values[3]."\n";
        chdir($values[3]);

        `bedtools intersect \-wa \-u \-abam properly\_mapped\_to\_celera\.bam \-b \/data\_fedor12\/robin\/databases\/EVE\/mappingC\/EVE\_mapped\-to\-Celera\_overlapped\.bed \> reads\_celera\_eve\.bam`;
        `samtools view reads\_celera\_eve\.bam | awk \'\{print \$1\}\' | sort | uniq \> readnames\-eve\_celera\.lst`;
        `samtools view properly\_mapped\_to\_celera\.bam | awk \'\{print \$1\}\' | sort | uniq \> all\_celera\_reads\.lst`;
        `wc \-l all\_celera\_reads\.lst \>\> report\_balfour\.stats`;
        `wc \-l readnames\-eve\_celera\.lst \>\> report\_balfour\.stats`;

        print $values[3]." is done\n";
        chdir "..";
}