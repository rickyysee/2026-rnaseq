#!/usr/bin/env bash

STAR --runMode genomeGenerate --genomeDir AalbF5-whole/index/ \
--genomeFastaFiles AalbF5-whole/AalbF5_whole.fna --sjdbGTFfile AalbF5-whole/AalbF5_whole.gff \
--sjdbOverhang 100 --genomeSAindexNbases 10 --runThreadN 4

