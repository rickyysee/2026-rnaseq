#!/usr/bin/env bash

STAR --runMode alignReads --genomeDir AalbF5/mini/index \
--readFilesIn fastp/19_Aalb_lab_NBF_rep1_1.fastq.gz fastp/19_Aalb_lab_NBF_rep1_2.fastq.gz \
--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate \
--outFileNamePrefix mapping/mini/19_Aalb_lab_NBF_rep1/ \
--runThreadN 4
