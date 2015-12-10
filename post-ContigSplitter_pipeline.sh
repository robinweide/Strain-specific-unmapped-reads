# STEP 1
# Remove duplicates
# Remove < 500bp sequences
# Remove trailing denovo-number from fasta-header

# Strain-specific
for i in S.fa/*; do echo $i; python dedupFasta.py $i tmp.fa; seqtk comp tmp.fa | awk '$2 >= 500 {print $1}' > tmp.lst; seqtk subseq tmp.fa tmp.lst | sed  $'/^\>/ s/\t.*//g' > $(basename $i | sed 's#^#500plus/Strain.fa/#'); rm tmp.fa; rm tmp.lst; done
# Common
for i in N.fa/*; do echo $i; python dedupFasta.py $i tmp.fa; seqtk comp tmp.fa | awk '$2 >= 500 {print $1}' > tmp.lst; seqtk subseq tmp.fa tmp.lst | sed  $'/^\>/ s/\t.*//g' > $(basename $i | sed 's#^#500plus/Common.fa/#'); rm tmp.fa; rm tmp.lst; done


# STEP 2
# Get Mouse-matching sequences from previous step

# Strain-specific
for i in SM.lst/*; do echo $i; sort -u $i | seqtk subseq $(basename $i | sed 's#^#500plus/Strain.fa/#' | sed 's/$/.fa/') - > $(basename $i | sed 's#^#500plus/StrainMouse.fa/#' | sed 's/$/.fa/'); done
# Common
for i in NM.lst/*; do echo $i; sort -u $i | seqtk subseq $(basename $i | sed 's#^#500plus/Common.fa/#' | sed 's/$/.fa/') - > $(basename $i | sed 's#^#500plus/CommonMouse.fa/#' | sed 's/$/.fa/'); done


# STEP 3
# Every sequence of STEP1 not in STEP2 is rat-specific
for i in 500plus/Common.fa/*; do echo $i; grep ^'>' $i  | sed 's/>//' | sort -u > tmp1; grep ^'>' $(echo $i | sed 's/Common/CommonMouse/')  | sed 's/>//' | sort -u > tmp2; python filterRatSeqs.py tmp1 tmp2 tmp3; seqtk subseq $i tmp3 > $(echo $i | sed 's/Common/CommonRat/'); done
# Strain-specific
for i in 500plus/Strain.fa/*; do echo $i; grep ^'>' $i  | sed 's/>//' | sort -u > tmp1; grep ^'>' $(echo $i | sed 's/Strain/StrainMouse/')  | sed 's/>//' | sort -u > tmp2; python filterRatSeqs.py tmp1 tmp2 tmp3; seqtk subseq $i tmp3 > $(echo $i | sed 's/Strain/StrainRat/'); done


# STEP 4
# Augustus-prediction 
ls -d -1 $PWD*/*/*.fa | parallel -j 10 '/bin/augustus-3.0.1/bin/augustus --AUGUSTUS_CONFIG_PATH=/bin/augustus-3.0.1/config/ --gff3=on --uniqueGeneId=true --species=human {} > $(echo {} | sed 's/.fa$/.gff3/')'

# STEP 5
# extract stats and AA-fasta's from augustus-output
for i in */*.gff3; do echo $i; python ~/GitHub/Strain-specific-unmapped-reads/augustusGFF3parser.py $i $(echo $i | sed 's/.gff3/.fa/' | sed 's/.gff3//') $(basename $i | sed 's/.gff3//') ; done

