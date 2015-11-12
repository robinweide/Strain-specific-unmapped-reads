#!/usr/bin/perl

# input: sample_name	fq1		fq2	InsertSize

echo 1.fastq > reads.lst
echo 2.fastq >> reads.lst

/bin/SOAPec_v2.01/bin/KmerFreq_HA -t 10 -p $values[0] -l reads.lst >SOAPECkmerfreq.log 2>SOAPECkmerfreq.err
/bin/SOAPec_v2.01/bin/Corrector_HA -t 10 -j 0 -o 3 -q 30 $values[0].freq.gz reads.lst >SOAPECcorr.log
# perl /bin/AddPairedEndSuffix.pl S.cor.fq S_1.cor.fq 1
java -Xmx2g -jar /bin/picard/picard-tools-1.109/FastqToSam.jar FASTQ=1.fastq.cor.fq OUTPUT=1.fastq.sam SAMPLE_NAME=$values[0]
java -Xmx2g -jar /bin/picard/picard-tools-1.109/FastqToSam.jar FASTQ=2.fastq.cor.fq OUTPUT=2.fastq.sam SAMPLE_NAME=$values[0]
java -Xmx2g -jar /bin/picard/picard-tools-1.109/MergeSamFiles.jar INPUT=1.fastq.sam INPUT=2.fastq.sam  OUTPUT=$values[0]_MERGED.sam SORT_ORDER=queryname
perl /bin/UnmappedBamToFastq.pl $values[0]_MERGED.sam $values[0]_Unmapped

mv $values[0]_Unmapped.fastq $values[0]_unmapped_singletons_corrected.fastq
mv $values[0]_Unmapped_1.fastq $values[0]_unmapped_PE1_corrected.fastq
mv $values[0]_Unmapped_2.fastq $values[0]_unmapped_PE2_corrected.fastq

echo max_rd_len=100 > $values[0].config
echo [LIB] >> $values[0].config
echo avg_ins=$values[2] >> $values[0].config
echo reverse_seq=0 >> $values[0].config
echo asm_flags=3 >> $values[0].config
echo rd_len_cutoff=100 >> $values[0].config
echo pair_num_cutoff=3 >> $values[0].config
echo map_len=32 >> $values[0].config
echo q1=$values[0]_unmapped_PE1_corrected.fastq >> $values[0].config
echo q2=$values[0]_unmapped_PE2_corrected.fastq >> $values[0].config

cat $values[0]_unmapped_PE1_corrected.fastq > kmergenie.fq
cat $values[0]_unmapped_PE2_corrected.fastq >> kmergenie.fq
cat $values[0]_unmapped_singletons_corrected.fastq >> kmergenie.fq

/bin/kmergenie-1.6476/kmergenie kmergenie.fq &> kmerlog

/bin/SOAPdenovo2-bin-LINUX-generic-r240/SOAPdenovo-63mer all -s $values[0].config -o $values[0] -p 10 -V -K "$(grep 'best k:' kmerlog | tail -n 1 | awk '{print $3}')"
/bin/GapCloser/GapCloser -b $values[0].config -a $values[0].scafSeq -o $values[0]_gapcloser -t 10

python /bin/quast-2.3/quast.py $values[0]_gapcloser -T 10 -o quast_scaffold
