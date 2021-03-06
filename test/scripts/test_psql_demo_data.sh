#! /bin/bash
set -euo pipefail

readonly WHI="\e[0m"
readonly YEL="\e[1;33m"
readonly RED="\e[0;31m"
readonly GRE="\e[0;32m"

if ! systemctl is-active --quiet postgresql; then
    systemctl start postgresql
    sleep 5s
fi

# assuming the folder "test" is located in the working dir of Docker
echo -e "${YEL} - importing data${WHI}"
sudo -u postgres psql -d i2b2 -v ON_ERROR_STOP=1 -f "test/resources/sql/i2b2_demographics_demo.sql" >/dev/null

COUNT=$(sudo -u postgres psql -d i2b2 -c "SELECT COUNT(*) FROM i2b2crcdata.observation_fact;" | grep -oP "[0-9]{3}")
if [[ "${COUNT}" == "933" ]]; then
    echo -e "${GRE} - row count matches${WHI}"
else
    echo -e "${RED} - invalid row count (${COUNT})${WHI}"
    exit 1
fi

COUNT=$(sudo -u postgres psql -d i2b2 -c "SELECT COUNT(DISTINCT patient_num) FROM i2b2crcdata.observation_fact;" | grep -oP "[0-9]{3}")
if [[ "${COUNT}" == "133" ]]; then
    echo -e "${GRE} - patient count matches${WHI}"
else
    echo -e "${RED} - invalid patient count (${COUNT})${WHI}"
    exit 1
fi

COUNT=$(sudo -u postgres psql -d i2b2 -c "SELECT COUNT(DISTINCT encounter_num) FROM i2b2crcdata.observation_fact;" | grep -oP "[0-9]{3}")
if [[ "${COUNT}" == "266" ]]; then
    echo -e "${GRE} - encounter count matches${WHI}"
else
    echo -e "${RED} - invalid encounter count (${COUNT})${WHI}"
    exit 1
fi
