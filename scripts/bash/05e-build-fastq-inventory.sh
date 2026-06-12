#!/usr/bin/env bash

set -euo pipefail

mkdir -p data/inventory

echo "Building FASTQ inventory..."

printf "file\tsize_bytes\n" \
> data/inventory/fastq-inventory.tsv

if [[ "$OSTYPE" == "darwin"* ]]; then

  find data/raw/fastq \
    -type f \
    \( \
    -name "*.fastq" -o \
    -name "*.fastq.gz" -o \
    -name "*.fq" -o \
    -name "*.fq.gz" \
    \) \
    -exec stat -f "%N|%z" {} \; \
    | sed 's/|/\t/' \
    >> data/inventory/fastq-inventory.tsv

else

  find data/raw/fastq \
    -type f \
    \( \
    -name "*.fastq" -o \
    -name "*.fastq.gz" -o \
    -name "*.fq" -o \
    -name "*.fq.gz" \
    \) \
    -exec stat -c "%n|%s" {} \; \
    | sed 's/|/\t/' \
    >> data/inventory/fastq-inventory.tsv

fi

echo
echo "Inventory created:"
echo "  data/inventory/fastq-inventory.tsv"

echo
echo "Preview:"
head data/inventory/fastq-inventory.tsv

echo
echo "Total records:"
wc -l data/inventory/fastq-inventory.tsv