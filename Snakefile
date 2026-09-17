# ------------------------------------------------------------------
# QC + Adapter/Quality Trimming Pipeline for Paired-End FASTQ Data
#
# steps: FastQC (raw) -> fastp (trim) -> FastQC (trimmed) -> MultiQC
#
# requirements: conda, snakemake
# ------------------------------------------------------------------

SAMPLES,RUNS = glob_wildcards('fastq/{fastq}_{run}.fastq.gz')

# SAMPLES = ['19_Aalb_leg_NBF_rep1']

RUNS = ['1', '2']
# print(SAMPLES, RUNS)

rule all:
	input:
		fastqc = expand('fastqc/{fastq}_{run}_fastqc.html', fastq=SAMPLES, run=RUNS),
		fastp  = expand('fastp/{fastq}_{run}.fastq.gz', fastq=SAMPLES, run=RUNS),
		multiqc = 'multiqc/multiqc_report.html'

rule fastqc:
	input: 'fastq/{fastq}.fastq.gz'
	output: 
		html = 'fastqc/{fastq}_fastqc.html',
		zip = 'fastqc/{fastq}_fastqc.zip'
	params: outdir = 'fastqc'
	conda: 'fastqc.yaml'
	shell:
		"""
		mkdir -p {params.outdir}
		fastqc -o {params.outdir} {input}
		"""

rule fastp:
	input: 
		r1 = 'fastq/{fastq}_1.fastq.gz',
		r2 = 'fastq/{fastq}_2.fastq.gz'
	output: 
		t1   = 'fastp/{fastq}_1.fastq.gz',
		t2   = 'fastp/{fastq}_2.fastq.gz',
		html = 'fastp/logs/{fastq}.html',
		json = 'fastp/logs/{fastq}.fastp.json'
	params: 
		outdir = 'fastp/logs'
	conda: 'fastqc.yaml'
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
		fastqc = expand('fastqc/{fastq}_{run}_fastqc.html', fastq=SAMPLES, run=RUNS),
		fastp  = expand('fastp/logs/{fastq}.fastp.json', fastq=SAMPLES)
	output: 'multiqc/multiqc_report.html'
	conda: 'fastqc.yaml'
	shell:
		"""
		mkdir -p multiqc
		multiqc . --ignore .snakemake --outdir multiqc --no-ai
		"""
