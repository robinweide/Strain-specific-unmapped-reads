#!/bin/sh
#																							 First, stats on input
# 
echo '!!!!!!!!!! Basic info !!!!!!!!!!'

INPUTFILE=`basename $1`
INPUTDIR=`dirname $1`
#cd $4
# echo 'Input file is '$INPUTFILE > report_balfour.stats
# echo '   ' >> report_balfour.stats
# echo 'Platfrom is '$3 >> report_balfour.stats
# echo '   ' >> report_balfour.stats
# echo 'Read-ID is '$2 >> report_balfour.stats
# echo '   ' >> report_balfour.stats
# echo 'Flagstat' $INPUTFILE >> report_balfour.stats
# echo '   ' >> report_balfour.stats
# samtools flagstat $1 >> report_balfour.stats
# echo '   ' >> report_balfour.stats

# echo '!!!!!!!!!! Pindel !!!!!!!!!!'

# samtools view -b -F 136 -f 68 $1 > ${INPUTFILE%%.*}_PE1_UM.bam
# samtools view -b -F 72 -f 132 $1 > ${INPUTFILE%%.*}_PE2_UM.bam
# samtools view -b -f 72 -F 132 $1 > ${INPUTFILE%%.*}_PE1_MU.bam
# samtools view -b -f 136 -F 68 $1 > ${INPUTFILE%%.*}_PE2_MU.bam

# java -Xmx2g -jar /home/robin/bin/picard-tools-1.98/MergeSamFiles.jar INPUT=${INPUTFILE%%.*}_PE1_UM.bam INPUT=${INPUTFILE%%.*}_PE2_UM.bam INPUT=${INPUTFILE%%.*}_PE1_MU.bam INPUT=${INPUTFILE%%.*}_PE2_MU.bam OUTPUT=${INPUTFILE%%.*}_split.bam SORT_ORDER=queryname USE_THREADING=true VALIDATION_STRINGENCY=SILENT

# java -Xmx2g -jar /home/robin/bin/picard-tools-1.98/SortSam.jar INPUT=${INPUTFILE%%.*}_split.bam OUTPUT=${INPUTFILE%%.*}_split_sort.bam SORT_ORDER=coordinate VALIDATION_STRINGENCY=SILENT

# java -Xmx2g -jar /home/robin/bin/picard-tools-1.98/BuildBamIndex.jar INPUT=${INPUTFILE%%.*}_split_sort.bam VALIDATION_STRINGENCY=SILENT

# mv ${INPUTFILE%%.*}_split_sort.bai ${INPUTFILE%%.*}_split_sort.bam.bai

# echo ${INPUTFILE%%.*}_split_sort.bam	200	${INPUTFILE%%.*} > ${INPUTFILE%%.*}.pindelconfig

# /home/robin/bin/pindel/pindel -f /data_fedor12/common_data/GENOMES/R_norvegicus/Rnor_5.0/reference/bwa_0.7.5a/R_norvegicus_Rnor_5.0.fasta -l false -k false -s false -i ${INPUTFILE%%.*}.pindelconfig -c ALL -o ${INPUTFILE%%.*} -L pindel.log -T 10

# cat ${INPUTFILE%%.*}_D > pindelrawoutput
# cat ${INPUTFILE%%.*}_INV >> pindelrawoutput
# cat ${INPUTFILE%%.*}_SI >> pindelrawoutput
# cat ${INPUTFILE%%.*}_TD >> pindelrawoutput
# mkdir pindel_output
# mv ${INPUTFILE%%.*}.pindelconfig ./pindel_output/${INPUTFILE%%.*}.pindelconfig
# mv ${INPUTFILE%%.*}_BP ./pindel_output/${INPUTFILE%%.*}_BP
# mv ${INPUTFILE%%.*}_CloseEndMapped ./pindel_output/${INPUTFILE%%.*}_CloseEndMapped
# mv ${INPUTFILE%%.*}_D ./pindel_output/${INPUTFILE%%.*}_D
# mv ${INPUTFILE%%.*}_INT_final ./pindel_output/${INPUTFILE%%.*}_INT_final
# mv ${INPUTFILE%%.*}_INV ./pindel_output/${INPUTFILE%%.*}_INV
# mv ${INPUTFILE%%.*}_LI ./pindel_output/${INPUTFILE%%.*}_LI
# mv ${INPUTFILE%%.*}_RP ./pindel_output/${INPUTFILE%%.*}_RP
# mv ${INPUTFILE%%.*}_SI ./pindel_output/${INPUTFILE%%.*}_SI
# mv ${INPUTFILE%%.*}_TD ./pindel_output/${INPUTFILE%%.*}_TD

