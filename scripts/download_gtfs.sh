#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="data"
GTFS="${DATA_DIR}/gtfs.zip"

mkdir -p "$DATA_DIR"

echo "Downloading latest official Bydgoszcz GTFS..."

curl -L \
  -o "$GTFS" \
  "https://zdmikp.bydgoszcz.pl/rozklady/paczka/gtfs/gtfs.zip"

echo "Saved to $GTFS"