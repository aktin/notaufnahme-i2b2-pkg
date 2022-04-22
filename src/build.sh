#!/bin/bash
set -euo pipefail

# Required parameter
VERSION="${1}"
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi

# namely src/
ROOT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

. $ROOT_DIR/debian/build.sh "$VERSION"
. $ROOT_DIR/docker/build.sh "$VERSION" "full"
