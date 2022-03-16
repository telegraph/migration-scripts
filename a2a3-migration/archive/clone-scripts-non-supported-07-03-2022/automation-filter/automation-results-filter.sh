#!/bin/bash
# Filtering automation results

ORIG_RESULTS_FILE="result_1629369734813.txt"
REMOVE_LINE_Byline="Byline"
REMOVE_LINE_IS_NOT_A2="is not A2"
REMOVE_LINE_Headline_is_different="Headline is different"
LIST_PAGE_ListOfTags="ListOfTags"
LIST_PAGE_ArticleBodyImage="ArticleBodyImage"
LIST_PAGE_LeadAsset="LeadAsset"
LIST_PAGE_ARTICLE_TYPE="article type is different"
OUTPUT_DIR="output"
RESULTS_FILE="${OUTPUT_DIR}/${ORIG_RESULTS_FILE}_modified.txt"

rm ${OUTPUT_DIR}/*.*
rm image_corruptions.txt ListOfTags.txt tmp.txt article_type.txt
cp ${ORIG_RESULTS_FILE} ${RESULTS_FILE}

#awk '{ "!/'${REMOVE_LINE_Byline}'/" }' ${RESULTS_FILE} > tmp.txt && mv tmp.txt ${RESULTS_FILE}
grep -v "${REMOVE_LINE_IS_NOT_A2}" ${RESULTS_FILE} > tmp.txt && mv tmp.txt ${RESULTS_FILE}
echo "Removed lines which has ${REMOVE_LINE_IS_NOT_A2} from ${RESULTS_FILE}"
grep -v "${REMOVE_LINE_Byline}" ${RESULTS_FILE} > tmp.txt && mv tmp.txt ${RESULTS_FILE}
echo "Removed lines which has ${REMOVE_LINE_Byline} from ${RESULTS_FILE}"

grep ${LIST_PAGE_ListOfTags} ${RESULTS_FILE} | awk -F $'\t' '{print $6}' | cut -c24- > ${LIST_PAGE_ListOfTags}.txt
grep -v "${LIST_PAGE_ListOfTags}" ${RESULTS_FILE} > tmp.txt && mv tmp.txt ${RESULTS_FILE}
echo "Removed lines which has ${LIST_PAGE_ListOfTags} from ${RESULTS_FILE}"

grep -w ${LIST_PAGE_ARTICLE_TYPE} ${RESULTS_FILE} | awk -F $'\t' '{print $6}' | cut -c24- > article_type.txt
grep -v "${LIST_PAGE_ARTICLE_TYPE}" ${RESULTS_FILE} > tmp.txt && mv tmp.txt ${RESULTS_FILE}
echo "Removed lines which has ${LIST_PAGE_ARTICLE_TYPE} from ${RESULTS_FILE}"

grep ${LIST_PAGE_ArticleBodyImage} ${RESULTS_FILE} | awk -F $'\t' '{print $6}' | cut -c24- > ${OUTPUT_DIR}/${LIST_PAGE_ArticleBodyImage}.txt
grep -v "${LIST_PAGE_ArticleBodyImage}" ${RESULTS_FILE} > tmp.txt && mv tmp.txt ${RESULTS_FILE}
echo "Removed lines which has ${LIST_PAGE_ArticleBodyImage} from ${RESULTS_FILE}"

grep ${LIST_PAGE_LeadAsset} ${RESULTS_FILE} | awk -F $'\t' '{print $6}' | cut -c24- > ${OUTPUT_DIR}/${LIST_PAGE_LeadAsset}.txt
grep -v "${LIST_PAGE_LeadAsset}" ${RESULTS_FILE} > tmp.txt && mv tmp.txt ${RESULTS_FILE}
echo "Removed lines which has ${LIST_PAGE_LeadAsset} from ${RESULTS_FILE}"

cat ${OUTPUT_DIR}/${LIST_PAGE_LeadAsset}.txt ${OUTPUT_DIR}/${LIST_PAGE_ArticleBodyImage}.txt > image_corruptions.txt
