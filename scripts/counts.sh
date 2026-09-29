#!/usr/bin/bash

# use featureCounts to generate count matrix of all samples in the mapping folder

# CONFIG
OUTDIR=counting
# use same GFF/GTF as used by STAR to index
GFILE=AalbF5/AalbF5_whole.gff
STRAND=2
THREADS=4

# look for BAM files
BAMS=( ./mapping/*/Aligned.sortedByCoord.out.bam )

# if no files were found, exit
if [[ ! -e "${BAMS[0]}" ]]; then
	echo "ERROR: no BAM files found" >&2
	exit 1
fi

# report BAM files
echo "Found ${#BAMS[@]} BAM files"
printf ' %s\n' "${BAMS[@]}"

# run featureCounts and make one count table
mkdir -p "$OUTDIR"
featureCounts -T "$THREADS" -p --countReadPairs -s "$STRAND" -a "$GFILE" \
-t exon -g ID -o "$OUTDIR/counts.txt" \
"${BAMS[@]}" \
2> "$OUTDIR"/featureCounts.log