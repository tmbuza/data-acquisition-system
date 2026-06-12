#!/usr/bin/env bash

set -euo pipefail

echo "Verifying downloads..."

echo
echo "FASTQ file count:"
find data/raw/fastq \
  -type f \
  \( \
  -name "*.fastq" -o \
  -name "*.fastq.gz" -o \
  -name "*.fq" -o \
  -name "*.fq.gz" \
  \) | wc -l

echo
echo "First files:"
find data/raw/fastq -type f | head

echo
echo "File sizes:"
find data/raw/fastq \
  -type f \
  -exec ls -lh {} \; | head

echo
echo "SeqKit summary:"
seqkit stats data/raw/fastq/*

echo
echo "Verification complete."
