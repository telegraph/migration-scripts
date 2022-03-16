#!/bin/bash
# Testing number of files in a directory

OUTPUT_A2_BACKUP="./output/a2-backup"
OUTPUT_A2_BACKUP_P1="./output/a2-backup-p1"
OUTPUT_A2_BACKUP_PREFIX="a2-backup"
OUTPUT_A3_MIGRATED="./output/a3-migrated"
OUTPUT_A3_MIGRATED_P1="./output/a3-migrated-p1"
OUTPUT_A3_MIGRATED_P1_PREFIX="a3-migrated"

checkFilesInADir() {
  directory="$1"
  fileNamePrefix="$2"
  textFiles=$(ls ./${directory}/${fileNamePrefix}*.txt | wc -l)
  zipFiles=$(ls ./${directory}/${fileNamePrefix}*.zip | wc -l)

  if [ "$textFiles" = "$zipFiles" ]; then
    echo "$textFiles text files and $zipFiles zip files are equals in ${directory} directory"
  else
    echo "$textFiles text files and $zipFiles zip files are NOT EQUAL in ${directory} directory"
  fi
}

checkFilesInADir "${OUTPUT_A2_BACKUP}" "${OUTPUT_A2_BACKUP_PREFIX}"
checkFilesInADir "${OUTPUT_A2_BACKUP_P1}" "${OUTPUT_A2_BACKUP_PREFIX}"
checkFilesInADir "${OUTPUT_A3_MIGRATED}" "${OUTPUT_A3_MIGRATED_P1_PREFIX}"
checkFilesInADir "${OUTPUT_A3_MIGRATED_P1}" "${OUTPUT_A3_MIGRATED_P1_PREFIX}"
