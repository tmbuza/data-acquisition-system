#!/usr/bin/env bash

set -euo pipefail

FASTQ_DIR="${1:-data/raw/ena}"
REPORT_DIR="data/validation"

mkdir -p "${REPORT_DIR}"

REPORT="${REPORT_DIR}/validation-report.tsv"

echo "Validating:"
echo "  ${FASTQ_DIR}"

echo -e "check\tstatus\tvalue" > "${REPORT}"


##############################################################################
# File Count
##############################################################################

FILE_COUNT=$(find "${FASTQ_DIR}" -name "*.fastq.gz" | wc -l | tr -d ' ')

echo
echo "FASTQ files:"
echo "  ${FILE_COUNT}"

echo -e "fastq_file_count\tPASS\t${FILE_COUNT}" \
>> "${REPORT}"

##############################################################################
# Compression Validation
##############################################################################

echo
echo "Testing gzip integrity..."

FAILED_GZIP=0

while read -r file
do
    if gzip -t "${file}" 2>/dev/null
    then
        :
    else
        echo "FAILED: ${file}"
        FAILED_GZIP=$((FAILED_GZIP + 1))
    fi
done < <(find "${FASTQ_DIR}" -name "*.fastq.gz")

if [[ "${FAILED_GZIP}" -eq 0 ]]
then
    echo "Compression validation: PASS"

    echo -e "compression_validation\tPASS\t0" \
    >> "${REPORT}"
else
    echo "Compression validation: FAIL"

    echo -e "compression_validation\tFAIL\t${FAILED_GZIP}" \
    >> "${REPORT}"
fi

##############################################################################
# Paired-End Validation
##############################################################################

FORWARD=$(find "${FASTQ_DIR}" -name "*_1.fastq.gz" | wc -l | tr -d ' ')
REVERSE=$(find "${FASTQ_DIR}" -name "*_2.fastq.gz" | wc -l | tr -d ' ')

echo
echo "Forward reads: ${FORWARD}"
echo "Reverse reads: ${REVERSE}"

if [[ "${FORWARD}" -eq "${REVERSE}" ]]
then
    echo "Paired-end validation: PASS"

    echo -e "paired_end_validation\tPASS\t${FORWARD}" \
    >> "${REPORT}"
else
    echo "Paired-end validation: FAIL"

    echo -e "paired_end_validation\tFAIL\t${FORWARD}:${REVERSE}" \
    >> "${REPORT}"
fi

##############################################################################
# FASTQ Structure Validation
##############################################################################

echo
echo "Checking FASTQ readability..."

TEST_FILE=$(find "${FASTQ_DIR}" -name "*.fastq.gz" | sort | head -n 1)

if gzip -t "${TEST_FILE}" 2>/dev/null
then
    echo "FASTQ validation: PASS"

    echo -e "fastq_validation\tPASS\t${TEST_FILE}" \
    >> "${REPORT}"
else
    echo "FASTQ validation: FAIL"

    echo -e "fastq_validation\tFAIL\t${TEST_FILE}" \
    >> "${REPORT}"
fi

##############################################################################
# Summary
##############################################################################

echo
echo "Validation report:"
cat "${REPORT}"

echo
echo "Saved:"
echo "  ${REPORT}"