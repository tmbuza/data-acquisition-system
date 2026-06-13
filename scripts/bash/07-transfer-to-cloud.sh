#!/usr/bin/env bash

set -euo pipefail

LOCAL_DIR="${1:-data}"
S3_BUCKET="${2:?Usage: bash 07a-transfer-to-s3.sh <local_dir> <s3_bucket> [sync|cp]}"
MODE="${3:-sync}"

LOG_FILE="data/logs/s3-transfer.log"

mkdir -p data/logs

exec > >(tee -a "${LOG_FILE}")
exec 2>&1

echo "Starting cloud transfer..."
echo "Local directory: ${LOCAL_DIR}"
echo "S3 bucket: ${S3_BUCKET}"
echo "Mode: ${MODE}"

echo

if [[ "${MODE}" == "sync" ]]
then

    aws s3 sync \
      "${LOCAL_DIR}" \
      "s3://${S3_BUCKET}/"

elif [[ "${MODE}" == "cp" ]]
then

    aws s3 cp \
      "${LOCAL_DIR}" \
      "s3://${S3_BUCKET}/" \
      --recursive

else

    echo "Invalid mode: ${MODE}"
    echo "Supported modes: sync | cp"
    exit 1

fi

echo
echo "Verifying destination..."

aws s3 ls \
  "s3://${S3_BUCKET}/"

echo
echo "Cloud transfer complete."