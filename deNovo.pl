#!/usr/bin/perl
use strict;
use File::Basename;
# print("#sample_name	PE1		PE2		Singleton	InsertSize");
open(INFILE, "$ARGV[0]");

my @QUERY = <INFILE>;
close INFILE;

my $start_run = time();

foreach my $QUERY (@QUERY){
        chomp $QUERY;
        my $Qname = basename($QUERY);
        my @values = split(/\t/,$QUERY);
        chomp $values[0];
        print $values[0]." has begun!\n";
        #print "cd ".$values[3]."\n";
        `mkdir $values[0]`;
        chdir($values[0]);

`cat $values[1] \| paste \- \- \- \- \- \- \- \-  \| tee \>\(cut \-f 1\-4 \| tr \"\\t\" \"\\n\" \> 1.fastq\) \| cut \-f 5\-8 \| tr \"\\t\" \"\\n\" \> 2.fastq`;


`echo 1\.fastq \> reads\.lst`;
`echo 2\.fastq \>\> reads\.lst`;

`\/home\/robin\/bin\/SOAPec\_v2\.01\/bin\/KmerFreq\_HA \-t 10 \-p $values[0] \-l reads\.lst \>SOAPECkmerfreq\.log 2\>SOAPECkmerfreq\.err`;
`\/home\/robin\/bin\/SOAPec\_v2\.01\/bin\/Corrector\_HA \-t 10 \-j 0 \-o 3 \-q 30 $values[0]\.freq\.gz reads\.lst \>SOAPECcorr\.log`;
# `perl \/home\/robin\/bin\/AddPairedEndSuffix\.pl S\.cor\.fq S\_1\.cor\.fq 1`;
`java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/FastqToSam\.jar FASTQ\=1\.fastq\.cor\.fq OUTPUT\=1\.fastq\.sam SAMPLE\_NAME\=$values[0]`;
`java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/FastqToSam\.jar FASTQ\=2\.fastq\.cor\.fq OUTPUT\=2\.fastq\.sam SAMPLE\_NAME\=$values[0]`;
# `java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/FastqToSam\.jar FASTQ\=S\_1\.cor\.fq OUTPUT\=$values[3]\.sam SAMPLE\_NAME\=$values[0]`;
`java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/MergeSamFiles\.jar INPUT\=1\.fastq\.sam INPUT\=2\.fastq\.sam  OUTPUT\=$values[0]\_MERGED\.sam SORT\_ORDER\=queryname`;
`perl \/home\/robin\/bin\/UnmappedBamToFastq\.pl $values[0]\_MERGED\.sam $values[0]\_Unmapped`;
`mv $values[0]\_Unmapped\.fastq $values[0]\_unmapped\_singletons\_corrected\.fastq`;
`mv $values[0]\_Unmapped\_1\.fastq $values[0]\_unmapped\_PE1\_corrected\.fastq`;
`mv $values[0]\_Unmapped\_2\.fastq $values[0]\_unmapped\_PE2\_corrected\.fastq`;

`echo max\_rd\_len\=100 \> $values[0]\.config`;
`echo [LIB] \>\> $values[0]\.config`;
`echo avg\_ins\=$values[2] \>\> $values[0]\.config`;
`echo reverse\_seq\=0 \>\> $values[0]\.config`;
`echo asm\_flags\=3 \>\> $values[0]\.config`;
`echo rd\_len\_cutoff\=100 \>\> $values[0]\.config`;
`echo pair\_num\_cutoff\=3 \>\> $values[0]\.config`;
`echo map\_len\=32 \>\> $values[0]\.config`;
`echo q1\=$values[0]\_unmapped\_PE1\_corrected\.fastq \>\> $values[0]\.config`;
`echo q2\=$values[0]\_unmapped\_PE2\_corrected\.fastq \>\> $values[0]\.config`;
# `echo q\=$values[0]\_unmapped\_singletons\_corrected\.fastq \>\> $values[0]\.config`;


`cat $values[0]\_unmapped\_PE1\_corrected\.fastq \> kmergenie\.fq`;
`cat $values[0]\_unmapped\_PE2\_corrected\.fastq \>\> kmergenie\.fq`;
`cat $values[0]\_unmapped\_singletons\_corrected\.fastq \>\> kmergenie\.fq`;

`\/home\/robin\/bin\/kmergenie\-1\.6476\/kmergenie kmergenie\.fq \&\> kmerlog`;

`\/home\/robin\/bin\/SOAPdenovo2\-bin\-LINUX\-generic\-r240\/SOAPdenovo\-63mer all \-s $values[0]\.config \-o $values[0] \-p 10 \-V \-K \"\$\(grep \'best k\:\' kmerlog \| tail \-n 1 \| awk \'\{print \$3\}\'\)\"`;
`\/home\/robin\/bin\/GapCloser\/GapCloser \-b $values[0]\.config \-a $values[0]\.scafSeq \-o $values[0]\_gapcloser \-t 10`;

`python \/home\/robin\/bin\/quast\-2\.3\/quast\.py $values[0]\_gapcloser \-T 10 \-o quast\_scaffold`;

        print $values[0]." is done\n";
        chdir "..";
    }

    my $end_run = time();
my $run_time = $end_run - $start_run;
print "Job took $run_time seconds\n";