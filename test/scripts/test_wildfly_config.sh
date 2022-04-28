#! /bin/bash
set -euo pipefail

readonly WHI="\e[0m"
readonly RED="\e[0;31m"
readonly GRE="\e[0;32m"

if [[ -z $(grep "JAVA_OPTS=\"-Xms1024m -Xmx2g -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true\"" "/opt/wildfly/bin/appclient.conf") ]]; then
    echo -e "${RED} - java heap memory in appclient.conf is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "JAVA_OPTS=\"-Xms1024m -Xmx2g -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=256m -Djava.net.preferIPv4Stack=true\"" "/opt/wildfly/bin/standalone.conf") ]]; then
    echo -e "${RED} - java heap memory in standalone.conf is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "JAVA_OPTS=\"\$JAVA_OPTS -Dlog4j2.formatMsgNoLookups=true\"" "/opt/wildfly/bin/standalone.conf") ]]; then
    echo -e "${RED} - log4j fix in standalone.conf is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<property name=\"jboss.as.management.blocking.timeout\ value=\"900\"/>" "/opt/wildfly/standalone/configuration/standalone.xml") ]]; then
    echo -e "${RED} - blocking timeout in standalone.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<size-rotating-file-handler name=\"srf\" autoflush=\"true\" rotate-on-boot=\"true\">" "/opt/wildfly/standalone/configuration/standalone.xml") ]]; then
    echo -e "${RED} - rotating file handler in standalone.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<http-listener name=\"default\" socket-binding=\"http\" max-post-size=\"1073741824\" redirect-socket=\"https\" enable-http2=\"true\"/>" "/opt/wildfly/standalone/configuration/standalone.xml") ]]; then
    echo -e "${RED} - http max-post-size in standalone.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<https-listener name=\"https\" socket-binding=\"https\" max-post-size=\"1073741824\" security-realm=\"ApplicationRealm\" enable-http2=\"true\"/>" "/opt/wildfly/standalone/configuration/standalone.xml") ]]; then
    echo -e "${RED} - https max-post-size in standalone.xml is not set correctly${WHI}"
    exit 1
fi

if [[ -z $(grep "<socket-binding name=\http\" port=\"\${jboss.http.port:9090}\"/>" "/opt/wildfly/standalone/configuration/standalone.xml") ]]; then
    echo -e "${RED} - https max-post-size in standalone.xml is not set correctly${WHI}"
    exit 1
fi

echo -e "${GRE} - wildfly configuration is set accordingly${WHI}"
