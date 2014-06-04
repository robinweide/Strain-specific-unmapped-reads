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

` sed  \'\/\^\@$values[1]\/ s\/\[\:\/\]\[12\]\$\/\/\' $values[3]\_Unmapped\_1\.fastq \> test1\.fq`;
`seqtk subseq test1\.fq nameMc\.lst \> celera\_m1\.fq`;
` sed  \'\/\^\@$values[1]\/ s\/\[\:\/\]\[12\]\$\/\/\' $values[3]\_Unmapped\_2\.fastq \> test2\.fq`;
`seqtk subseq test2\.fq nameMc\.lst \> celera\_m2\.fq`;

        
# map to celera in paired-end mode
`\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-M \/data\_fedor12\/robin\/databases\/Celera\/Alt\_Rn\_Celera\.fa celera\_m1\.fq celera\_m2\.fq \> CeleraR\.sam`;
# get reads, that properly map in pairs
`samtools view \-bS \-f 2 CeleraR\.sam \> Celera\_proper\_mappedR\.bam`;

`bedtools intersect \-abam Celera\_proper\_mappedR\.bam \-wa \-u -b \/data\_fedor12\/robin\/databases\/EVE\/CELERA\_EVE\/overlap6EveCelera\.bed \> unmappedByTechnicalMissingInCelera\.bam`;
`samtools view unmappedByTechnicalMissingInCelera\.bam | awk \'\{print \$1\}\' \| sort \| uniq \> unmappedByTechnicalMissingInCeleraReadPairs\.lst`;
`wc \-l unmappedByTechnicalMissingInCeleraReadPairs\.lst \> DoubleCask\.log`;

`grep \-Fx \-f nameMy\.lst unmappedByTechnicalMissingInCeleraReadPairs\.lst \> unmappedByTechnicalMissingInCeleraReadPairsAlsoInYchr\.lst`;
`wc \-l unmappedByTechnicalMissingInCeleraReadPairsAlsoInYchr\.lst \> DoubleCask\.log`;
        chdir "..";
}