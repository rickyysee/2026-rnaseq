"""
transcriptome assembly of quality controlled short-read RNA seq data
NOTE: this workflow should be started after quality control of rna-seq reads

steps: mapping to genome (STAR) -> assembly (Trinity[reference-guided and free]) -> annotation

requirements: snakemake, conda
"""

import os
import sys
configfile: 'config.yaml'

# import configuration variables
INPUT       = config['FASTP_OUT']
GENOME_DIR  = config['GENOME_DIR']
GENOME_IND  = os.path.join(GENOME_DIR, 'index')
GENOME_SA   = os.path.join(GENOME_IND, 'SA')
GENOME_FNA  = os.path.join(GENOME_DIR, config['GENOME_FNA'])
GENOME_GFF  = os.path.join(GENOME_DIR, config['GENOME_GFF'])
STAR_OUT    = config['STAR_OUT']
TRINITY_OUT = config['TRINITY_OUT']
THREADS     = config['THREADS']

# handle emailing if specified
# --config email='youremail@domain.tld'
EMAIL = config.get('email', None)
if EMAIL:
	onsuccess: shell("sed '/^$/q' {log} | mail -s 'Pipeline SUCCESS' {email}")
	onerror:   shell("sed '/^$/q' {log} | mail -s 'Pipeline FAILURE' {email}")

# search fastq directory all fastq files
SAMPLES, RUNS = glob_wildcards(os.path.join(INPUT, '{sample}_{run}.fastq.gz'))
SAMPLES = ['19_Aalb_leg_NBF_rep1','19_Aalb_lab_NBF_rep1']

RUNS = set(RUNS)
RUNS = list(RUNS)
RUNS.sort()

# exit if the number of runs found is not 2, which indicates inconsistent naming or SE reads
if len(RUNS) != 2: sys.exit('error: runs per sample is not 2, please check file naming (should be [sample]_[run].fastq.gz)')

rule all:
	input:
		assembly = os.path.join(TRINITY_OUT, 'Trinity.fasta'),
		mapping  = expand('{mapping}/{sample}/Aligned.sortedByCoord.out.bam', mapping=STAR_OUT, sample=SAMPLES)

rule assemble:
	input:
		r1 = expand('{input}/{sample}_1.fastq.gz', input=INPUT, sample=SAMPLES),
		r2 = expand('{input}/{sample}_2.fastq.gz', input=INPUT, sample=SAMPLES)
	output:
		assembly = os.path.join(TRINITY_OUT, 'Trinity.fasta'),
		outdir   = directory(TRINITY_OUT)
	params:
		r1_list = ','.join(expand('{input}/{sample}_1.fastq.gz', input=INPUT, sample=SAMPLES)),
		r2_list = ','.join(expand('{input}/{sample}_2.fastq.gz', input=INPUT, sample=SAMPLES))
	conda: 'envs/rnaseq.yaml'
	shell:
		"""
		Trinity --seqType fq --max_memory 25G \
		--left {params.r1_list} \
		--right {params.r2_list} \
		--CPU {THREADS}
		--output {output.outdir}
		"""

rule index:
	input:
		genome_fna = GENOME_FNA,
		genome_gff = GENOME_GFF
	output:
		genome_SA  = GENOME_SA,
		index_DIR  = directory(GENOME_IND)
	conda: 'envs/rnaseq.yaml'
	shell:
		"""
		STAR --runMode genomeGenerate --genomeDir {output.index_DIR} \
		--genomeFastaFiles {input.genome_fna} --sjdbGTFfile {input.genome_gff} \
		--sjdbOverhang 100 --genomeSAindexNbases 10 --runThreadN {THREADS}
		"""

rule mapping:
	input:
		genome_SA = GENOME_SA,
		r1 = INPUT + '/{sample}_1.fastq.gz',
		r2 = INPUT + '/{sample}_2.fastq.gz'
	output:
		mapping_dir = directory(STAR_OUT + '/{sample}'),
		mapping = STAR_OUT + '/{sample}/Aligned.sortedByCoord.out.bam'
	conda: 'envs/rnaseq.yaml'
	shell:
		"""
		STAR --runMode alignReads --genomeDir {GENOME_IND} \
		--readFilesIn {input.r1} {input.r2} \
		--readFilesCommand zcat --outSAMtype BAM SortedByCoordinate \
		--quantMode GeneCounts \
		--outFileNamePrefix {output.mapping_dir}/ \
		--runThreadN {THREADS}
		"""