# grep -o "@$2[^    ]*" pindelrawoutput | sort | uniq | sed 's/^@//' > name.lst

# samtools view -b -f 68 $1 > ${INPUTFILE%%.*}_PE1.bam
# samtools view -b -f 132 $1 > ${INPUTFILE%%.*}_PE2.bam

# bedtools bamtofastq -i ${INPUTFILE%%.*}_PE1.bam -fq ${INPUTFILE%%.*}_PE1.fastq
# bedtools bamtofastq -i ${INPUTFILE%%.*}_PE2.bam -fq ${INPUTFILE%%.*}_PE2.fastq

# perl /home/robin/bin/AddPairedEndSuffix.pl ${INPUTFILE%%.*}_PE1.fastq ${INPUTFILE%%.*}_PE1_unmapped.fastq 1
# perl /home/robin/bin/AddPairedEndSuffix.pl ${INPUTFILE%%.*}_PE2.fastq ${INPUTFILE%%.*}_PE2_unmapped.fastq 2

# grep -o "@$2[^    ]*" ${INPUTFILE%%.*}_PE1_unmapped.fastq | sort | uniq | sed 's/^@//' > allname.lst
# grep -o "@$2[^    ]*" ${INPUTFILE%%.*}_PE2_unmapped.fastq | sort | uniq | sed 's/^@//' >> allname.lst

# echo '0---   Amount of total unmapped reads:' >> report_balfour.stats
# wc -l allname.lst >> report_balfour.stats
# echo '   ' >> report_balfour.stats

# echo '0---   Amount of unmapped reads split-mapped:' >> report_balfour.stats
# wc -l name.lst >> report_balfour.stats

# grep -Fxv -f name.lst allname.lst  > pindelu.lst

# echo '0---   Amount of unmapped reads (and split-read unmapped):' >> report_balfour.stats
# wc -l pindelu.lst >> report_balfour.stats
# echo '   ' >> report_balfour.stats

# seqtk subseq ${INPUTFILE%%.*}_PE1_unmapped.fastq pindelu.lst > ${INPUTFILE%%.*}_PE1_PINDELUNMAPPED.fastq
# seqtk subseq ${INPUTFILE%%.*}_PE2_unmapped.fastq pindelu.lst > ${INPUTFILE%%.*}_PE2_PINDELUNMAPPED.fastq

# echo '0---   Unmapped non-split PE1:' >> report_balfour.stats
# /home/robin/bin/fasta_utilities/ea-utils.1.1.2-537/fastq-stats ${INPUTFILE%%.*}_PE1_PINDELUNMAPPED.fastq  >> report_balfour.stats

# echo '0---   Unmapped non-split PE2:' >> report_balfour.stats
# /home/robin/bin/fasta_utilities/ea-utils.1.1.2-537/fastq-stats ${INPUTFILE%%.*}_PE2_PINDELUNMAPPED.fastq  >> report_balfour.stats

# mv pindel.log ./pindel_output/pindel.log
# mv pindelrawoutput ./pindel_output/pindelrawoutput

# java -Xmx2g -jar /home/robin/bin/picard-tools-1.98/FastqToSam.jar FASTQ=${INPUTFILE%%.*}_PE1_PINDELUNMAPPED.fastq OUTPUT=${INPUTFILE%%.*}_pretrim1.sam SAMPLE_NAME=${INPUTFILE%%.*}
# java -Xmx2g -jar /home/robin/bin/picard-tools-1.98/FastqToSam.jar FASTQ=${INPUTFILE%%.*}_PE2_PINDELUNMAPPED.fastq OUTPUT=${INPUTFILE%%.*}_pretrim2.sam SAMPLE_NAME=${INPUTFILE%%.*}
# java -Xmx2g -jar /home/robin/bin/picard-tools-1.98/MergeSamFiles.jar INPUT=${INPUTFILE%%.*}_pretrim1.sam INPUT=${INPUTFILE%%.*}_pretrim2.sam OUTPUT=${INPUTFILE%%.*}_pretrim.sam SORT_ORDER=queryname USE_THREADING=true VALIDATION_STRINGENCY=SILENT

