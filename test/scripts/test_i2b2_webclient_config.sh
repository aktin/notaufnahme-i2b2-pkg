#! /bin/bash
set -euo pipefail

readonly WHI="\e[0m"
readonly RED="\e[0;31m"
readonly GRE="\e[0;32m"

if [[ -z $(cat /var/www/html/webclient/i2b2_config_data.js | grep "name" | grep "AKTIN") ]]; then
    echo -e "${RED} - name is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(cat /var/www/html/webclient/i2b2_config_data.js | grep "urlCellPM" | grep "http://127.0.0.1:9090/i2b2/services/PMService/") ]]; then
    echo -e "${RED} - urlCellPM is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(cat /var/www/html/webclient/js-i2b2/i2b2_ui_config.js | grep "loginDefaultUsername" | grep "\"\"") ]]; then
    echo -e "${RED} - default username is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(cat /var/www/html/webclient/js-i2b2/i2b2_ui_config.js | grep "loginDefaultPassword" | grep "\"\"") ]]; then
    echo -e "${RED} - default username is not set correctly${WHI}"
    exit 1
fi

echo -e "${GRE} - i2b2 webclient config is set accordingly${WHI}"
