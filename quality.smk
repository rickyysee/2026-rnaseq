"""
QC + Adapter/Quality Trimming Pipeline for Paired-End FASTQ Data

steps: FastQC (raw) -> fastp (trim) -> MultiQC

requirements: conda, snakemake
"""

import os
import sys
configfile: 'config.yaml'

# import configuration variables
INPUT  = config['INPUT_DIR']
FASTQC = config['FASTQC_OUT']
FASTP  = config['FASTP_OUT']

# ensure directories are given, otherwise can run into root directory issues
if not INPUT or not FASTQC or not FASTP:
	sys.exit('error: input and output directory names cannot be empty')

# handle emailing if specified
# --config email='youremail@domain.tld'
EMAIL = config.get('email', None)
if EMAIL:
	onsuccess: shell("sed '/^$/q' {log} | mail -s 'Pipeline SUCCESS' {email}")
	onerror:   shell("sed '/^$/q' {log} | mail -s 'Pipeline FAILURE' {email}")

# search fastq directory all fastq files
SAMPLES, RUNS = glob_wildcards(os.path.join(INPUT, '{sample}_{run}.fastq.gz'))
# SAMPLES = ['19_Aalb_leg_NBF_rep1']
RUNS = set(RUNS)
RUNS = list(RUNS)
RUNS.sort()

# exit if the number of runs found is not 2, which indicates inconsistent naming or SE reads
if len(RUNS) != 2: sys.exit('error: runs per sample is not 2, please check file naming (should be [sample]_[run].fastq.gz)')

###

rule all:
	input:
		# fastqc = expand('{fastqc}/{sample}_{run}_fastqc.html', fastqc=FASTQC, sample=SAMPLES, run=RUNS),
		fastp  = expand('{fastp}/{sample}_{run}.fastq.gz', fastp=FASTP, sample=SAMPLES, run=RUNS),
		multiqc = 'multiqc/multiqc_report.html'

rule fastqc:
	input: INPUT + '/{sample}_{run}.fastq.gz'
	output: 
		html = FASTQC + '/{sample}_{run}_fastqc.html',
		zip = FASTQC + '/{sample}_{run}_fastqc.zip'
	params: outdir = FASTQC
	conda: 'envs/rnaseq.yaml'
	shell:
		"""
		mkdir -p {params.outdir}
		fastqc -o {params.outdir} {input}
		"""

rule fastp:
	input: 
		r1 = INPUT + '/{sample}_' + RUNS[0] + '.fastq.gz',
		r2 = INPUT + '/{sample}_' + RUNS[1] + '.fastq.gz',
		zip1 = FASTQC + '/{sample}_' + RUNS[0] + '_fastqc.zip',
		zip2 = FASTQC + '/{sample}_' + RUNS[1] + '_fastqc.zip',
	output: 
		t1 = FASTP + '/{sample}_' + RUNS[0] + '.fastq.gz',
		t2 = FASTP + '/{sample}_' + RUNS[1] + '.fastq.gz',
		html = FASTP + '/logs/{sample}.html',
		json = FASTP + '/logs/{sample}.fastp.json'
	params: 
		outdir = FASTP + '/logs'
	conda: 'envs/rnaseq.yaml'
	shell:
		"""
		mkdir -p {params.outdir}
		fastp -i {input.r1} -I {input.r2} \
		-o {output.t1} -O {output.t2} \
		-h {output.html} -j {output.json} \
		--detect_adapter_for_pe
		"""

rule multiqc:
	input: 
		fastqc = expand('{fastqc}/{sample}_{run}_fastqc.html', fastqc=FASTQC, sample=SAMPLES, run=RUNS),
		fastp  = expand('{fastp}/logs/{sample}.fastp.json', fastp=FASTP, sample=SAMPLES)
	output: 'multiqc/multiqc_report.html'
	conda: 'envs/rnaseq.yaml'
	shell:
		"""
		mkdir -p multiqc
		multiqc . --ignore .snakemake --outdir multiqc --no-ai
		"""
