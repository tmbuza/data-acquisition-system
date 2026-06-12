#!/usr/bin/env bash

set -euo pipefail

echo "Building download manifests..."

mkdir -p data/manifests

# Full manifest
cp \
  data/metadata/srr-accessions.txt \
  data/manifests/download-manifest.tsv

# Small test manifest
head -n 3 \
  data/metadata/srr-accessions.txt \
  > data/manifests/test-manifest.tsv

echo
echo "Manifest files created:"

echo "  data/manifests/download-manifest.tsv"
echo "  data/manifests/test-manifest.tsv"

echo
echo "Full manifest preview:"
head data/manifests/download-manifest.tsv

echo
echo "Full manifest count:"
wc -l data/manifests/download-manifest.tsv

echo
echo "Test manifest:"
cat data/manifests/test-manifest.tsv

echo
echo "Test manifest count:"
wc -l data/manifests/test-manifest.tsv

echo
echo "Recommended usage:"
echo "  test-manifest.tsv      -> workflow development and validation"
echo "  download-manifest.tsv  -> full dataset acquisition"
