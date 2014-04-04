Readme
====
This repository encloses all scripts and pipelines used for the researchproject of Robin van der Weide for the master "Cancer Stem cells and Development". It is chronologically subdivided.

Extraction of unmapped reads from strains
---
Here, a perl-wrapper is used to loop trough the shellscript. This shellscript holds a bam-extraction, Pindel-analysis and filtering on read-length ann -quality. Eventually, this wrapper should not loop a shellscript, but just execute the commands on its own (I didn't know enough Perl in the beginning to do everything in the language)

Filtering of unmapped reads
-----

The shell-script map-based_filtering-Celera,Ychr,ViPro.sh serves as a pipeline for the filtering of unmapped reads. It calls reads mapped, that properly map with their mate. At each of the mapping stages, two files are generated: the mapped and unmapped paired reads. It also writes to the report.txt (allready used by the extraction-script)

Shell-looper
-------
A simple perl-script that takes two arguments, inputfiles and shellscript, and runs it. This is handy to use, if there a multiple scripts needed for the same multiple files. I know, this loop can be incorporated in every shellscript: but this is just a simple perlscript for people that do not want to mess with adding loops in shell scripts.