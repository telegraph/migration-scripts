#!/bin/bash
# Passwords are dummy passwords.
# you'll have to add the packages to a folder output where the script it
# and update PACKAGE_NAME, START_PACKS,END_PACKS,PASSWORD, INSTALL

# -------- CONFIG --------
INPUT_FILE="./input/affiliate-long-disclaimer.txt"
# INPUT_FILE="./input/affiliate-short-disclaimer.txt"
# INPUT_FILE="./input/travel-disclaimer.txt"
OUTPUT_FILE="./output"
PACKAGE_NAME="affiliate-long-disclaimer$TODAYS_DATE"
# PACKAGE_NAME="affiliate-short-disclaimer$TODAYS_DATE"
# PACKAGE_NAME="travel-disclaimer$TODAYS_DATE"
START_PACKS=1
END_PACKS=1
USERNAME="jenkins"
PASSWORD="xxxx"
BASE_URL="https://author-p3505-e359555.adobeaemcloud.com/"
DELETE_MODE="false"
SINGLE_PACKAGE_MODE="false"
TEMP_FILE="tmp.txt"
LOG_FILE="info.log"
REPLICATE=false
INSTALL=true
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
    -i|--inputfile)
      INPUT_FILE="$2"
      shift # past argument
      shift # past value
      ;;
    -k|--package)
      PACKAGE_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -o|--outputfile)
      OUTPUT_FILE="$2"
      shift # past argument
      shift # past value
      ;;
    -c|--chunks)
      CHUNKS="$2"
      shift # past argument
      shift # past value
      ;;
    -r|--replicate)
      REPLICATE=true
      shift # past argument
      ;;
    -j|--install)
      INSTALL=true
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
	    deleteFile "${OUTPUT_FILE}/${packageName}.zip"
	    deleteFile "${OUTPUT_FILE}/${LOG_FILE}"
	    printf "\n"
	else
		echo "---- START - processing batch $batchNumber of $CHUNKS rows -----"

        #p "${OUTPUT_FILE}/tmp.txt" "${OUTPUT_FILE}/${packageName}.txt"
        
    printf "${packageName} uploading\n"
		curl -u "${USERNAME}":"${PASSWORD}" -F file=@"${OUTPUT_FILE}/${packageName}".zip -F name="${packageName}" -F force=true -F install=false ${BASE_URL}/crx/packmgr/service.jsp
		printf "\n"

    
    if [ "$REPLICATE" = true ]; then
      sleep 5
      printf "${packageName} replicating\n"
      curl -u "${USERNAME}":"${PASSWORD}" -F cmd=replicate ${BASE_URL}/crx/packmgr/service/.json/etc/packages/my_packages/${packageName}.zip
      printf "\n"
    fi
    if [ "$INSTALL" = true ]; then
      sleep 5
      printf "${packageName} installing\n"
      curl -u "${USERNAME}":"${PASSWORD}" -F file=@"${OUTPUT_FILE}/${packageName}".zip -F name="${packageName}" -F force=true -F install=true ${BASE_URL}/crx/packmgr/service.jsp
      printf "\n"
    fi

		echo "---- END - processing batch $batchNumber of $CHUNKS rows -----"
	fi

	#deleteFile "${OUTPUT_FILE}/${TEMP_FILE}"
}

# ------ MAIN --------
deleteFile "${OUTPUT_FILE}/${TEMP_FILE}"
deleteFile "${OUTPUT_FILE}/${LOG_FILE}"
counter=0  
batchNumber=7

for i in $(seq $START_PACKS $END_PACKS)
do
  echo "$i"
    processTmp $i
    #deleteFile "${OUTPUT_FILE}/${TEMP_FILE}"
done
echo "END"