# perl /home/robin/bin/UnmappedBamToFastq.pl ${INPUTFILE%%.*}_pretrim.sam ${INPUTFILE%%.*}_unmapped

# echo '   ' >> report_balfour.stats
# echo 'Trimmomatic singletons' >> report_balfour.stats
# java -jar /home/robin/bin/Trimmomatic-0.30/trimmomatic-0.30.jar SE -threads 8 -phred33 ${INPUTFILE%%.*}_unmapped.fastq TRIMMED_S.fastq ILLUMINACLIP:/home/robin/bin/Trimmomatic-0.30/adapters/TruSeq$3-SE.fa:2:30:10 SLIDINGWINDOW:25:25 MINLEN:46 &>> report_balfour.stats
# echo 'Trimmomatic readpairs' >> report_balfour.stats
# java -jar /home/robin/bin/Trimmomatic-0.30/trimmomatic-0.30.jar PE -threads 8 -phred33 ${INPUTFILE%%.*}_unmapped_1.fastq ${INPUTFILE%%.*}_unmapped_2.fastq TRIMMED_PE1.fastq TRIMMED_SINGLE_PE1.fastq TRIMMED_PE2.fastq TRIMMED_SINGLE_PE2.fastq ILLUMINACLIP:/home/robin/bin/Trimmomatic-0.30/adapters/TruSeq$3-PE.fa:2:30:10 SLIDINGWINDOW:25:25 MINLEN:46 &>> report_balfour.stats
# echo '   ' >> report_balfour.stats

# cat TRIMMED_S.fastq > 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_singletons.fastq

# cat TRIMMED_SINGLE_PE1.fastq >> 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_singletons.fastq

# cat TRIMMED_SINGLE_PE2.fastq >> 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_singletons.fastq

# python /home/robin/bin/interleave/interleave_fastq.py -l TRIMMED_PE1.fastq -r TRIMMED_PE2.fastq -o 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_readpairs.fastq

# mv TRIMMED_PE1.fastq ${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_readpairs_PE1.fastq
# mv TRIMMED_PE2.fastq ${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_readpairs_PE2.fastq

# echo '0---   Unmapped non-split filtered readpairs:' >> report_balfour.stats
# /home/robin/bin/fasta_utilities/ea-utils.1.1.2-537/fastq-stats 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_readpairs.fastq  >> report_balfour.stats

# echo '0---   Unmapped non-split filtered singletons:' >> report_balfour.stats
# /home/robin/bin/fasta_utilities/ea-utils.1.1.2-537/fastq-stats 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_singletons.fastq  >> report_balfour.stats

# rm *_pretrim*
# rm TRIMMED_S.fastq
# rm *_split*
# rm TRIMMED_PE1.fastq
# rm TRIMMED_SINGLE_PE1.fastq
# rm TRIMMED_PE2.fastq
# rm TRIMMED_SINGLE_PE2.fastq
# rm ${INPUTFILE%%.*}_unmapped.fastq
# rm ${INPUTFILE%%.*}_unmapped_1.fastq
# rm ${INPUTFILE%%.*}*
# rm allname.lst
# rm -rf pindel_output 
# rm name.lst
# rm pindelu.lst


# # ===================================================================================================================================CELERA
echo '!!!!!!!!!! CELERA !!!!!!!!!!'

bedtools bamtofastq -i $1 -fq all.fastq

sed  '/^[@]'$2'/ s/\/[12]$//' 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_singletons.fastq > s_empty.fq

sed  '/^[@]'$2'/ s/\/[12]$//' 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_readpairs.fastq > r_empty.fq

cat  s_empty.fq > empty.fastq
cat  r_empty.fq >> empty.fastq
grep -o "@$2[^    ]*" empty.fastq | sort | uniq | sed 's/^@//' > name.lst

seqtk subseq all.fastq name.lst > ready_for_celera_mapping.fastq

