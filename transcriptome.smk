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
		assembly = os.path.join(TRINITY_OUT, 'Trinity.fasta')

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
