"""
transcriptome assembly of quality controlled short-read RNA seq data

steps: mapping to genome (STAR) -> assembly (Trinity[reference-guided and free]) -> annotation

requirements: snakemake, conda
"""

# handle emailing if specified
# --config email='youremail@domain.tld'
EMAIL = config.get('email', None)
if EMAIL:
	onsuccess: shell("sed '/^$/q' {log} | mail -s 'Pipeline SUCCESS' {email}")
	onerror:   shell("sed '/^$/q' {log} | mail -s 'Pipeline FAILURE' {email}")

# search for what files need to be processed in the fastp directory
SAMPLES = glob_wildcards('fastp/{fastq}_{run}.fastq.gz')

print(SAMPLES.fastq)