/home/robin/bin/bwa-0.7.5a/bwa mem -R '@RG\tID:${INPUTFILE%%.*}\tSM:${INPUTFILE%%.*}' -M -p /data_fedor12/robin/databases/Celera/Alt_Rn_Celera.fa ready_for_celera_mapping.fastq > ${INPUTFILE%%.*}_Celera.sam

samtools view -bS -f 2 -F 4 ${INPUTFILE%%.*}_Celera.sam > ${INPUTFILE%%.*}_Celera_proper_mapped.bam

bedtools bamtofastq -i  ${INPUTFILE%%.*}_Celera_proper_mapped.bam -fq ${INPUTFILE%%.*}_Celera_mapped_prop.fastq

sed  '/^[@]'$2'/ s/\/[12]$//'  ${INPUTFILE%%.*}_Celera_mapped_prop.fastq >  ${INPUTFILE%%.*}_Celera_mapped_prop_nosuf.fastq


grep -o "@$2[^    ]*" ${INPUTFILE%%.*}_Celera_mapped_prop_nosuf.fastq | sort | uniq | sed 's/^@//' > nameM.lst
grep -o "@$2[^    ]*" ready_for_celera_mapping.fastq | sort | uniq | sed 's/^@//' > nameA.lst


grep -Fxv -f nameM.lst nameA.lst  > unmapped_headers.lst

seqtk subseq empty.fastq unmapped_headers.lst > Cu.fastq

seqtk subseq empty.fastq nameM.lst > C.fastq

cat Cu.fastq | paste - - - - | sort -k1,1 -t " " | tr "\t" "\n" > nC_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera.fastq
cat C.fastq | paste - - - - | sort -k1,1 -t " " | tr "\t" "\n" > C_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_Celera.fastq


echo '0---   Unmapped filtered non-split filtered non-celera:' >> report_balfour.stats
/home/robin/bin/fasta_utilities/ea-utils.1.1.2-537/fastq-stats nC_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera.fastq >> report_balfour.stats
echo '0---   ' >> report_balfour.stats
echo '0---   Unmapped filtered non-split filtered celera:' >> report_balfour.stats
/home/robin/bin/fasta_utilities/ea-utils.1.1.2-537/fastq-stats  C_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_Celera.fastq >> report_balfour.stats
echo '0---   ' >> report_balfour.stats
echo '0---   ' >> report_balfour.stats

#rm *empty*
#rm ${INPUTFILE%%.*}*
#rm *.lst
#rm C.fastq
#rm Cu.fastq
#rm ready_for_celera_mapping.fastq



#pbzip2 C_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_Celera.fastq
#rm 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_singletons.fastq
#rm 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_readpairs.fastq

# ===================================================================================================================================YYY
echo '!!!!!!!!!! Ychr !!!!!!!!!!'

#changed reference
/home/robin/bin/bwa-0.7.5a/bwa mem -R '@RG\tID:${INPUTFILE%%.*}\tSM:${INPUTFILE%%.*}' -M -p /data_fedor12/robin/databases/YchrBAC/YchrBAC.fasta nC_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera.fastq > ${INPUTFILE%%.*}_YYY.sam

samtools view -bS -f 2 -F 4 ${INPUTFILE%%.*}_YYY.sam > ${INPUTFILE%%.*}_YYY_proper_mapped.bam

bedtools bamtofastq -i  ${INPUTFILE%%.*}_YYY_proper_mapped.bam -fq ${INPUTFILE%%.*}_YYY_mapped_prop.fastq
mv ${INPUTFILE%%.*}_YYY_proper_mapped.bam mapped_to_celera.bam
sed  '/^[@]'$2'/ s/\/[12]$//'  ${INPUTFILE%%.*}_YYY_mapped_prop.fastq >  ${INPUTFILE%%.*}_YYY_mapped_prop_nosuf.fastq


grep -o "@$2[^    ]*" ${INPUTFILE%%.*}_YYY_mapped_prop_nosuf.fastq | sort | uniq | sed 's/^@//' > nameM.lst
grep -o "@$2[^    ]*" nC_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera.fastq | sort | uniq | sed 's/^@//' > nameA.lst


grep -Fxv -f nameM.lst nameA.lst  > unmapped_headers.lst

seqtk subseq nC_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera.fastq unmapped_headers.lst > Cu.fastq

seqtk subseq nC_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera.fastq nameM.lst > C.fastq

