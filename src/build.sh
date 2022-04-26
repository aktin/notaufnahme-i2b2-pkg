#!/bin/bash
set -euo pipefail

readonly VERSION="${1:-}"
if [ -z "${VERSION}" ]; then echo "\$VERSION is empty."; exit 1; fi

# namely src/
readonly DIR_ROOT="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

function main() {
set -euo pipefail
. "${DIR_ROOT}/debian/build.sh" "${VERSION}"
. "${DIR_ROOT}/docker/build.sh" "${VERSION}" "full"
}

main
