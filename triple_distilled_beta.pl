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
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-M \-p \/data\_fedor12\/robin\/databases\/Celera\/Alt\_Rn\_Celera\.fa ready\_for\_celera\_mapping\.fastq \> Celera\.sam`;
        # get reads, that properly map in pairs
        `samtools view \-bS \-f 2 Celera\.sam \> Celera\_proper\_mapped\.bam`;

 		# map to celera in paired-end mode
 		`\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-M \-p \/data\_fedor12\/robin\/databases\/YchrBAC\/YchrBAC\.fasta ready\_for\_celera\_mapping\.fastq \> Ychr\.sam`;
        # get reads, that properly map in pairs
        `samtools view \-bS \-f 2 Ychr\.sam \> Ychr\_proper\_mapped\.bam`;

		# map against vipro-db
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-M \-p \/data\_fedor12\/robin\/databases\/ViPro\/ProVi\.fa ready\_for\_celera\_mapping\.fastq \> V\.sam`;
        # extract properly-mapped reads
        `samtools view \-bS \-f 2 V\.sam \> V\_proper\_mapped\.bam`;


        # get headers from properly mapped readpairs
        `samtools view \-f 2  V\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameMv\.lst`;
        # get headers from properly mapped readpairs
        `samtools view \-f 2  Ychr\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameMy\.lst`;
        # get headers from properly mapped readpairs
        `samtools view \-f 2  Celera\_proper\_mapped\.bam \| awk \'\{print \$1\}\' \| sort \| uniq \> nameMc\.lst`;

        # find read-ids in both V & Y, not in C
		`grep \-Fx \-f nameMv\.lst nameMy\.lst \| sort \| uniq \> VY\.lst`;
		`grep \-Fxv \-f nameMc\.lst VY\.lst  \| sort \| uniq  \> VY\-nC\.lst`;
        # find read-ids in both V & C, not in Y
		`grep \-Fx \-f nameMv\.lst nameMc\.lst  \| sort \| uniq \> VC\.lst`;
		`grep \-Fxv \-f nameMy\.lst VC\.lst   \| sort \| uniq \> VC\-nY\.lst`;
        # find read-ids in both C & Y, not in V
        `grep \-Fx \-f nameMy\.lst nameMc\.lst  \| sort \| uniq \> YC\.lst`;
		`grep \-Fxv \-f nameMv\.lst YC\.lst  \| sort \| uniq  \> YC\-nV\.lst`;
        # find read-ids in all three
		`grep \-Fx \-f nameMv\.lst YC\.lst  \| sort \| uniq  \> YCV\.lst`;
		# find reads in none of the three
		`grep \-Fxv \-f nameMv\.lst name\_unmapped\.lst  \| sort \| uniq  \> no\.lst`;
		`grep \-Fxv \-f nameMc\.lst no\.lst  \| sort \| uniq  \> nono\.lst`;
		`grep \-Fxv \-f nameMy\.lst nono\.lst  \| sort \| uniq  \> nonono\.lst`;

		`echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#	ViPro\-mapped readpairs		\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \> TripleDistilled\.log`;
		`wc \-l nameMv\.lst \>> TripleDistilled\.log`;
		`echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#	Ychr\-mapped readpairs		\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
		`wc \-l nameMy\.lst \>\> TripleDistilled\.log`;
		`echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#	Celera\-mapped readpairs	\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
		`wc \-l nameMc\.lst \>\> TripleDistilled\.log`;
		`echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#	VY\-mapped readpairs		\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
		`wc \-l VY\-nC\.lst \>\> TripleDistilled\.log`;
		`echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#	CY\-mapped readpairs		\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
		`wc \-l YC\-nV\.lst \>\> TripleDistilled\.log`;
		`echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#	CV\-mapped readpairs		\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
		`wc \-l VC\-nY\.lst \>\> TripleDistilled\.log`;
		`echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#	CVY\-mapped readpairs		\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
		`wc \-l YCV\.lst \>\> TripleDistilled\.log`;
		`echo \'\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#	none-\-mapped readpairs		\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\' \>\> TripleDistilled\.log`;
		`wc \-l nonono\.lst \>\> TripleDistilled\.log`;


        #get fastq of remaining reads
        `seqtk subseq all\.fastq nonono\.lst \> NoNoNo\.fastq`;
        

        `rm VY\.lst`;
        `rm VC\.lst`;
        `rm YC\.lst`;
        `rm no\.lst`;
        `rm nono\.lst`;
        `rm \*.sam`;
        `rm \*.bam`;
        print $values[3]." is done\n";
        chdir "..";
}