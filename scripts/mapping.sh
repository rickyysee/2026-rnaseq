#!/usr/bin/env bash

# define paths and variables
GENOME_DIR="AalbF5/index"
FASTQ_DIR="fastp"
OUTPUT_DIR="mapping"
THREADS=4

# limit processing to subset of files for testing
TEST=""

# create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# loop through the forward reads
for f_file in "${FASTQ_DIR}/${TEST}"*_1.fastq.gz; do

	# get the base file name
	sample=$(basename "$f_file" _1.fastq.gz)

	# get the corresponding reverse read
	r_file="${FASTQ_DIR}/${sample}_2.fastq.gz"
	
	# check if this file has been processed
	if [ -d "${OUTPUT_DIR}/${sample}" ]; then
		echo "skipping $sample because output directory exists"
		echo "---"
		continue
	fi

	echo "processing sample: $sample"
	echo "reads:  $f_file and $r_file"
	echo "genome: $GENOME_DIR"
	echo "output: ${OUTPUT_DIR}/${sample}/"
	echo "threads: $THREADS"

	# run the STAR aligner
	# output to OUTPUT_DIR and make new directory per sample
	STAR --runMode alignReads --genomeDir "$GENOME_DIR" \
	--readFilesIn "$f_file" "$r_file" \
	--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate \
	--outFileNamePrefix "${OUTPUT_DIR}/${sample}/" \
	--runThreadN "$THREADS"

	echo "---"
done

: << 'COMMENT'
STAR --runMode alignReads --genomeDir AalbF5/index \
--readFilesIn fastp/19_Aalb_lab_NBF_rep2_1.fastq.gz fastp/19_Aalb_lab_NBF_rep2_2.fastq.gz \
--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate \
--outFileNamePrefix mapping/19_Aalb_lab_NBF_rep2/ \
--runThreadN 4
"""
COMMENT