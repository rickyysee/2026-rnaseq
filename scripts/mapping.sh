#!/usr/bin/env bash

# define paths and variables
GENOME_DIR="AalbF5/index"
FASTQ_DIR="fastp"
OUT_DIR="mapping"
THREADS=4

# limit processing to subset of files for testing
TEST="22_Aalb_lab_M_rep3"

# create the output directory if it doesn't exist
mkdir -p "$OUT_DIR"

# loop through the forward reads
for f_file in "${FASTQ_DIR}/${TEST}"*_1.fastq.gz; do

	# get the base file name
	sample=$(basename "$f_file" _1.fastq.gz)

	# get the corresponding reverse read
	r_file="${FASTQ_DIR}/${sample}_2.fastq.gz"
	
	# check if this file has been processed
	if [ -f "${OUT_DIR}/${sample}/Aligned.sortedByCoord.bam" ]; then
		echo "skipping $sample because output BAM exists"
		echo "---"
		continue
	fi

	echo "processing sample: $sample"
	echo "reads:  $f_file and $r_file"
	echo "genome: $GENOME_DIR"
	echo "output: ${OUT_DIR}/${sample}/"
	echo "threads: $THREADS"

	# run the STAR aligner
	# output to OUT_DIR and make new directory per sample
	mkdir -p "${OUT_DIR}/${sample}"
	STAR --runMode alignReads --genomeDir "$GENOME_DIR" \
	--readFilesIn "$f_file" "$r_file" \
	--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate \
	--outFileNamePrefix "${OUT_DIR}/${sample}/" \
	--runThreadN "$THREADS" \
	2> "${OUT_DIR}/${sample}/stderr.log"

	echo "---"
done

: << 'COMMENT'
STAR --runMode alignReads --GENOME_DIR AalbF5/index \
--readFilesIn fastp/19_Aalb_lab_NBF_rep2_1.fastq.gz fastp/19_Aalb_lab_NBF_rep2_2.fastq.gz \
--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate \
--outFileNamePrefix mapping/19_Aalb_lab_NBF_rep2/ \
--runThreadN 4
"""
COMMENT