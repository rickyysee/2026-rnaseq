#!/usr/bin/bash

# run trinity in genome-guided mode by using the STAR alignment

# PARAMS
INPUT=mapping/19_Aalb_lab_NBF_rep1/Aligned.sortedByCoord.out.bam
INTRON=200000
MEM=10G
THREADS=4
OUTDIR=trinity-transcriptome

Trinity --genome_guided_bam "$INPUT" \
--genome_guided_max_intron "$INTRON" \
--max_memory "$MEM" --CPU "$THREADS" \
--output "$OUTDIR"
