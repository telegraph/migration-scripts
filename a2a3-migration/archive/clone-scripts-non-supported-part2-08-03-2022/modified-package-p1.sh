#!/bin/bash
# Gets the modified pages file and deleted those pages from the pages paths file and re-create and build the package in the HOST
# Passwords are dummy passwords.

# -------- CONFIG --------
MODIFIED_DIR="./modified-p1"
PACKAGES_DIR="./output/a3-migrated-p1"
PAGES_TO_REMOVE_FILE="./input/pages_to_remove.txt"


USERNAME="telegraph"
PASSWORD="<PASSWORD>"
HOST="10.38.10.9"
PORT="4503"
PROTOCOL="http://"

OUTPUT_DIR="${MODIFIED_DIR}/output"
TEMP_FILE="tmp.txt"
TEMP_FILE_1="tmp1.txt"
LOG_FILE="info.log"

# -------- CONFIG --------

# FUNCTIONS
deleteFile() {
  if [ -f "${1}" ]; then
    rm -rf "${1}"
  fi
}

getFilters() {
  filter=""
  while read line; do
    if [ ! -z "$line" ]; then
      echo "${2} : ${line}" >>"${OUTPUT_DIR}/${LOG_FILE}"
      filter="${filter} {\"root\" : \"${line}\", \"rules\": []}, "
    fi
  done <"${1}"
  echo "${filter:0:${#filter}-2}"
}

processPackage() {

  packageName="${1}"
  echo "Processing package ${packageName}"
  filters=$(getFilters "${OUTPUT_DIR}/tmp.txt" "${packageName}")
  printf "${packageName} filters \n"

  cp "${OUTPUT_DIR}/tmp.txt" "${OUTPUT_DIR}/${packageName}.txt"

  printf "${packageName} updating in ${HOST} \n"
  curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/update.jsp" -F path="/etc/packages/my_packages/${packageName}".zip -F packageName="${packageName}" -F groupName=my_packages -F filter="[${filters}]" -F '_charset_=UTF-8'
  printf "\n"

  printf "${packageName} building in ${HOST} \n"
  curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip?cmd=build"
  printf "\n"

  printf "${packageName} downloaded from host ${HOST} to ${OUTPUT_DIR}\n"
  curl -s -o "${OUTPUT_DIR}/${packageName}.zip" -u "${USERNAME}":"${PASSWORD}" "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/download.jsp?_charset_=utf-8&path=/etc/packages/my_packages/${packageName}.zip"
  printf "\n"

  echo "---- END - processing batch $batchNumber of $CHUNKS rows ----- in host ${HOST}"
  deleteFile "${OUTPUT_DIR}/${TEMP_FILE}"

}

# ------ MAIN --------
echo "---- BEGIN - processing packages ---- in host ${HOST}"
rm -rf ${MODIFIED_DIR} ${OUTPUT_DIR}
mkdir ${MODIFIED_DIR}
mkdir ${OUTPUT_DIR}
echo "grep -x -l -F -f ${PAGES_TO_REMOVE_FILE} ${PACKAGES_DIR}/*.txt | sort --unique"
packages=$(grep -x -l -F -f ${PAGES_TO_REMOVE_FILE} ${PACKAGES_DIR}/*.txt | sort --unique)
length="${packages[@]}"
echo "Following packages are modified: in  ${PACKAGES_DIR} from the file ${PAGES_TO_REMOVE_FILE}"
printf "${packages} \n"

# ------ Copy files  --------
echo "Copying files to ${MODIFIED_DIR}  dir"
for p in ${length}; do
  file=(${p//// })
  fileName=${file[3]}
  #fileName=$(basename "$file")
  cp "./${p}" ${MODIFIED_DIR}
  echo " ${p} copied to ${MODIFIED_DIR}  and file =${file}, fileName =${fileName} "
  echo "grep -v -f ${PAGES_TO_REMOVE_FILE} ${MODIFIED_DIR}/${fileName} >${OUTPUT_DIR}/${TEMP_FILE_1} && mv ${OUTPUT_DIR}/${TEMP_FILE_1} ${MODIFIED_DIR}/${fileName}"
  grep -v -f ${PAGES_TO_REMOVE_FILE} ${MODIFIED_DIR}/${fileName} >${OUTPUT_DIR}/${TEMP_FILE_1} && mv ${OUTPUT_DIR}/${TEMP_FILE_1} ${MODIFIED_DIR}/${fileName}
done

# ------ Create updated package  --------
for file in ${MODIFIED_DIR}/*.txt; do
    fileName=$(basename "$file")
    packageName=(${fileName//./ })
    cp "${file}" ${OUTPUT_DIR}/${TEMP_FILE}
    echo "Updating packge with page paths from file = ${fileName} and packageName = ${packageName}"
    processPackage $packageName
done
echo "END"
