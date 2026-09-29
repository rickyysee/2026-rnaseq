#!/usr/bin/bash

# use featureCounts to generate count matrix of all samples in the mapping folder

# CONFIG
OUTDIR=counting
# use same GFF as used by STAR to index
GFF=AalbF5/AalbF5_whole.gff
STRAND=2
THREADS=4

# look for BAM files
BAMS=( ./mapping/*/Aligned.sortedByCoord.out.bam )

# if no files were found, exit
if [[ ! -e "${BAMS[@]}" ]]; then
	echo "ERROR: no BAM files found" >&2
	exit 1
fi

# report BAM files
echo "Found ${#BAMS[@]} BAM files"
printf ' %s\n' "${BAMS[@]}"

# run featureCounts and make one count table
featureCounts -T "$THREADS" -p --countReadPairs -s "$STRAND" -a "$GFF" \
-t exon -g gene_id -o "$OUTDIR/counts.txt" \
"${BAMS[@]}" \
2> "$OUTDIR/featureCounts.log"