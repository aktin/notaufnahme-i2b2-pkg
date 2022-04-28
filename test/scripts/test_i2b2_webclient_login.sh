#! /bin/bash
set -euo pipefail

readonly WHI="\e[0m"
readonly RED="\e[0;31m"
readonly GRE="\e[0;32m"

# destination for i2b2 testing
readonly URL="http://localhost:80/webclient/index.php"

function create_i2b2_webclient_login_request() {
    local USERNAME="${1:-}"

    echo "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><i2b2:request xmlns:i2b2=\"http://www.i2b2.org/xsd/hive/msg/1.1/\" xmlns:pm=\"http://www.i2b2.org/xsd/cell/pm/1.1/\"><message_header><proxy><redirect_url>http://127.0.0.1:9090/i2b2/services/PMService/getServices</redirect_url></proxy><i2b2_version_compatible>1.1</i2b2_version_compatible><hl7_version_compatible>2.4</hl7_version_compatible><sending_application><application_name>i2b2 Project Management</application_name><application_version>1.6</application_version></sending_application><sending_facility><facility_name>i2b2 Hive</facility_name></sending_facility><receiving_application><application_name>Project Management Cell</application_name><application_version>1.6</application_version></receiving_application><receiving_facility><facility_name>i2b2 Hive</facility_name></receiving_facility><datetime_of_message>2022-02-04T10:11:26+01:00</datetime_of_message><security><domain>i2b2demo</domain><username>${USERNAME}</username><password>demouser</password></security><message_control_id><message_num>SaUo9S3Zl05U75055L7Ws</message_num><instance_num>0</instance_num></message_control_id><processing_id><processing_id>P</processing_id><processing_mode>I</processing_mode></processing_id><accept_acknowledgement_type>AL</accept_acknowledgement_type><application_acknowledgement_type>AL</application_acknowledgement_type><country_code>US</country_code><project_id>undefined</project_id></message_header><request_header><result_waittime_ms>180000</result_waittime_ms></request_header><message_body><pm:get_user_configuration><project>undefined</project></pm:get_user_configuration></message_body></i2b2:request>"
}

REQUEST="$(create_i2b2_webclient_login_request "i2b2")"
RESPONSE=$(curl --silent --request POST "${URL}" --header "Content-Type: application/xml" --data-raw "${REQUEST}")
if [ "$(echo "${RESPONSE}" | grep -c "<status type=\"DONE\">")" == 1 ]; then
    echo -e "${GRE} - login with correct credentials successful${WHI}"
else
    echo -e "${RED} - login with correct credentials failed${WHI}"
    exit 1
fi

REQUEST="$(create_i2b2_webclient_login_request "2b2i")"
RESPONSE=$(curl --silent --request POST "${URL}" --header "Content-Type: application/xml" --data-raw "${REQUEST}")
if [ "$(echo "${RESPONSE}" | grep -c "<status type=\"ERROR\">")" == 1 ]; then
    echo -e "${GRE} - login with incorrect credentials failed${WHI}"
else
    echo -e "${RED} - login with incorrect credentials successful${WHI}"
    exit 1
fi
