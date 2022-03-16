#!/bin/bash
# Copy files from multiple directories to a single directory

# -------- CONFIG --------
SRC_DIR="output/backup/folders/pub"
DEST_DIR="output/sponsored/pub"

# ------ Create updated package  --------
echo "Starting..."
rmdir ${DEST_DIR}
mkdir ${DEST_DIR}
for file in ${SRC_DIR}/*; do
  fileName=$(basename "$file")
  packageName=(${fileName//./ })
  for file1 in ${file}/*; do
    fileName1=$(basename "$file1")
    packageName1=(${fileName1//./ })
    cp "${file1}" ${DEST_DIR}
    echo "File copied from $file1 to ${DEST_DIR}"
  done
done
echo "END"