# STEP 6
# Combine all protein-fasta's within the common/strain/mouse/rat bins
cat CommonMouse.fa/*.fa > CommonMouse.fasta
cat CommonRat.fa/*.fa > CommonRat.fasta
cat StrainMouse.fa/*.fa > StrainMouse.fasta
cat StrainRat.fa/*.fa > StrainRat.fasta

# STEP 7
# send all four fastas from step 6 to orthoMCL
# http://www.orthomcl.org/orthomcl/proteomeUpload.do

# STEP 8
# Concat all dna-fasta's within the common/strain/mouse/rat bins
for i in ../analysis30June2015/CommonMouse.fa/*.fa; do sed "s/>/>$(basename $i | sed 's/.fa//')_/" $i; done > CommonMouse.fa
for i in ../analysis30June2015/CommonRat.fa/*.fa; do sed "s/>/>$(basename $i | sed 's/.fa//')_/" $i; done > CommonRat.fa
for i in ../analysis30June2015/StrainMouse.fa/*.fa; do sed "s/>/>$(basename $i | sed 's/.fa//')_/" $i; done > StrainMouse.fa
for i in ../analysis30June2015/CommonRat.fa/*.fa; do sed "s/>/>$(basename $i | sed 's/.fa//')_/" $i; done > StrainRat.fa

# STEP 10
# Downloaded files from orthoMCl and used orthologGroups
# Get ortho-genes for panther
for i in *.txt; do awk '{print $3}' $i | sed $'s/|/\t/' | awk '{print $2}' > $(echo $i | sed 's/.txt/.orthoLST/'); done
# Get ortho-animals for pie-chart
for i in *.txt; do echo $i;  awk '{print $3}' $i | sed $'s/|/\t/' | awk '{print $1}' | sort | uniq -c | awk '$1 > 3 {print}' | sort -k1,1 -n; done


# Step 11
# Make figure 5
# Header
echo $'ID\tCR.RM\tCM.RM\tSR.RM\tSM.RM\tCR\tCM\tSR\tSM\tCR.P\tCM.P\tSR.P\tSM.P'  > fig5.raw ; \
for i in CommonRat.fa/*; do echo $(basename $i) > id.tmp; \
# #bases N
seqtk comp $i |  awk '{print ($2-($3+$4+$5+$6))}' |  awk '{ sum+=$1} END {print sum+1}' | awk '{print $1-1}' > CRr.tmp; \
seqtk comp $(echo $i| sed 's/Rat/Mouse/') |  awk '{print ($2-($3+$4+$5+$6))}' |  awk '{ sum+=$1} END {print sum+1}' | awk '{print $1-1}' > CMr.tmp; \
seqtk comp $(echo $i| sed 's/Common/Strain/') |  awk '{print ($2-($3+$4+$5+$6))}' |  awk '{ sum+=$1} END {print sum+1}' | awk '{print $1-1}' > SRr.tmp; \
seqtk comp $(echo $i| sed 's/Rat/Mouse/'| sed 's/Common/Strain/') |  awk '{print ($2-($3+$4+$5+$6))}' |  awk '{ sum+=$1} END {print sum+1}' | awk '{print $1-1}' > SMr.tmp; \
# #bases -N
seqtk comp $i |  awk '{print $2-(($2-($3+$4+$5+$6)))}' |  awk '{ sum+=$1} END {print sum+1}' | awk '{print $1-1}' > CR.tmp; \
seqtk comp $(echo $i| sed 's/Rat/Mouse/') |  awk '{print $2-(($2-($3+$4+$5+$6)))}' |  awk '{ sum+=$1} END {print sum+1}' | awk '{print $1-1}' > CM.tmp; \
seqtk comp $(echo $i| sed 's/Common/Strain/') |  awk '{print $2-(($2-($3+$4+$5+$6)))}' |  awk '{ sum+=$1} END {print sum+1}' | awk '{print $1-1}' > SR.tmp; \
seqtk comp $(echo $i| sed 's/Rat/Mouse/'| sed 's/Common/Strain/') |  awk '{print $2-(($2-($3+$4+$5+$6)))}' |  awk '{ sum+=$1} END {print sum+1}' | awk '{print $1-1}' > SM.tmp; \
# total length coding sequences
grep 'Length protein-coding' $(echo $i | sed 's$^$augustus/$'| sed 's/.fa$/.stats/') |                        grep 'seqs' | grep 'Sum' | awk '{print $5}' > CRp.tmp ;\
grep 'Length protein-coding' $(echo $i | sed 's$^$augustus/$'  | sed 's/Rat/Mouse/'| sed 's/.fa$/.stats/') |  grep 'seqs' | grep 'Sum' | awk '{print $5}' > CMp.tmp ;\
grep 'Length protein-coding' $(echo $i | sed 's$^$augustus/$'  | sed 's/Common/Strain/'| sed 's/.fa$/.stats/') | grep 'seqs' | grep 'Sum' | awk '{print $5}' > SRp.tmp ;\
grep 'Length protein-coding' $(echo $i | sed 's$^$augustus/$'   | sed 's/Rat/Mouse/'| sed 's/Common/Strain/'| sed 's/.fa$/.stats/') | grep 'seqs' | grep 'Sum' | awk '{print $5}' > SMp.tmp ;\
paste id.tmp CRr.tmp CMr.tmp SRr.tmp SMr.tmp CR.tmp CM.tmp SR.tmp SM.tmp CRp.tmp CMp.tmp SRp.tmp SMp.tmp >> fig5.raw; done; rm *.tmp
awk 'NR < 2' fig5.raw | sed $'s/\t/ /g'> tmp; awk 'NR > 1 {print $1,$2,$3,$4,$5,($6-$10),($7-$11),($8-$12),($9-$13),$10,$11,$12,$13}' fig5.raw >> tmp; mv tmp fig5.raw
# Step 12
# R
Strain <- filter(melt(fig5, id.vars = 'ID'), (variable == 'CM' | variable ==  'CM.RM' | variable == 'CM.P' | variable == 'CR' | variable ==  'CR.RM' | variable == 'CR.P') & ID != 'SBN_Ygl.fa')
Common <- filter(melt(fig5, id.vars = 'ID'), (variable == 'CM' | variable ==  'CM.RM' | variable == 'CM.P' | variable == 'CR' | variable ==  'CR.RM' | variable == 'CR.P') & ID != 'SBN_Ygl.fa')
library("ggplot2")

library("reshape2")

cbPalette <- c("#999999",  "#999999", "#56B4E9", "#009E73", "#F0E442", "#E69F00")

ggplot(Strain, aes(value, x = ID, fill = variable, order=factor(variable)) ) +geom_bar(position = "fill", stat="identity") + scale_fill_manual(values=cbPalette) + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(x="Strains", y= "Percentage non-EVE{Celera} (0-1%)") + coord_flip()
ggplot(Common, aes(value, x = ID, fill = variable, order=factor(variable)) ) + geom_bar(position = "fill", stat="identity") + scale_fill_manual(values=cbPalette) + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + labs(x="Strains", y= "Percentage non-EVE{Celera} (0-1%)") + coord_flip()

# Step 13
# lengths of assemblies
for i in Common.fasta/*; do seqtk comp $i | awk '{ sum+=$2} END { print sum}'; done > lenCommon.tt
for i in Strain.fasta/*; do seqtk comp $i | awk '{ sum+=$2} END { print sum}'; done > lenStrain.tt
