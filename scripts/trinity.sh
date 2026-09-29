#!/usr/bin/bash

# simple script to run trinity on a set of fastq PE reads

Trinity --seqType fq --max_memory 20G \
--left $(find fastp/ -name '*_1.fastq.gz' -printf '%p,') \
--right $(find fastp/ -name '*_2.fastq.gz' -printf '%p,') \
--CPU 4
