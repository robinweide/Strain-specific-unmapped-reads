#read -p "samplename PE1.fq PE2.fq singletons.fq"
#read -p "First deinterleave the readpairs"
#read -p "cat $2 | paste - - - - - - - -  | tee >(cut -f 1-4 | tr "\t" "\n" > PE1.fastq) | cut -f 5-8 | tr "\t" "\n" > PE2.fastq
cd $1
echo $4 > reads.lst
echo $2 >> reads.lst
echo $3 >> reads.lst

/home/robin/bin/SOAPec_v2.01/bin/KmerFreq_HA -t 10 -p $1 -l reads.lst >SOAPECkmerfreq.log 2>SOAPECkmerfreq.err
/home/robin/bin/SOAPec_v2.01/bin/Corrector_HA -t 10 -j 0 -o 3 -q 30 $1.freq.gz reads.lst >SOAPECcorr.log
perl /home/robin/bin/AddPairedEndSuffix.pl $4.cor.fq $4_1.cor.fq 1
java -Xmx2g -jar /home/robin/bin/picard-tools-1.98/FastqToSam.jar FASTQ=$2.cor.fq OUTPUT=$2.sam SAMPLE_NAME=$1
java -Xmx2g -jar /home/robin/bin/picard-tools-1.98/FastqToSam.jar FASTQ=$3.cor.fq OUTPUT=$3.sam SAMPLE_NAME=$1
java -Xmx2g -jar /home/robin/bin/picard-tools-1.98/FastqToSam.jar FASTQ=$4_1.cor.fq OUTPUT=$4.sam SAMPLE_NAME=$1
java -Xmx2g -jar /home/robin/bin/picard-tools-1.98/MergeSamFiles.jar INPUT=$2.sam INPUT=$3.sam INPUT=$4.sam OUTPUT=$1_MERGED.sam SORT_ORDER=queryname
perl /home/robin/bin/UnmappedBamToFastq.pl $1_MERGED.sam $1_Unmapped
#cat $4.cor.fq >> $1_Unmapped.fastq
mv $1_Unmapped.fastq $1_unmapped_singletons_corrected.fastq
mv $1_Unmapped_1.fastq $1_unmapped_PE1_corrected.fastq
mv $1_Unmapped_2.fastq $1_unmapped_PE2_corrected.fastq

echo max_rd_len=100 > $1.config
echo [LIB] >> $1.config
echo avg_ins=206 >> $1.config
echo reverse_seq=0 >> $1.config
echo asm_flags=3 >> $1.config
echo rd_len_cutoff=100 >> $1.config
echo pair_num_cutoff=3 >> $1.config
echo map_len=32 >> $1.config
echo q1=$1_unmapped_PE1_corrected.fastq >> $1.config
echo q2=$1_unmapped_PE2_corrected.fastq >> $1.config
echo q=$1_unmapped_singletons_corrected.fastq >> $1.config


cat $1_unmapped_PE1_corrected.fastq > kmergenie.fq
cat $1_unmapped_PE2_corrected.fastq >> kmergenie.fq
cat $1_unmapped_singletons_corrected.fastq >> kmergenie.fq

/home/robin/bin/kmergenie-1.5854/kmergenie kmergenie.fq &> kmerlog

/home/robin/bin/SOAPdenovo2-src-r240/SOAPdenovo-63mer all -s $1.config -o $1 -p 10 -V -K "$(grep 'best k:' kmerlog | awk '{print $3}')"
/home/robin/bin/GapCloser -b $1.config -a $1.scafSeq -o $1_gapcloser -t 10
# python /home/robin/bin/quast-2.2/quast.py $1.contig -T 10 -o quast_contig
python /home/robin/bin/quast-2.2/quast.py $1_gapcloser -T 10 -o quast_scaffold
# rm $1*
rm histograms*
# rm SOAPEC*
rm kmergenie.fq 
rm reads.lst*
cd ..