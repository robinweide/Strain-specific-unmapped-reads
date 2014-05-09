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
    if (-e "all\.fastq") {
        print "File all\.fastq exists.\n";
    }
    else{

       `bedtools bamtofastq \-i $values[0] \-fq alll\.fastq`; 
       `sed  \'\/\^\@$values[1]\/ s\/\[\:\/\]\[12\]\$\/\/\' alll\.fastq \> all\.fastq`; 
       `rm alll\.fastq`; 

    }       
      # get headers frmo the remaining unmapped reads
    if (-e "name\_unmapped\.lst") {
        print "File name\_unmapped\.lst exists.\n";
    }
    else{
       `sed  \'\/\^\@$values[1]\/ s\/\[\:\/\]\[12\]\$\/\/\' \/data\_fedor12\/robin\/Q\_C\_Y\_C\/$values[3]\/1\_\* \| grep \-o \"\@$values[1]\[\^\ \  \]\*\" \| sort \| uniq \| sed \'s\/\^\@\/\/\' \| sed \'s\/\[\:\/\]\[12\]\$\/\/\' \> name\_unmapped\.lst`;
    }  
       # get interleaved fastq of unmapped reads
    if (-e "ready\_for\_celera\_mapping\.fastq") {
        print "File ready\_for\_celera\_mapping\.fastq exists.\n";
    }
    else{
        `seqtk subseq all\.fastq name\_unmapped\.lst \> ready\_for\_celera\_mapping\.fastq`;
    }  
      
      
        # map to celera in paired-end mode
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-R \"\@RG\\\tID\:celera\\tSM\:celera\" \-M \-p \/data\_fedor12\/robin\/databases\/Celera\/Alt\_Rn\_Celera\.fa ready\_for\_celera\_mapping\.fastq \> Celera\.sam`;
        # get reads, that properly map in pairs
        `samtools view \-bS \-f 2 Celera\.sam \> Celera\_proper\_mapped\.bam`;
        # get headers from properly mapped readpairs
        `samtools view \-f 2  Celera\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameMc\.lst`;
        #get headers from not properly mapped readpairs
        `samtools view \-F 2  Celera\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameUc\.lst`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameMc\.lst \> C\.fastq`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameUc\.lst \> Cu\.fastq`;
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
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-R \"\@RG\\\tID\:ychr\\tSM\:ychr\" \-M \-p \/data\_fedor12\/robin\/databases\/YchrBAC\/YchrBAC\.fasta nC\_$values[3]\.fastq \> Ychr\.sam`;
        # get reads, that properly map in pairs
        `samtools view \-bS \-f 2 Ychr\.sam \> Ychr\_proper\_mapped\.bam`;
        # get headers from properly mapped readpairs
        `samtools view \-f 2  Ychr\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameMy\.lst`;
        #get headers from not properly mapped readpairs
        `samtools view \-F 2  Ychr\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameUy\.lst`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameMy\.lst \> Y\.fastq`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameUy\.lst \> Yu\.fastq`;
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
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-R \"\@RG\\\tID\:vipro\\tSM\:vipro\" \-M \-p \/data\_fedor12\/robin\/databases\/ViPro\/ProVi\.fa nV\_$values[3]\.fastq \> V\.sam`;
        # report found contamination-derived reads
        `echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#     Found organisms     \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
        `samtools view \-S V\.sam \-f 2 \| cut \-f3 \| sort \| uniq \-c \| sort \-nr \>\> TripleDistilled\.log`;
        # extract properly-mapped reads
        `samtools view \-bS \-f 2 V\.sam \> V\_proper\_mapped\.bam`;
        # get headers from properly mapped readpairs
        `samtools view \-f 2  V\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameMv\.lst`;
        #get headers from not properly mapped readpairs
        `samtools view \-F 2 V\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameUv\.lst`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameMv\.lst \> V\.fastq`;
        #get fastq of properly mapped readpairs
        `seqtk subseq all\.fastq nameUv\.lst \> Vu\.fastq`;
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