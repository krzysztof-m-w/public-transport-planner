#!/usr/bin/env bash
# Converted to LF line endings
set -euo pipefail

OTP_VERSION="2.6.0"
OTP_JAR="otp-${OTP_VERSION}-shaded.jar"

DATA_DIR="data"
GTFS="${DATA_DIR}/gtfs.zip"
OSM="${DATA_DIR}/kujawsko-pomorskie-latest.osm.pbf"

mkdir -p "$DATA_DIR"

# If the JAR already exists but is invalid, remove it so we can re-download.
if [ -f "$OTP_JAR" ]; then
    if ! head -c 2 "$OTP_JAR" | od -An -tx1 | tr -d ' \t\n' | grep -q '^504b'; then
        echo "Existing $OTP_JAR appears invalid; removing and re-downloading."
        rm -f "$OTP_JAR"
    fi
fi

# Download OpenTripPlanner if needed
if [ ! -f "$OTP_JAR" ]; then
    echo "Downloading OpenTripPlanner ${OTP_VERSION}..."
    curl -L \
        -o "$OTP_JAR" \
        "https://repo1.maven.org/maven2/org/opentripplanner/otp/${OTP_VERSION}/${OTP_JAR}"
fi

# Check for GTFS
if [ ! -f "$GTFS" ]; then
    echo "Missing GTFS archive:"
    echo "  $GTFS"
    echo
    echo "Place your GTFS ZIP there and rerun."
    exit 1
fi

# Download OSM extract for Kujawsko-Pomorskie
if [ ! -f "$OSM" ]; then
    echo "Downloading OSM data for Kujawsko-Pomorskie..."
    curl -L \
        -o "$OSM" \
        "https://download.geofabrik.de/europe/poland/kujawsko-pomorskie-latest.osm.pbf"
fi

if [ ! -f "data/graph.obj" ]; then
    echo "Graph not found; building..."
    java -Xmx2G -jar "$OTP_JAR" --build "$DATA_DIR" --save
fi

echo "Starting OTP..."
java -Xmx2G -jar "$OTP_JAR" --load "$DATA_DIR"