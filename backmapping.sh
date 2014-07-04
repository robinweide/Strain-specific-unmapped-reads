
# file1 is gapclosers
while read line1; do
	# file2 is compareads
	while read line2; do


# backmap
echo $line1
echo $line2
/data_fedor12/common_scripts/bwa/bwa-0.7.7/bwa mem -t 40 -p $line1 $line2 > $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').bam

# get NLC: contig-per-line
samtools sort $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').bam $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').s.bam.bam; bedtools genomecov -ibam $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').s.bam.bam -max 1 | sort -u -k1,1 | tee $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').bedgraph | awk '{if ($2 == 0) print $1"\t"$4"\t"$5; else print $1"\t"$4"\t""0"}' | tee $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').nameLenZerocov | cut -f 1 > $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').headers; samtools view -H $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').s.bam.bam | grep ^"@SQ" | sed 's/SN://g' | awk '{print $0" "}'> $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').allheaders; fgrep -vw -f $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').headers $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').allheaders | awk '{print $2"\t"$3"\t""0"}' | sed 's/LN://g' > $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').namelencov; cat $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').nameLenZerocov >> $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').namelencov; rm $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').allheaders; rm $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').nameLenZerocov; rm $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').headers; rm $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').s.bam.bam; rm $(basename $line1 | sed 's/.fasta//g')_$(basename $line2 | sed 's/.fasta//g').bedgraph



done < file2
done < file1
