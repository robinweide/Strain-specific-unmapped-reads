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
        print $values[3]." has begun\n";
        #print "cd ".$values[3]."\n";
        `mkdir $values[3]`;
        chdir($values[3]);

` sed  \'\/\^\@$values[1]\/ s\/\[\:\/\]\[12\]\$\/\/\' $values[3]\_Unmapped\_1\.fastq \> vipro1\.fq`;
`seqtk subseq vipro1\.fq nameMv\.lst \> vipro\_m1\.fq`;
` sed  \'\/\^\@$values[1]\/ s\/\[\:\/\]\[12\]\$\/\/\' $values[3]\_Unmapped\_2\.fastq \> vipro2\.fq`;
`seqtk subseq vipro2\.fq nameMv\.lst \> vipro\_m2\.fq`;

        
# map to vipro in paired-end mode
`\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-M \/data\_fedor12\/robin\/databases\/ViPro\/ProVi\.fa vipro\_m1\.fq vipro\_m2\.fq \> viproR\.sam`;
# get organisms that properly map in pairs
`samtools view \-S \-f 2 viproR\.sam \| cut \-f3 \| sort \| uniq \-c \|sort \-nr \> Baudoinia.log`;







        chdir "..";
}