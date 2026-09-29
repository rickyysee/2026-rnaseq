#!/usr/bin/env bash

STAR --runMode genomeGenerate --genomeDir AalbF5/index/ \
--genomeFastaFiles AalbF5/AalbF5_whole.fna --sjdbGTFfile AalbF5/AalbF5_whole.gff \
--sjdbOverhang 100 --genomeSAindexNbases 10 --runThreadN 4

