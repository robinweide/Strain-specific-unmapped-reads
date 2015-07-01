# STEP 1
# Remove duplicates
# Remove < 500bp sequences
# Remove trailing denovo-number from fasta-header

# Strain-specific
for i in S.fa/*; do echo $i; python ~/GitHub/Strain-specific-unmapped-reads/dedupFasta.py $i tmp.fa; seqtk comp tmp.fa | awk '$2 >= 500 {print $1}' > tmp.lst; seqtk subseq tmp.fa tmp.lst | sed  $'/^\>/ s/\t.*//g' > $(basename $i | sed 's#^#500plus/Strain.fa/#'); rm tmp.fa; rm tmp.lst; done
# Common
for i in N.fa/*; do echo $i; python ~/GitHub/Strain-specific-unmapped-reads/dedupFasta.py $i tmp.fa; seqtk comp tmp.fa | awk '$2 >= 500 {print $1}' > tmp.lst; seqtk subseq tmp.fa tmp.lst | sed  $'/^\>/ s/\t.*//g' > $(basename $i | sed 's#^#500plus/Common.fa/#'); rm tmp.fa; rm tmp.lst; done


# STEP 2
# Get Mouse-matching sequences from previous step

# Strain-specific
for i in SM.lst/*; do echo $i; sort -u $i | seqtk subseq $(basename $i | sed 's#^#500plus/Strain.fa/#' | sed 's/$/.fa/') - > $(basename $i | sed 's#^#500plus/StrainMouse.fa/#' | sed 's/$/.fa/'); done
# Common
for i in NM.lst/*; do echo $i; sort -u $i | seqtk subseq $(basename $i | sed 's#^#500plus/Common.fa/#' | sed 's/$/.fa/') - > $(basename $i | sed 's#^#500plus/CommonMouse.fa/#' | sed 's/$/.fa/'); done


# STEP 3
# Every sequence of STEP1 not in STEP2 is rat-specific
for i in 500plus/Common.fa/*; do echo $i; grep ^'>' $i  | sed 's/>//' | sort -u > tmp1; grep ^'>' $(echo $i | sed 's/Common/CommonMouse/')  | sed 's/>//' | sort -u > tmp2; python ~/GitHub/Strain-specific-unmapped-reads/filterRatSeqs.py tmp1 tmp2 tmp3; seqtk subseq $i tmp3 > $(echo $i | sed 's/Common/CommonRat/'); done
# Strain-specific
for i in 500plus/Strain.fa/*; do echo $i; grep ^'>' $i  | sed 's/>//' | sort -u > tmp1; grep ^'>' $(echo $i | sed 's/Strain/StrainMouse/')  | sed 's/>//' | sort -u > tmp2; python ~/GitHub/Strain-specific-unmapped-reads/filterRatSeqs.py tmp1 tmp2 tmp3; seqtk subseq $i tmp3 > $(echo $i | sed 's/Strain/StrainRat/'); done


# STEP 4
# Augustus-prediction on fedor12
ls -d -1 $PWD*/*/*.fa | parallel -j 10 '/home/robin/bin/augustus-3.0.1/bin/augustus --AUGUSTUS_CONFIG_PATH=/home/robin/bin/augustus-3.0.1/config/ --gff3=on --uniqueGeneId=true --species=human {} > $(echo {} | sed 's/.fa$/.gff3/')'
