
# file1 is gapclosers
while read line1; do
	# file2 is compareads
	while read line2; do


# backmap
echo $line1
echo $line2
/data_fedor12/common_scripts/bwa/bwa-0.7.7/bwa mem -t 40 -p $line1 $line2 > $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').sam

samtools view -Sb $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').sam > $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').bam

# get NLC: contig-per-line
samtools sort $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').bam $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').s.bam.bam; bedtools genomecov -ibam $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').s.bam.bam.bam -max 1 | sort -u -k1,1 | tee $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').bedgraph | awk '{if ($2 == 0) print $1"\t"$4"\t"$5; else print $1"\t"$4"\t""0"}' | tee $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').nameLenZerocov | cut -f 1 > $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').headers; samtools view -H $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').s.bam.bam.bam | grep ^"@SQ" | sed 's/SN://g' | awk '{print $0" "}'> $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').allheaders; fgrep -vw -f $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').headers $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').allheaders | awk '{print $2"\t"$3"\t""1"}' | sed 's/LN://g' > $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').namelencov; cat $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').nameLenZerocov >> $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').namelencov; rm $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').allheaders; rm $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').nameLenZerocov; rm $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').headers;  rm $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').bedgraph; rm *.bam; rm *.sam

sort -n -k1,1 $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').namelencov > $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').namelencov1

mv $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').namelencov1 $(basename $line1 | sed 's/_gapcloser.fasta//g')_$(basename $line2 | sed 's/.fastq//g').namelencov

done < file2
done < file1
