#!/usr/bin/env bash

set -euo pipefail

ENA_METADATA="data/metadata/ena-prjna477349.tsv"

TEST_MANIFEST="data/manifests/test-manifest.tsv"

PRODUCTION_URLS="data/manifests/ena-fastq-urls.txt"
TEST_URLS="data/manifests/ena-fastq-test-urls.txt"

mkdir -p data/raw/ena
mkdir -p data/manifests
mkdir -p data/logs

echo "Extracting production FASTQ URLs..."

awk -F '\t' '
NR==1 {
  for (i=1; i<=NF; i++) {
    if ($i=="fastq_ftp") col=i
  }
}
NR>1 && col>0 && $col!="" {
  n=split($col, urls, ";")
  for (j=1; j<=n; j++)
    print "https://" urls[j]
}
' "${ENA_METADATA}" \
> "${PRODUCTION_URLS}"

echo
echo "Production URL count:"
wc -l "${PRODUCTION_URLS}"

echo
echo "Building ENA test URL list from test-manifest.tsv..."

awk '{ print $1 }' "${TEST_MANIFEST}" \
| while read -r RUN
do
    grep "${RUN}" "${PRODUCTION_URLS}"
done \
> "${TEST_URLS}"

echo
echo "Test URL count:"
wc -l "${TEST_URLS}"

echo
echo "Test runs:"
cat "${TEST_MANIFEST}"

echo
echo "Preview:"
cat "${TEST_URLS}"

echo
echo "Starting test download..."

echo
echo "Starting ENA test download..."

wget \
  --continue \
  --directory-prefix data/raw/ena \
  --input-file "${TEST_URLS}" \
  2>&1 | tee data/logs/download-ena.log

echo
echo "Downloaded files:"
find data/raw/ena -name "*.fastq.gz" | sort

echo
echo "ENA test download complete."