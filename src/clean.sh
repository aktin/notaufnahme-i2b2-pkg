#!/bin/bash
set -euo pipefail

# namely src/
readonly ROOT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

rm -rf "${ROOT_DIR}/debian/build" "${ROOT_DIR}/docker/build"
