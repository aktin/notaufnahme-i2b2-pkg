FROM jboss/wildfly:__VWILDFLY__

ENV DBHOST=database
ENV DBPORT=5432

USER root
RUN yum install -y patch
USER jboss

RUN sed -i 's/-Xms64m -Xmx512m/-Xms1024m -Xmx2g/' /opt/jboss/wildfly/bin/appclient.conf
RUN sed -i 's/-Xms64m -Xmx512m/-Xms1024m -Xmx2g/' /opt/jboss/wildfly/bin/standalone.conf
RUN echo 'JAVA_OPTS="$JAVA_OPTS -Dlog4j2.formatMsgNoLookups=true"' >>  /opt/jboss/wildfly/bin/standalone.conf

COPY ./standalone.xml.patch /opt/jboss/wildfly
RUN patch -p1 -d /opt/jboss/wildfly < /opt/jboss/wildfly/standalone.xml.patch
RUN rm /opt/jboss/wildfly/standalone.xml.patch

COPY ./i2b2.war /opt/jboss/wildfly/standalone/deployments/
COPY ./postgresql-*.jar /opt/jboss/wildfly/standalone/deployments/

COPY ./ds/* /usr/share/aktin-notaufnahme-i2b2/datasource/

USER root
RUN chown -R jboss:jboss /opt/jboss/wildfly/standalone/deployments /usr/share/aktin-notaufnahme-i2b2/datasource
USER jboss

COPY ./entrypoint.sh /
CMD ["/entrypoint.sh"]
