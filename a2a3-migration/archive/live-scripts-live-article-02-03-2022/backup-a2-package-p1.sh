#!/bin/bash
# Passwords are dummy passwords.

# -------- CONFIG --------
TODAYS_DATE=$(date +"%d-%m-%Y")
INPUT_FILE="./input/input-urls-p1.txt"
OUTPUT_FILE="./output/a2-backup-p1"
PACKAGE_NAME="a2-backup-live-article-p1-$TODAYS_DATE"
CHUNKS=950
USERNAME="<USERNAME>"
PASSWORD="<PASSWORD>"
HOST="<HOST>"
PROTOCOL="http://"
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

processTmp () {
	
 	batchNumber="${1}"
	packageName="${PACKAGE_NAME}-${batchNumber}"
	
	if [ "${DELETE_MODE}" = "true" ]; then
		printf "Trying to delete the package ${packageName} in host ${HOST} \n"
	    curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip?cmd=delete"
	    deleteFile "${OUTPUT_FILE}/${packageName}.zip"
	    deleteFile "${OUTPUT_FILE}/${LOG_FILE}"
	    printf "\n"
	else
		echo "---- START - processing batch $batchNumber of $CHUNKS rows ----- in host ${HOST}"

        cp "${OUTPUT_FILE}/tmp.txt" "${OUTPUT_FILE}/${packageName}.txt"
        
        filters=$(getFilters "${OUTPUT_FILE}/tmp.txt" "${packageName}")

		printf "${packageName} created in host ${HOST} \n"
		curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/my_packages/${PACKAGE_NAME}?cmd=create" -d packageName="${packageName}" -d groupName=my_packages
		printf "\n"

		printf "${packageName} filters \n"
		curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/update.jsp" -F path="/etc/packages/my_packages/${packageName}".zip -F packageName="${packageName}" -F groupName=my_packages -F filter="[${filters}]" -F '_charset_=UTF-8'
		printf "\n"

		printf "${packageName} build in host ${HOST} \n"
		curl -u "${USERNAME}":"${PASSWORD}" -X POST "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip?cmd=build"
		printf "\n"

		printf "${packageName} downloaded from host ${HOST} to ${OUTPUT_FILE} \n"
		curl -s -o "${OUTPUT_FILE}/${packageName}.zip" -u "${USERNAME}":"${PASSWORD}" "${PROTOCOL}${HOST}:${PORT}/crx/packmgr/download.jsp?_charset_=utf-8&path=/etc/packages/my_packages/${packageName}.zip"
		printf "\n"

		echo "---- END - processing batch $batchNumber of $CHUNKS rows ----- in host ${HOST}"
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