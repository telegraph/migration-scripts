#!/bin/bash
# Passwords are dummy passwords.

# -------- CONFIG --------
INPUT_FILE="./input/input-urls-p1.txt"
OUTPUT_FILE="./output/a3-migrated-p1"
PACKAGE_NAME="a3-migrated-p1-26-11-2021"
CHUNKS=950
USERNAME="telegraph"
PASSWORD="<PASSWORD>"
PROTOCOL="http://"
HOST="10.38.10.9"
PORT="4503"
DELETE_MODE="false"
SINGLE_PACKAGE_MODE="false"
TEMP_FILE="tmp.txt"
LOG_FILE="info.log"
# -------- CONFIG --------



# FUNCTIONS
deleteFile () {
	if [ -f "${1}" ]; then
		rm -rf "${1}"
	fi
}

getFilters () {
	filter=""
	while read line
	do
		if [ ! -z "$line" ]; then
			echo "${2} : ${line}" >> "${OUTPUT_FILE}/${LOG_FILE}"
	    	filter="${filter} {\"root\" : \"${line}\", \"rules\": []}, "
	    fi
	done < "${1}"
	echo "${filter:0:${#filter}-2}"	
}

checkPackageStatus() {
  packageExist="true"
  packageCheck=$(curl -u "${USERNAME}":"${PASSWORD}" -s -I -w %{http_code} "${PROTOCOL}${HOST}:${PORT}/etc/packages/my_packages/${packageName}.zip")
  if [[ $packageCheck =~ "404 Not Found" ]]; then
    packageExist="false"
  else
    packageInstallationCheck=$(curl -u "${USERNAME}":"${PASSWORD}" "${PROTOCOL}${HOST}:${PORT}/etc/packages/my_packages/${packageName}.zip/jcr:content/vlt:definition.json" | grep 'lastUnpacked')
    if [ ! -z "$packageInstallationCheck" ]; then
      packageExist="true"
    else
      packageExist="false"
    fi
  fi
  echo "$packageExist"
}

processTmp () {
	
 	batchNumber="${1}"
	packageName="${PACKAGE_NAME}-${batchNumber}"
	packageExist=$(checkPackageStatus "$packageName")
  if [ "$packageExist" = "false" ]; then
    printf "'${packageName}.zip' package does not exist in the host ${HOST}, so uploading... \n"

    if [ "${DELETE_MODE}" = "true" ]; then
		printf "Trying to delete the package ${packageName} in the ${HOST} \n"
        curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip?cmd=delete"
        deleteFile "${OUTPUT_FILE}/${packageName}.zip"
        deleteFile "${OUTPUT_FILE}/${LOG_FILE}"
        printf "\n"
    else
      echo "---- START - processing batch $batchNumber of $CHUNKS rows ----- in the host ${HOST}"

          cp "${OUTPUT_FILE}/tmp.txt" "${OUTPUT_FILE}/${packageName}.txt"

          printf "${packageName} uploaded in the host ${HOST} \n"
      curl -u "${USERNAME}":"${PASSWORD}" -F file=@"${OUTPUT_FILE}/${packageName}".zip -F name="${packageName}" -F force=true -F install=false ${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service.jsp
      printf "\n"

          printf "${packageName} installed in the host ${HOST} \n"
      curl -u "${USERNAME}":"${PASSWORD}" -F file=@"${OUTPUT_FILE}/${packageName}".zip -F name="${packageName}" -F force=true -F install=true ${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service.jsp
      printf "\n"

      echo "---- END - processing batch $batchNumber of $CHUNKS rows ----- in the host ${HOST}"
    fi
  else
    echo "'${packageName}.zip' package already installed in the host ${HOST}, so SKIPPING the package"
	fi

	deleteFile "${OUTPUT_FILE}/${TEMP_FILE}"
}

# ------ MAIN --------
deleteFile "${OUTPUT_FILE}/${TEMP_FILE}"
deleteFile "${OUTPUT_FILE}/${LOG_FILE}"
counter=0  
batchNumber=1
while read line
do
    if [ "${CHUNKS}" = "${counter}" ];
	then 
    	processTmp $batchNumber
    	let counter=0
    	let batchNumber++
    	if [ "${SINGLE_PACKAGE_MODE}" = "true" ]; then
    		exit 0
    	fi
	fi;
    echo "${line}" >> "${OUTPUT_FILE}/${TEMP_FILE}"
    let counter++
done < ${INPUT_FILE}

if [ $counter != 0 ];
then 
	processTmp $batchNumber
	deleteFile "${OUTPUT_FILE}/${TEMP_FILE}"
fi;
echo "END"


