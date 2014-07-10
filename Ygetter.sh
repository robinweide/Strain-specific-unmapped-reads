for i in */nameMy.lst
do
echo $i
echo $(echo $i | awk '{print $0"_1"}') 
echo $(echo $i | sed 's%/nameMy.lst%%g' | awk '{print $0"/"$0"_Unmapped_1.fastq"}') 
echo $(echo $i | awk '{print $0"_1_mappedToY.fastq"}')

sed 's@$@/1@g' $i > $(echo $i | awk '{print $0"_1"}')
sed 's@$@/2@g' $i > $(echo $i | awk '{print $0"_2"}')

# trek fastqs eruit
seqtk subseq $(echo $i | sed 's%/nameMy.lst%%g' | awk '{print $0"/"$0"_Unmapped_1.fastq"}') $(echo $i | awk '{print $0"_1"}') > $(echo $i | awk '{print $0"_1_mappedToY.fastq"}')
seqtk subseq $(echo $i | sed 's%/nameMy.lst%%g' | awk '{print $0"/"$0"_Unmapped_2.fastq"}') $(echo $i | awk '{print $0"_2"}') > $(echo $i | awk '{print $0"_2_mappedToY.fastq"}')

done