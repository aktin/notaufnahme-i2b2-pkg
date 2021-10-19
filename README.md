# notaufnahme-i2b2

Paketierung der I2B2 Installation für das AKTIN Datawarehouse in Notaufnahmen

# unzip is needed

builds a functional i2b2 instance
includes postgres database
wildfly
and apache2 server with i2b2 webclient


1. to create new package run ./build.sh with argument package_name and package_version
creates in debian and docker folder a new dir named build with the corresponding package content

common/build.sh common functions needed by both docker and debian

2. Order
create new dir
i2b2_webclient
wildfly_download
wildfly_systemd
wildfly_config
wildfly_i2b2
database_postinstall
datasource_postinstall

3. puts the in corresponding folders

4. zips folder to debian package



ORDER DEBIAN
common/Build.sh
debian/build.sh
debian/postinstall.sh

# mostly the same, configuration wildfly is moved from build to postinstall in docker
ORDER DOCKER
common/build.sh
docker/build.sh
docker/docker-compose.yaml
docker/database/Dockerfile
docker/http/Dockerfile
docker/wildfly/Dockerfile




# TODO Tests

############## docker-compose kann nicht über das skript ausgeführt werden?
ERROR: Couldn't connect to Docker daemon at http+docker://localhost - is it running?
If it's at a non-standard location, specify the URL with the DOCKER_HOST environment variable.


# TODO tests finishing
# TODO docker fix
# TODO READMEs



service postgresql start/restart braucht zu lange



apt-get install -y unzip debconf curl sudo libpq-dev software-properties-common openjdk-11-jre-headless apache2 php php-common libapache2-mod-php php-curl libcurl4-openssl-dev libssl-dev libxml2-dev postgresql-12



# install all packages
# install postgres
# run debian packages

# build debian
# apt-get install -y unzip
# make everything debian/* executable
chmod +x build.sh clean.sh
chmod +x debian/*

apt-get install -y postgresql-12
 apt install ./paket1--i2b2_1.deb




# build docker
apt-get install docker-compose

export DOCKER_HOST=127.0.0.1

sudo chmod 666 /var/run/docker.sock




# check creation of docker images with
docker images
