echo "Genomic segment" > temp
echo "Size" > ttemp

awk '{print $0"\t"FILENAME}' $1_* | sed 's/'$1'_//g' | sed 's/.namelencov//g' | sort -k1,1 -k4,4 | head -n 33 | awk '{print $4}' | sed 's$_$/$g' | sed 's$BGI/F344$F344/NHsd$g' | sed 's$tadao/F344$F344/Stm$g' | sed 's/olal/Olal/g' | sed 's$DA$Da/BklArbNsi$g' | paste temp ttemp - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - > $1.SSresource

awk '{print $0"\t"FILENAME}' $1_* | sed 's/'$1'_//g' | sed 's/.namelencov//g' | sort -k1,1 -k4,4 | paste - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - | awk '{print $1"\t"$2"\t"$3"\t"$7"\t"$11"\t"$15"\t"$19"\t"$23"\t"$27"\t"$31"\t"$35"\t"$39"\t"$43"\t"$47"\t"$51"\t"$55"\t"$59"\t"$63"\t"$67"\t"$71"\t"$75"\t"$79"\t"$83"\t"$87"\t"$91"\t"$95"\t"$99"\t"$103"\t"$107"\t"$111"\t"$115"\t"$119"\t"$123"\t"$127}' >> $1.SSresource

rm temp
rm ttemp
