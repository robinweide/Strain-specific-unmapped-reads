Readme
====
This repository encloses all scripts and pipelines used for the researchproject of Robin van der Weide for the master "Cancer Stem cells and Development". It is chronologically subdivided.

Extraction of unmapped reads from strains
---
Here, a perl-wrapper is used to loop trough the shellscript. This shellscript holds a bam-extraction, Pindel-analysis and filtering on read-length ann -quality. Eventually, this wrapper should not loop a shellscript, but just execute the commands on its own (I didn't know enough Perl in the beginning to do everything in the language)

Filtering of unmapped reads
-----
...
