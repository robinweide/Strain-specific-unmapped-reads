#!/bin/sh

#input: original .bam file (used for the unmapped-reads extraction) \t read-prefix \t truseq-kit (2 or 3) \t sample-name

INPUTFILE=`basename $1`
INPUTDIR=`dirname $1`

#uncomment following line for perl-style loops
cd $4
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
mv ${INPUTFILE%%.*}_Celera_proper_mapped.bam properly_mapped_to_celera.bam
# ===================================================================================================================================YYY
echo '!!!!!!!!!! Ychr !!!!!!!!!!'
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
# ===================================================================================================================================VVV
echo '!!!!!!!!!! Vipro !!!!!!!!!!'
/home/robin/bin/bwa-0.7.5a/bwa mem -R '@RG\tID:${INPUTFILE%%.*}\tSM:${INPUTFILE%%.*}' -M -p /data_fedor12/robin/databases/ViPro/ProVi.fa nY_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY.fastq > viral.sam
echo '0---   VIPRO  (>3900 reads or more) --------0' >> report_balfour.stats
samtools view -S viral.sam -f 2 -F 4 | cut -f3 | sort | uniq -c | sort -nr >> report_balfour.stats
#read -p "Vipro treshold? ( Check report )" VIPROTRES
echo 'ViPro treshold is 0 mapped pairs' >> report_balfour.stats
samtools view -S viral.sam -f 2 -F 4 | cut -f3 | sort | uniq -c | awk '{if ($1 > 0) print $2}' > found_organisms
if [ "$(wc -c <found_organisms)" -eq 0 ];then
	echo "No found found_organisms. Use the _APE.fastq-files" 1>&2 
	cp nY_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY.fastq nV_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY_nonV.fastq
	exit
fi
samtools view -bS -f 2 -F 4 viral.sam > viral.bam
samtools sort viral.bam viral_sorted
samtools index viral_sorted.bam

#used for per-microbe looping: old way
##################################################################
# perl /home/robin/bin/looper.pl
##################################################################


#new way to check out


filename='found_organisms'
filelines=`cat $filename`
echo Start
for line in $filelines ; do
    samtools view -h viral_sorted.bam $line > temp.sam
    samtools view -S -f 66 -F 4 temp.sam | awk '{print $1}' | sed 's/\$/\/1/' >> viral_mapped_readnames.lst
    samtools view -S -f 130 -F 4 temp.sam | awk '{print $1}' | sed 's/\$/\/2/' >> viral_mapped_readnames.lst
done



###################################################

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



# clean-up
rm ${INPUTFILE%%.*}*
rm all.fastq
rm C.fastq
rm Cu.fastq
rm empty.fastq
rm nameA.lst
rm name.lst
rm nameM.lst
rm ready_for_celera_mapping.fastq
rm r_empty.fq
rm s_empty.fq
rm unmapped_headers.lst
rm viral.sam


pbzip2 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_readpairs.fastq
pbzip2 1_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_singletons.fastq
pbzip2 nC_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera.fastq
pbzip2 nY_${INPUTFILE%%.*}_PINDELUNMAPPED_trimmed_nonCelera_nonY.fastq


# uncomment for perl-style loop
cd ..
