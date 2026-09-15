# Analysis of RNA Seq Data

This repo will house various workflows for working with RNA seq data, including tools that perform quality control, trimming and filtering, mapping and quantifying, de novo assembly and annotation, and possibly more.

The overall workflow is:

FastQC &Rightarrow; fastp &Rightarrow; STAR &Rightarrow; transXpress / StringTie / Trinity &Rightarrow; BLAST &Rightarrow; BUSCO and Bowtie2

The initial step, FASTQC, expects a folder named `fastq` with gzipped FASTQ files. To run this, simply use:

```bash
snakemake -c [cores to use] --use-conda 
```

Dependencies:
- snakemake
- Conda