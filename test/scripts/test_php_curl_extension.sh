#! /bin/bash
set -euo pipefail

readonly WHI="\e[0m"
readonly RED="\e[0;31m"
readonly GRE="\e[0;32m"

if [[ -n $(grep "extension=curl" /etc/php/*/apache2/php.ini) ]]; then
    echo -e "${GRE} - php curl is enabled${WHI}"
else
    echo -e "${RED} - php curl is disabled${WHI}"
    exit 1
fi
