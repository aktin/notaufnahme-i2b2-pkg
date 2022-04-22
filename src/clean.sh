#!/bin/bash
set -euo pipefail

# namely src/
readonly DIR_ROOT="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

rm -rf "${DIR_ROOT}/debian/build" "${DIR_ROOT}/docker/build"
