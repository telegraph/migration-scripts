#!/bin/bash
# Gets the modified pages file and deleted those pages from the pages paths file and re-create and build the package in the HOST
# Passwords are dummy passwords.

# -------- CONFIG --------
SPONSORED_DIR="./sponsored/pub"
PACKAGES_DIR="./output/sponsored/pub"
SPONSORED_PAGES="./input/sponsored_pages.txt"


USERNAME="admin"
PASSWORD="Telegraphpreprod!"
HOST="pub.aem-qa11.platforms-preprod-gcp.telegraph.co.uk"
PORT="4503"
PROTOCOL="http://"

OUTPUT_DIR="${SPONSORED_DIR}/output"
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
  #filters=$(getFilters "${OUTPUT_DIR}/tmp.txt" "${packageName}")
  #printf "${packageName} filters \n"

  cp "${OUTPUT_DIR}/tmp.txt" "${OUTPUT_DIR}/${packageName}.txt"


  printf "${SPONSORED_DIR}/${packageName} uploaded to the host ${HOST} \n"
  #printf "curl -u "${USERNAME}":"${PASSWORD}" -s -I -w %{http_code} -F file=@"${SPONSORED_DIR}/${packageName}".zip -F name="${packageName}" -F force=true -F install=false ${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service.jsp"
  curl -u "${USERNAME}":"${PASSWORD}" -F file=@"${SPONSORED_DIR}/${packageName}".zip -F name="${packageName}" -F force=true -F install=false ${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service.jsp
  printf "\n"

  printf "${SPONSORED_DIR}/${packageName} installed in the host ${HOST} \n"
  printf "curl -u "${USERNAME}":"${PASSWORD}" -F file=@"${SPONSORED_DIR}/${packageName}".zip -F name="${packageName}" -F force=true -F install=true ${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service.jsp"
		curl -u "${USERNAME}":"${PASSWORD}" -F file=@"${SPONSORED_DIR}/${packageName}".zip -F name="${packageName}" -F force=true -F install=true ${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service.jsp
		printf "\n"

  echo "---- END - processing batch $batchNumber of $CHUNKS rows ----- in host ${HOST}"
  deleteFile "${OUTPUT_DIR}/${TEMP_FILE}"

}

# ------ MAIN --------
: '
echo "---- BEGIN - processing packages ---- in host ${HOST}"
rm -rf ${SPONSORED_DIR} ${OUTPUT_DIR}
mkdir ${SPONSORED_DIR}
mkdir ${OUTPUT_DIR}
echo "grep -x -l -F -f ${SPONSORED_PAGES} ${PACKAGES_DIR}/*.txt | sort --unique"
packages=$(grep -x -l -F -f ${SPONSORED_PAGES} ${PACKAGES_DIR}/*.txt | sort --unique)
length="${packages[@]}"
echo "Following packages are modified: in  ${PACKAGES_DIR} from the file ${SPONSORED_PAGES}"
printf "${packages} \n"

# ------ Copy files  --------
echo "Copying files to ${SPONSORED_DIR}  dir"
for p in ${length}; do
  file=(${p//// })
  fileName=${file[3]}
  actualfileName=$(basename "$p")
  fileNameWithourExtension=$(echo "$actualfileName" | cut -f 1 -d '.')
  cp "./${p}" ${SPONSORED_DIR}
  cp "${PACKAGES_DIR}/${fileNameWithourExtension}.zip" ${SPONSORED_DIR}
  echo " ${p} copied to ${SPONSORED_DIR}  and file =${file}, fileName =${fileName}, actualfileName = ${actualfileName} and fileNameWithourExtension = ${fileNameWithourExtension} "
  echo "grep -v -f ${SPONSORED_PAGES} ${SPONSORED_DIR}/${fileName} >${OUTPUT_DIR}/${TEMP_FILE_1} && mv ${OUTPUT_DIR}/${TEMP_FILE_1} ${SPONSORED_DIR}/${fileName}"
  grep -v -f ${SPONSORED_PAGES} ${SPONSORED_DIR}/${fileName} >${OUTPUT_DIR}/${TEMP_FILE_1} && mv ${OUTPUT_DIR}/${TEMP_FILE_1} ${SPONSORED_DIR}/${fileName}
done
'

# ------ Create updated package  --------
for file in ${SPONSORED_DIR}/*.zip; do
    fileName=$(basename "$file")
    packageName=(${fileName//./ })
    cp "${file}" ${OUTPUT_DIR}/${TEMP_FILE}
    echo "Updating packge with page paths from file = ${fileName} and packageName = ${packageName}"
    processPackage $packageName
done
rm -rf ${OUTPUT_DIR}
echo "END"
