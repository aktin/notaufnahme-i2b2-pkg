#!/bin/bash
set -euo pipefail

# Required parameter
VERSION="${1}"

# Check if variables are empty
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi

. debian/build.sh "$VERSION"
. docker/build.sh "$VERSION" "full"
