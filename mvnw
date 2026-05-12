#!/bin/sh
# Maven wrapper script for Unix/Linux/macOS
# Downloads Maven 3.9.x automatically on first run — no local install needed.

set -e

MAVEN_PROJECTBASEDIR="${MAVEN_BASEDIR:-$(pwd)}"
MAVEN_WRAPPER_PROPERTIES="$MAVEN_PROJECTBASEDIR/.mvn/wrapper/maven-wrapper.properties"

# Parse distributionUrl from properties
DISTRIBUTION_URL=$(grep "^distributionUrl" "$MAVEN_WRAPPER_PROPERTIES" | cut -d'=' -f2)

# Resolve cache directory
USER_HOME="${MAVEN_USER_HOME:-$HOME/.m2/wrapper}"
MAVEN_ZIP_NAME=$(basename "$DISTRIBUTION_URL")
MAVEN_HOME="$USER_HOME/dists/${MAVEN_ZIP_NAME%.zip}"

# Download and unpack if not already cached
if [ ! -d "$MAVEN_HOME" ]; then
    mkdir -p "$USER_HOME/dists"
    echo "Downloading Maven: $DISTRIBUTION_URL"
    if command -v curl > /dev/null 2>&1; then
        curl -fsSL -o "$USER_HOME/dists/$MAVEN_ZIP_NAME" "$DISTRIBUTION_URL"
    elif command -v wget > /dev/null 2>&1; then
        wget -q -O "$USER_HOME/dists/$MAVEN_ZIP_NAME" "$DISTRIBUTION_URL"
    else
        echo "ERROR: curl or wget is required." >&2; exit 1
    fi
    unzip -q "$USER_HOME/dists/$MAVEN_ZIP_NAME" -d "$USER_HOME/dists"
fi

exec "$MAVEN_HOME/bin/mvn" "$@"
