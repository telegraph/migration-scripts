#!/bin/bash
# Passwords are dummy passwords.

# -------- CONFIG --------
INPUT_FILE="./input/affiliate-long-disclaimer.txt"
# INPUT_FILE="./input/affiliate-short-disclaimer.txt"
# INPUT_FILE="./input/travel-disclaimer.txt"
OUTPUT_FILE="./output"
PACKAGE_NAME="affiliate-long-disclaimer$TODAYS_DATE"
# PACKAGE_NAME="affiliate-short-disclaimer$TODAYS_DATE"
# PACKAGE_NAME="travel-disclaimer$TODAYS_DATE"
CHUNKS=20
USERNAME="jenkins"
PASSWORD="xxxx"
BASE_URL="https://author-p3505-e359555.adobeaemcloud.com/"
DELETE_MODE="false"
SINGLE_PACKAGE_MODE="false"
TEMP_FILE="tmp.txt"
LOG_FILE="info.log"
# -------- CONFIG --------

while [[ $# -gt 0 ]]; do
  case $1 in
    -p|--password)
      PASSWORD="$2"
      shift # past argument
      shift # past value
      ;;
    -u|--user)
      USERNAME="$2"
      shift # past argument
      shift # past value
      ;;
    -b|--baseurl)
      BASE_URL="$2"
      shift # past argument
      shift # past value
      ;;
    -k|--package)
      PACKAGE_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -c|--chunks)
      CHUNKS="$2"
      shift # past argument
      shift # past value
      ;;
    -d|--delete)
      DELETE_MODE="true"
      shift # past argument
      ;;    
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

mkdir -p ${OUTPUT_FILE}

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
		printf "Trying to delete the package ${packageName} \n"
	    curl -u "${USERNAME}":"${PASSWORD}" -X POST "${BASE_URL}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip?cmd=delete"
	    printf "\n"
	else
		echo "---- START - processing batch $batchNumber of $CHUNKS rows -----"

        cp "${OUTPUT_FILE}/tmp.txt" "${OUTPUT_FILE}/${packageName}.txt"
        
        filters=$(getFilters "${OUTPUT_FILE}/tmp.txt" "${packageName}")

		printf "${packageName} created\n"
		curl -u "${USERNAME}":"${PASSWORD}" -X POST "${BASE_URL}/crx/packmgr/service/.json/etc/packages/my_packages/${PACKAGE_NAME}?cmd=create" -d packageName="${packageName}" -d groupName=my_packages
		printf "\n"

		sleep 5

		printf "${packageName} filters \n"
		curl -u "${USERNAME}":"${PASSWORD}" -X POST "${BASE_URL}/crx/packmgr/update.jsp" -F path="/etc/packages/my_packages/${packageName}".zip -F packageName="${packageName}" -F groupName=my_packages -F filter="[${filters}]" -F '_charset_=UTF-8'
		printf "\n"

		printf "${packageName} build\n"
		curl -u "${USERNAME}":"${PASSWORD}" -X POST "${BASE_URL}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip?cmd=build"
		printf "\n"

		printf "${packageName} downloaded\n"
		curl -s -o "${OUTPUT_FILE}/${packageName}.zip" -u "${USERNAME}":"${PASSWORD}" "${BASE_URL}/crx/packmgr/download.jsp?_charset_=utf-8&path=/etc/packages/my_packages/${packageName}.zip"
		printf "\n"

		echo "---- END - processing batch $batchNumber of $CHUNKS rows -----"
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