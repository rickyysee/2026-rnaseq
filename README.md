# Analysis of Transcriptomic Data

This workflow is meant to standardize and automate the process of analyzing a collection of paired-end RNA-seq files. This workflow is being used to analyze transcriptomic data for Aedes albopictus tarsal and labellar tissue samples but can be applied to other organisms with slight modifications.

## Summary of Workflow

Genome Mapped to: AalbF5

Quality Control: `FastQC` (0.12.1) and `fastp` (1.3.6)

Mapping: `STAR` (2.7.10b)

Transcriptome Assembly: `Trinity`

Assembly Quality: `BUSCO`, `STAR`, `ExN50`

Log Aggregation: `MultiQC` (1.35)

## Requirements

Clone this repository to your workstation and `cd` into it.

This workflow makes use of Conda to manage environments and dependencies. Follow instructions on the [Anaconda installation page](https://www.anaconda.com/docs/getting-started/installation).

If you are working in a cluster environment, the admin likely already installed Conda, refer to their documentation.

There are two main environments that are needed for this workflow: `snakemake` and `rnaseq`.

Both of these environments can be found in the `envs` directory of this repo and can be created with:

```bash
conda env create -f envs/snakemake.yaml
conda env create -f envs/rnaseq.yaml
```
> Note: creating an environment for `rnaseq` is not necessary because Snakemake will generate one on the first run

## Running Snakemake

Each analysis step has a corresponding Snakefile to run predefined shell commands. The Snakefiles can be found in the working directory and end in `.smk`. To call a specific Snakefile, use:

```bash
snakemake -s [file.smk] --use-conda -c [cores]
```

The `config.yaml` file is the main confiugration file for Snakemake. Here, you can define directory names and some global parameters. For more fine-tuned changes, you may edit the Snakefiles themselves but note that this is usually trickier and requires understanding Snakemake rules and wildcards as well as Python syntax.

For tractability, I will refer to configurable variables as `config['VAR_NAME']` throughout this document.

## File Structure

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

Notice that many folders are simply symbolic links to other locations. It is usually best practice to house raw data at a centralized location and link it to the working directory as needed. To achieve this, **create output directories before running the workflows**.

Here's an example of creating a linked directory for `fastp` output (assuming you cloned this repo to `~/Code`):

```bash
cd /path/to/storage/media
mkdir -p fastp
cd ~/Code/2026-rnaseq
ln -s /path/to/storage/media/rnaseq .
```

Again, this should be done depending on your own storage allocations and is only necessary if your working directory does not have sufficient disk space (hundreds of GB depending on raw data).

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

# Workflow Steps

## Quality Control

Snakefile: `quality.smk`

First, we will run some quality assessment and preprocessing programs. This workflow uses `fastqc` and `fastp` for quality reporting and trimming/filtering respectively. These programs produce many log files, which can be aggregated with the `multiqc` program.

`fastqc` -> `fastp` -> `multiqc`

First, `fastqc` is run on every file detected in `config['INPUT_DIR']` (default is `raw-fastq`).
