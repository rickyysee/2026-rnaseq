#### In summary:
Genome Mapped to: AalbF3 (now we have it mapped to AalbF5)
Mapping: TopHat (older, try STAR or HISAT2 now)
```bash
tophat -p 20 -o Mapping --library-type fr-firststrand -g 1 --no-discordant --no-mixed
```
De novo assembly: Cufflinks (maybe use [transXpress](http://pubmed.ncbi.nlm.nih.gov/37016291/))
```bash
cufflinks --library-type fr-firststrand
```
De novo annotation: Blast
```bash
blastn -outfmt “6 qseqid sseqid qlen slen pident length bitscore” -evalue 1e-3
```
Could add:
- BUSCO (universal benchmark)
- Bowtie2 (mapping to self)
- [Trinity](https://github.com/trinityrnaseq/trinityrnaseq/wiki) ("true" de novo assembly without reference genome)

It doesn't look like quality filtering/trimming was done, which is probably okay for some mapping algorithms (unsure about TopHat).

### Organizing Files

There is a lot of data to work with, so part of the challenge is simply getting a file structure that works well. Here is what I have currently (9/18/26):

```bash
2026-rnaseq
  ├── envs
  │   ├── fastqc.yaml
  │   └── star.yaml
  ├── Snakefile
  ├── README.md
  ├── mapping.sh
  ├── index.sh
  ├── .gitignore
# everything below is untracked
  ├── AalbF5
  │   ├── index (from STAR)
  │   └── mini
  │       └── index (from STAR)
  ├── fastp -> /media/rcantua/T9/mapping_Aalb5/rnaseq/fastp
  ├── fastqc
  ├── mapping -> /mnt/data/2026-rnaseq/mapping
  ├── multiqc
  └── raw-fastq
      └── *.fastq.gz -> /media/rcantua/T9/mapping_Aalb5/*fastq.gz

```

Notice that many folders are simply symbolic links to other locations because a single mount point is not enough for me to store all this data. In the future, a cluster should be able to accomodate this data; the file hierarchy shouldn't need to change.

The `.gitignore` file should be strict, so you have to explicitly include files. This would only be scripts, YAMLs, etc.

```bash
# ignore all files
*

# include certain files
!README.md
!.gitignore
!Snakefile
!envs
!envs/*
!scripts/
!scripts/*
```

This way, WHAT was done can be saved on GitHub, but the DATA will not be.

### Quality Control

First, I want to run some quality assessment programs to minimize low quality data.

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