#!/bin/bash
# Testing modifed file line number count

# -------- CONFIG --------
MODIFIED_DIR="sponsored/author"
PACKAGES_DIR="./output/sponsored/author"

fileName=$(ls ${MODIFIED_DIR}/*.txt | sed -e s/"^.\/sponsored\//"/ | awk 1 ORS=' ') #sed -e s/"^.\/modified\//"/
echo "-------  List of files modified - $fileName -------"

modifiedFileName=$(ls ${MODIFIED_DIR}/*.txt | awk 1 ORS=' ')
echo "------- From ${MODIFIED_DIR} directory -------"
wc -l $modifiedFileName
#presentFileName=$(ls ${MODIFIED_DIR}/*.txt | sed -e s/"^.\/sponsored\///"/ | awk '$0="./output/sponsored/author/"$0' | awk 1 ORS=' ')
presentFileName=$(ls ${MODIFIED_DIR}/*.txt | awk '{split($0,a,"/"); print a[3]}' | awk '$0="./output/sponsored/author/"$0' | awk 1 ORS=' ')

echo "------- From ${PACKAGES_DIR} directory -------"
echo " Running.. wc -l ${presentFileName}"
wc -l ${presentFileName}

