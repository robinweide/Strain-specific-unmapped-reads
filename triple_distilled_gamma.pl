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
    # if (-e "all\.fastq") {
    #     print "File all\.fastq exists.\n";
    # }
    # else{

    #    `bedtools bamtofastq \-i $values[0] \-fq alll\.fastq`; 
    #    `sed  \'\/\^\@$values[1]\/ s\/\[\:\/\]\[12\]\$\/\/\' alll\.fastq \> all\.fastq`; 
    #    `rm alll\.fastq`; 

    # }     
# if (-e $values[3]) {
#             `bunzip2 \/data\_fedor12\/robin\/Q\_C\_Y\_C\/$values[3]\/1\_\*bz2`;

#     }
#     else{
#         print "Unzip is not needed.\n";
# }
`cp $values[4] rp\.fastq\.bz2`;
`cp $values[5] st\.fastq\.bz2`;
`bunzip2 rp\.fastq\.bz2`;
`bunzip2 st\.fastq\.bz2`;
`cat rp\.fastq \> begin\.fastq`;
`cat st\.fastq \>\> begin\.fastq`;

  if (-e "first.fastq") {
        print "fwd-fastq exists.\n";
    }
    else{
    `samtools view \-f 64 $values[0] \-b \> first\.bam`;
    `bedtools bamtofastq \-i first\.bam \-fq first\_\.fastq`;
    `sed  \'\/\^\@$values[1]\/ s\/\[\:\/\]\[12\]\$\/\/\' first\_\.fastq \> first\.fastq`;
    `rm first\_\.fastq`;

}

    if (-e "second.fastq") {
        print "rev-fastq exists.\n";
    }
    else{
    `samtools view \-f 128 $values[0] \-b \> second\.bam`;
    `bedtools bamtofastq \-i second\.bam \-fq second\_\.fastq`;
    `sed  \'\/\^\@$values[1]\/ s\/\[\:\/\]\[12\]\$\/\/\' second\_\.fastq \> second\.fastq`;
    `rm second\_\.fastq`;
    }


      # get headers from the remaining unmapped reads
    if (-e "name\_unmapped\.lst") {
        print "File name\_unmapped\.lst exists.\n";
    }
    else{
       `sed  \'\/\^\@$values[1]\/ s\/\[\:\/\]\[12\]\$\/\/\' begin\.fastq \| grep \-o \"\@$values[1]\[\^\ \  \]\*\" \| sort \| uniq \| sed \'s\/\^\@\/\/\' \| sed \'s\/\[\:\/\]\[12\]\$\/\/\' \| sort \| uniq \> name\_unmapped\.lst`;
    }  
       # get fastqs of unmapped reads
    if (-e "ready\_for\_celera\_mapping2\.fastq") {
        print "File ready\_for\_celera\_mapping\.fastqs exists.\n";
    }
    else{
        `seqtk subseq first\.fastq name\_unmapped\.lst \> ready\_for\_celera\_mapping1\.fastq`;
		`seqtk subseq second\.fastq name\_unmapped\.lst \> ready\_for\_celera\_mapping2\.fastq`;
    }  

    `perl \/home\/robin\/bin\/AddPairedEndSuffix\.pl ready\_for\_celera\_mapping1\.fastq ready\_for\_celera\_mapping1_\.fastq 1`;
    `perl \/home\/robin\/bin\/AddPairedEndSuffix\.pl  ready\_for\_celera\_mapping2\.fastq ready\_for\_celera\_mapping2_\.fastq 2`;
	`java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/FastqToSam\.jar FASTQ\=ready\_for\_celera\_mapping1_\.fastq OUTPUT\=ready\_for\_celera\_mapping1\.sam SAMPLE\_NAME\=$values[3]`;
	`java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/FastqToSam\.jar FASTQ\=ready\_for\_celera\_mapping2_\.fastq OUTPUT\=ready\_for\_celera\_mapping2\.sam SAMPLE\_NAME\=$values[3]`;
	`java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/MergeSamFiles\.jar INPUT\=ready\_for\_celera\_mapping1\.sam INPUT\=ready\_for\_celera\_mapping2\.sam  OUTPUT\=MERGED\.sam SORT\_ORDER\=queryname`;
	`perl \/home\/robin\/bin\/UnmappedBamToFastq\.pl MERGED\.sam $values[3]\_Unmapped`;
	`python /home/robin/bin/InterleaveFastq.py -l $values[3]\_Unmapped_1.fastq -r $values[3]\_Unmapped_2.fastq -o RP.fastq`;
	`mv $values[3]\_Unmapped.fastq ST.fastq`;
        
        # map to celera in paired-end mode
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-M \-p \/data\_fedor12\/robin\/databases\/Celera\/Alt\_Rn\_Celera\.fa RP.fastq \> CeleraR\.sam`;
        # get reads, that properly map in pairs
        `samtools view \-bS \-f 2 CeleraR\.sam \> Celera\_proper\_mappedR\.bam`;

 		# map to celera in paired-end mode
 		`\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-M \-p \/data\_fedor12\/robin\/databases\/YchrBAC\/YchrBAC\.fasta RP.fastq \> YchrR\.sam`;
        # get reads, that properly map in pairs
        `samtools view \-bS \-f 2 YchrR\.sam \> Ychr\_proper\_mappedR\.bam`;

		# map against vipro-db
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-M \-p \/data\_fedor12\/robin\/databases\/ViPro\/ProVi\.fa RP.fastq \> VR\.sam`;
        # extract properly-mapped reads
        `samtools view \-bS \-f 2 VR\.sam \> V\_proper\_mappedR\.bam`;


