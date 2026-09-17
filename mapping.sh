#!/usr/bin/env bash

STAR --runMode alignReads --genomeDir AalbF5-whole/index \
--readFilesIn fastp/19_Aalb_lab_NBF_rep1_1.fastq.gz fastp/19_Aalb_lab_NBF_rep1_2.fastq.gz \
--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate \
--outFileNamePrefix star/19_Aalb_lab_NBF_rep1/paired/whole/ \
--runThreadN 4
