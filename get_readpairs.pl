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
        chdir($values[3]);
        
        `samtools view \-f 64 \-b $values[0] \> First\.bam`;
        `samtools view \-f 128 \-b $values[0] \> Second\.bam`;

        `bedtools bamtofastq \-i First\.bam \-fq First\.fastq`;
        `bedtools bamtofastq \-i Second\.bam \-fq Second\.fastq`;

        `grep \-o \"$values[1]\[\^    \]\*\" nY\_\*\.fastq \| sort \| uniq \| sed \'s\/\^\@\/\/\' \> nameA\.lst`;
        `seqtk subseq First\.fastq nameA\.lst \> ready\_for\_denovo\_1\.fastq`;
        `seqtk subseq Second\.fastq nameA\.lst \> ready\_for\_denovo\_2\.fastq`;


        `perl \/home\/robin\/bin\/AddPairedEndSuffix\.pl ready\_for\_denovo\_1\.fastq ready\_for\_denovo\_1s\.fastq 1`;
        `perl \/home\/robin\/bin\/AddPairedEndSuffix\.pl ready\_for\_denovo\_2\.fastq ready\_for\_denovo\_2s\.fastq 2`;
        `java \-Xmx2g \-jar \/home\/robin\/bin\/picard\-tools\-1\.98\/FastqToSam\.jar FASTQ\=ready\_for\_denovo\_1s\.fastq OUTPUT\=DN1\.sam SAMPLE\_NAME\=$values[3]`;
        `java \-Xmx2g \-jar \/home\/robin\/bin\/picard\-tools\-1\.98\/FastqToSam\.jar FASTQ\=ready\_for\_denovo\_2s\.fastq OUTPUT\=DN2\.sam SAMPLE\_NAME\=$values[3]`;
        `java \-Xmx2g \-jar \/home\/robin\/bin\/picard\-tools\-1\.98\/MergeSamFiles\.jar INPUT\=DN1\.sam INPUT\=DN2\.sam OUTPUT\=DN\.sam SORT\_ORDER\=queryname USE\_THREADING\=true VALIDATION\_STRINGENCY\=SILENT`;

        `perl \/home\/robin\/bin\/UnmappedBamToFastq\.pl DN\.sam READ\_FOR\_DENOVO`;



                # $all = 'all.fastq';
        # if (-e $all) {
        #         print "All.fastq Exists!";
        # }
        # else{
        #         `bedtools bamtofastq \-i $values[0] \-fq all\.fastq`;
        # }
        `rm First\*`;
        `rm Second\*`;
        `rm ready\_for\_denovo\*`;
        `rm DN\*`;
        
        print $values[3]." is done\n";
        chdir "..";
}