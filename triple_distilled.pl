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
       
# CELERA-mapping


       # get fastq of all reads
       `bedtools bamtofastq \-i $values[0] \-fq all\.fastq`; 
      # get headers frmo the remaining unmapped reads
       `sed  \'\/\^\[\@\]$values[1]\/ s\/\\\/\[12\]\$\/\/\' 1\_\* \| grep \-o \"\@$values[1]\[\^    \]\*\" \| sort \| uniq \| sed \'s\/\^\@\/\/\' | sed  \'s\/\\\/\[12\]\$\/\/\' \> name\_unmapped\.lst`;
       # get interleaved fastq of unmapped reads
       `seqtk subseq all\.fastq name\_unmapped\.lst \> ready\_for\_celera\_mapping\.fastq`;
        # map to celera in paired-end mode
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-R \'\@RG\\\tID\:$values[3]\\tSM\:$values[3]\' \-M \-p \/data\_fedor12\/robin\/databases\/Celera\/Alt\_Rn\_Celera\.fa ready\_for\_celera\_mapping\.fastq \> Celera\.sam`;
        # get reads, that properly map in pairs
        `samtools view \-bS \-f 2 Celera\.sam \> Celera\_proper\_mapped\.bam`;
        # get headers from properly mapped readpairs
        `samtools view \-f 2  Celera\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameM\.lst`;
        #get headers from not properly mapped readpairs
        `samtools view \-F 2  Celera\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameU\.lst`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameM\.lst \> C\.fastq`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameU\.lst \> Cu\.fastq`;
        # stats of mapped readpairs
        `echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#     Celera\-mapped readpairs     \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
        `\/home\/robin\/bin\/fasta\_utilities\/ea\-utils\.\1\.\1\.2\-537\/fastq\-stats C\.fastq \>\> TripleDistilled\.log`;
        # stats of  unmapped readpairs
        `echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#     Celera\-unmapped readpairs     \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
        `\/home\/robin\/bin\/fasta\_utilities\/ea\-utils\.\1\.\1\.2\-537\/fastq\-stats Cu\.fastq \>\> TripleDistilled\.log`;
        # rename files
        `mv C\.fastq C\_$values[3]\.fastq`;
        `mv Cu\.fastq nC\_$values[3]\.fastq`;


#  Y-chromosomal mapping

      # map to celera in paired-end mode
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-R \'\@RG\\\tID\:$values[3]\\tSM\:$values[3]\' \-M \-p \/data\_fedor12\/robin\/databases\/YchrBAC\/YchrBAC\.fasta nC\_$values[3]\.fastq \> Ychr\.sam`;
        # get reads, that properly map in pairs
        `samtools view \-bS \-f 2 Ychr\.sam \> Ychr\_proper\_mapped\.bam`;
        # get headers from properly mapped readpairs
        `samtools view \-f 2  Ychr\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameM\.lst`;
        #get headers from not properly mapped readpairs
        `samtools view \-F 2  Ychr\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameU\.lst`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameM\.lst \> Y\.fastq`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameU\.lst \> Yu\.fastq`;
        # stats of mapped readpairs
        `echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#     Ychr\-mapped readpairs     \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
        `\/home\/robin\/bin\/fasta\_utilities\/ea\-utils\.\1\.\1\.2\-537\/fastq\-stats Y\.fastq \>\> TripleDistilled\.log`;
        # stats of  unmapped readpairs
        `echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#     Ychr\-unmapped readpairs     \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
        `\/home\/robin\/bin\/fasta\_utilities\/ea\-utils\.\1\.\1\.2\-537\/fastq\-stats Yu\.fastq \>\> TripleDistilled\.log`;
        # rename files
        `mv Y\.fastq Y\_$values[3]\.fastq`;
        `mv Yu\.fastq nY\_$values[3]\.fastq`;


# ViPro mapping
        # map against vipro-db
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-R \'\@RG\\\tID\:$values[3]\\tSM\:$values[3]\' \-M \-p \/data\_fedor12\/robin\/databases\/ViPro\/ProVi\.fa nV\_$values[3]\.fastq \> V\.sam`;
        # report found contamination-derived reads
        `echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#     Found organisms     \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
        `samtools view \-S V\.sam \-f 2 \| cut \-f3 \| sort \| uniq \-c \| sort \-nr \>\> TripleDistilled\.log`;
        # extract properly-mapped reads
        `samtools view \-bS \-f 2 V\.sam \> V\_proper\_mapped\.bam`;
        # get headers from properly mapped readpairs
        `samtools view \-f 2  V\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameM\.lst`;
        #get headers from not properly mapped readpairs
        `samtools view \-F 2 V\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameU\.lst`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameM\.lst \> V\.fastq`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameU\.lst \> Vu\.fastq`;
        # stats of mapped readpairs
        `echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#     ViPro\-mapped readpairs     \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
        `\/home\/robin\/bin\/fasta\_utilities\/ea\-utils\.\1\.\1\.2\-537\/fastq\-stats V\.fastq \>\> TripleDistilled\.log`;
        # stats of  unmapped readpairs
        `echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#     ViPro\-unmapped readpairs     \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
        `\/home\/robin\/bin\/fasta\_utilities\/ea\-utils\.\1\.\1\.2\-537\/fastq\-stats Vu\.fastq \>\> TripleDistilled\.log`;
        # rename files
        `mv V\.fastq V\_$values[3]\.fastq`;
        `mv Vu\.fastq nV\_$values[3]\.fastq`;
        print $values[3]." is done\n";
        chdir "..";
}