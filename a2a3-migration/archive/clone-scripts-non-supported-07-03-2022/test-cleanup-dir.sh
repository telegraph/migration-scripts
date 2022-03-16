#!/bin/bash
# Testing number of files in a directory

OUTPUT_A2_BACKUP="./output/a2-backup"
OUTPUT_A2_BACKUP_P1="./output/a2-backup-p1"
OUTPUT_A3_MIGRATED="./output/a3-migrated"
OUTPUT_A3_MIGRATED_P1="./output/a3-migrated-p1"
INPUT="input"
clearDir() {
  directory="$1"
  rm $directory/*.*
}

clearDir "${OUTPUT_A2_BACKUP}"
clearDir "${OUTPUT_A2_BACKUP_P1}"
clearDir "${OUTPUT_A3_MIGRATED}"
clearDir "${OUTPUT_A3_MIGRATED_P1}"
rm ${INPUT}/input-urls.txt; touch ${INPUT}/input-urls.txt
rm ${INPUT}/input-urls-p1.txt; touch ${INPUT}/input-urls-p1.txt


