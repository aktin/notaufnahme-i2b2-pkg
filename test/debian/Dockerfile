FROM jrei/systemd-ubuntu:20.04

ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y wget unzip patch
WORKDIR /opt

COPY debian/ ./debian/
COPY common/ ./common/
COPY resources/ ./resources/
COPY test/ ./test/

RUN ./debian/build.sh 000
