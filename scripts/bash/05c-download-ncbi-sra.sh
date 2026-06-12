#!/usr/bin/env bash

set -euo pipefail

# Default to the test manifest.
# Optionally supply a different manifest as the first argument.
MANIFEST="${1:-data/manifests/test-manifest.tsv}"

mkdir -p data/raw/sra
mkdir -p data/raw/ncbi
mkdir -p data/logs

echo "Using manifest:"
echo "  ${MANIFEST}"

echo
echo "Downloading SRA files..."

while read -r run; do

  echo
  echo "Downloading ${run}"

  prefetch "${run}" \
    --output-directory data/raw/sra

done < "${MANIFEST}" \
2>&1 | tee data/logs/download-ncbi.log

echo
echo "Converting SRA to FASTQ..."

while read -r run; do

  echo
  echo "Converting ${run}"

  fasterq-dump \
    "data/raw/sra/${run}/${run}.sra" \
    --outdir data/raw/ncbi \
    --threads 4

done < "${MANIFEST}" \
2>&1 | tee -a data/logs/download-ncbi.log

echo
echo "Compressing FASTQ files..."

gzip -f data/raw/ncbi/*.fastq

echo
echo "Downloaded files:"
find data/raw/ncbi -name "*.fastq.gz" | sort

echo
echo "NCBI test download complete."