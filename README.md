# Analysis of Transcriptomic Data

This workflow is meant to standardize and automate the process of analyzing a collection of paired-end RNA-seq files. This workflow is being used to analyze transcriptomic data for Aedes albopictus tarsal and labellar tissue samples but can be applied to other organisms with slight modifications.

## Summary of Workflow

Genome Mapped to: AalbF5

Quality Control: FastQC (0.12.1) and fastp (1.3.6)

Mapping: STAR (2.7.10b)

Transcriptome Assembly: Trinity

Assembly Quality: BUSCO, STAR, ExN50

### Organizing Files

There is a lot of data to work with, so part of the challenge is simply getting a file structure that works well:

```bash
2026-rnaseq
  ├── scripts # scripts to be converted to Snakefiles
  │   ├── time.py
  │   ├── aggregate_star.py
  │   ├── violin.py
  │   ├── trinity.sh
  │   ├── index.sh
  │   ├── counts.sh
  │   ├── mapping.sh
  │   └── trinity_guided.sh
  ├── envs # conda env files
  │   ├── snakemake.yaml
  │   ├── plotting.yaml
  │   └── rnaseq.yaml
  ├── config.yaml # Snakemake config
  ├── transcriptome.smk
  ├── quality.smk
  ├── README.md
# everything below is untracked
  ├── AalbF5
  │   ├── index (from STAR)
  │   └── mini
  │       └── index (from STAR)
  ├── fastp -> /media/...
  ├── fastqc
  ├── mapping -> /mnt/...
  ├── multiqc
  └── raw-fastq
      └── *.fastq.gz -> /media/...

```

Notice that many folders are simply symbolic links to other locations. It is usually best practice to house raw data at a centralized location and link it to the working directory as needed. Ideally, this centralized location would have all of your data, including outputs, but this is not always possible due to storage constraints.

The `.gitignore` file should be strict, so you have to explicitly include files. This would only be scripts, YAMLs, etc.

```bash
# ignore all files
*

# include certain files
!README.md
!.gitignore
!Snakefile
!*.smk
!config.yaml
!envs/
!envs/*
!scripts/
!scripts/*
```

This way, WHAT was done can be saved on GitHub, but the DATA will not be.

### Quality Control

First, we will run some quality assessment programs to minimize low quality data.

To this end, I am using `fastqc` and `fastp` for quality reporting and trimming/filtering respectively. These programs produce many log files, which can be aggregated with the `multiqc` program.

`fastqc` -> `fastp` -> `multiqc`

environment:
```bash
name: fastqc
channels:
  - conda-forge
  - bioconda
  - defaults
dependencies:
  - fastqc=0.12.1
  - fastp=1.3.6
  - multiqc=1.35
```

To ensure reproducibility and allow parallelization, I've made use of `snakemake` (v. 9.26.1) and `graphviz` (v. 14.1.2).

The Snakefile will be kept updated on my GitHub: [Snakefile](https://github.com/rickyysee/2026-rnaseq/blob/main/Snakefile)

### Directories

The raw fastq files will all sit in some directory. In this case, `raw-fastq`. 