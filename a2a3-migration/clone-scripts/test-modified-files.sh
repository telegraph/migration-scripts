#!/bin/bash
# Testing modifed file line number count

# -------- CONFIG --------
MODIFIED_DIR="./modified"
PACKAGES_DIR="./output/a3-migrated"

fileName=$(ls ${MODIFIED_DIR}/*.txt | sed -e s/"^.\/modified\//"/ | awk 1 ORS=' ') #sed -e s/"^.\/modified\//"/
echo "-------  List of files modified - $fileName -------"

modifiedFileName=$(ls ${MODIFIED_DIR}/*.txt | awk 1 ORS=' ')
echo "------- From ${MODIFIED_DIR} directory -------"
wc -l $modifiedFileName
presentFileName=$(ls ${MODIFIED_DIR}/*.txt | sed -e s/"^.\/modified\//"/ | awk '$0="./output/a3-migrated/"$0' | awk 1 ORS=' ')

echo "------- From ${PACKAGES_DIR} directory -------"
echo " Running.. wc -l ${presentFileName}"
wc -l ${presentFileName}