cat Cu.fastq | paste - - - - | sort -k1,1 -t " " | tr "\t" "\n" > nY_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY.fastq
cat C.fastq | paste - - - - | sort -k1,1 -t " " | tr "\t" "\n" > Y_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_Y.fastq


echo '0---   Unmapped filtered non-split filtered non-celera non-Y:' >> report_balfour.stats
/home/robin/bin/fasta_utilities/ea-utils.1.1.2-537/fastq-stats nY_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY.fastq >> report_balfour.stats
echo '0---   ' >> report_balfour.stats
echo '0---   Unmapped filtered non-split filtered non-celera Y:' >> report_balfour.stats
/home/robin/bin/fasta_utilities/ea-utils.1.1.2-537/fastq-stats  Y_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_Y.fastq >> report_balfour.stats
echo '0---   ' >> report_balfour.stats
echo '0---   ' >> report_balfour.stats

#rm *empty*
#rm ${INPUTFILE%%.*}*
#rm *.lst
#rm C.fastq
#rm Cu.fastq


#pbzip2 Y_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_Y.fastq
#pbzip2 nC_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera.fastq
# ===================================================================================================================================VVV
echo '!!!!!!!!!! Vipro !!!!!!!!!!'
#changed reference
/home/robin/bin/bwa-0.7.5a/bwa mem -R '@RG\tID:${INPUTFILE%%.*}\tSM:${INPUTFILE%%.*}' -M -p /data_fedor12/robin/databases/ViPro/ProVi.fa nY_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY.fastq > viral.sam

echo '0---   VIPRO  (>3900 reads or more) --------0' >> report_balfour.stats
samtools view -S viral.sam -f 2 -F 4 | cut -f3 | sort | uniq -c | sort -nr >> report_balfour.stats
#read -p "Vipro treshold? ( Check report )" VIPROTRES
echo 'ViPro treshold is 20' >> report_balfour.stats

samtools view -S viral.sam -f 2 -F 4 | cut -f3 | sort | uniq -c | awk '{if ($1 > 20) print $2}' > found_organisms
if [ "$(wc -c <found_organisms)" -eq 0 ];then
	echo "No found found_organisms. Use the _APE.fastq-files" 1>&2 
	exit
fi

samtools view -bS -f 2 -F 4 viral.sam > viral.bam
samtools sort viral.bam viral_sorted
samtools index viral_sorted.bam


##################################################################
perl /home/robin/bin/looper.pl
##################################################################

#without @ and suffix
sort viral_mapped_readnames.lst | uniq | sed  '/^'$2'/ s/\/[1]$//' | sed  '/^'$2'/ s/\/[2]$//' | sed 's/^@//' > nameM.lst
grep -o "@$2[^    ]*" nY_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY.fastq | sort | uniq | sed 's/^@//' > nameA.lst



grep -Fxv -f nameM.lst nameA.lst  > unmapped_headers.lst

seqtk subseq nY_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY.fastq unmapped_headers.lst > Cu.fastq

seqtk subseq nY_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY.fastq nameM.lst > C.fastq

cat Cu.fastq | paste - - - - | sort -k1,1 -t " " | tr "\t" "\n" > nV_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY_nonV.fastq
cat C.fastq | paste - - - - | sort -k1,1 -t " " | tr "\t" "\n" > V_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY_V.fastq


echo '0---   Unmapped filtered non-split filtered non-celera non-Y non-V:' >> report_balfour.stats
/home/robin/bin/fasta_utilities/ea-utils.1.1.2-537/fastq-stats nV_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY_nonV.fastq >> report_balfour.stats
echo '0---   ' >> report_balfour.stats
echo '0---   Unmapped filtered non-split filtered non-celera non-Y V:' >> report_balfour.stats
/home/robin/bin/fasta_utilities/ea-utils.1.1.2-537/fastq-stats  V_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY_V.fastq >> report_balfour.stats
echo '0---   ' >> report_balfour.stats
echo '0---   ' >> report_balfour.stats


#rm ${INPUTFILE%%.*}*
#rm *.lst
#rm C.fastq
#rm Cu.fastq












#pbzip2 Y_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_Y.fastq
#pbzip2 nC_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera.fastq
#cd ..
