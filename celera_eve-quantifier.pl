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
        `cd $values[3]`;
        system("bedtools intersect -wa -u -abam properly_mapped_to_celera.bam -b /data_fedor12/robin/databases/EVE/mappingC/EVE_mapped-to-Celera_overlapped.bed > reads_celera_eve.bam");
        system("samtools view reads_celera_eve.bam | awk '{print $1}' | sort | uniq > readnames-eve_celera.lst");
        system("samtools view properly_mapped_to_celera.bam | awk '{print $1}' | sort | uniq > all_celera_reads.lst");
        system("wc -l all_celera_reads.lst >> report_balfour.stats");
        system("wc -l readnames-eve_celera.lst >> report_balfour.stats");
        print $values[3]." is done\n";
        system("cd ..");
}