# ######################################################################

        # map to celera in paired-end mode
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-M \-p \/data\_fedor12\/robin\/databases\/Celera\/Alt\_Rn\_Celera\.fa ST.fastq \> CeleraR\.sam`;
        # get reads, that properly map in pairs
        `samtools view \-bS \-f 2 CeleraR\.sam \> Celera\_proper\_mappedS\.bam`;

 		# map to celera in paired-end mode
 		`\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-M \-p \/data\_fedor12\/robin\/databases\/YchrBAC\/YchrBAC\.fasta ST.fastq \> YchrR\.sam`;
        # get reads, that properly map in pairs
        `samtools view \-bS \-f 2 YchrR\.sam \> Ychr\_proper\_mappedS\.bam`;

		# map against vipro-db
        `\/home\/robin\/bin\/bwa\-0\.7\.5a\/bwa mem \-M \-p \/data\_fedor12\/robin\/databases\/ViPro\/ProVi\.fa ST.fastq \> VR\.sam`;
        # extract properly-mapped reads
        `samtools view \-bS \-f 2 VR\.sam \> V\_proper\_mappedS\.bam`;


	`java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/MergeSamFiles\.jar INPUT\=Celera\_proper\_mappedR\.bam INPUT\=Celera\_proper\_mappedS\.bam OUTPUT\=Celera\_proper\_mapped\.bam SORT\_ORDER\=queryname`;
	`java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/MergeSamFiles\.jar INPUT\=Ychr\_proper\_mappedS\.bam INPUT\=Ychr\_proper\_mappedR\.bam  OUTPUT\=Ychr\_proper\_mapped\.bam SORT\_ORDER\=queryname`;
	`java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/MergeSamFiles\.jar INPUT\=V\_proper\_mappedS\.bam INPUT\=V\_proper\_mappedR\.bam  OUTPUT\=V\_proper\_mapped\.bam SORT\_ORDER\=queryname`;



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
        `seqtk subseq ready\_for\_celera\_mapping1\.fastq nonono\.lst \> NoNoNo1\.fastq`;
		`seqtk subseq ready\_for\_celera\_mapping2\.fastq nonono\.lst \> NoNoNo2\.fastq`;
         `perl \/home\/robin\/bin\/AddPairedEndSuffix\.pl NoNoNo1\.fastq NoNoNo1suf\.fastq 1`;
         `perl \/home\/robin\/bin\/AddPairedEndSuffix\.pl NoNoNo2\.fastq NoNoNo2suf\.fastq 2`;

    `java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/FastqToSam\.jar FASTQ\=NoNoNo1suf\.fastq OUTPUT\=NoNoNo1suf\.sam SAMPLE\_NAME\=$values[3]`;
    `java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/FastqToSam\.jar FASTQ\=NoNoNo2suf\.fastq OUTPUT\=NoNoNo2suf\.sam SAMPLE\_NAME\=$values[3]`;
    `java \-Xmx2g \-jar \/data\_fedor12\/common\_scripts\/picard\/picard\-tools\-1\.109\/MergeSamFiles\.jar INPUT\=NoNoNo1suf\.sam INPUT\=NoNoNo2suf\.sam  OUTPUT\=MERGEDno\.sam SORT\_ORDER\=queryname`;
    `perl \/home\/robin\/bin\/UnmappedBamToFastq\.pl MERGEDno\.sam $values[3]\_TripleDistilled`;
    `python /home/robin/bin/InterleaveFastq.py -l $values[3]\_TripleDistilled\_1\.fastq -r $values[3]\_TripleDistilled\_2\.fastq -o READY\_FOR\_DENOVO\_RP\.fastq`;
    `mv $values[3]\_TripleDistilled\.fastq READY\_FOR\_DENOVO\_ST\.fastq`;



        `rm VY\.lst`;
        `rm VC\.lst`;
        `rm YC\.lst`;
        `rm no\.lst`;
        `rm \*ono\*`;
        `rm \*TripleDistilled\_\*\.fastq`;
        `rm first\*`;
        `rm second\*`;
                `rm *oNo\*`;
        `rm \*.sam`;
        `rm \*.bam`;
        `rm name_unmapped.lst`;
        `rm ready\*`;
        `rm RP\.fastq`;
        `rm ST\.fastq`;
        print $values[3]." is done\n";
        chdir "..";
}