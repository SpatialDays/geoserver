FROM tomcat:9-jre8

#
# Set GeoServer version and data directory
#
ARG GEOSERVER_VERSION=2.22
ARG PATCH_NUMBER=x
ENV GEOSERVER_DATA_DIR="/geoserver_data/data"

#
# Download and install GeoServer
#

RUN apt-get update -y
RUN apt-get install unzip -y
RUN apt-get clean
RUN rm -rf /var/cache/apt/lists


RUN wget --no-check-certificate --progress=bar:force:noscroll \
    # https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}.${PATCH_NUMBER}/geoserver-${GEOSERVER_VERSION}.${PATCH_NUMBER}-war.zip && \
    https://build.geoserver.org/geoserver/2.22.x/geoserver-2.22.x-latest-war.zip \
    && /usr/bin/unzip -q geoserver-2.22.x-latest-war.zip \
    && mv geoserver.war webapps/ \
    && rm geoserver-2.22.x-2023-02-21-war.zip \
    && cd webapps \
    && unzip -q geoserver.war -d geoserver \
    && rm geoserver.war \
    && mkdir -p $GEOSERVER_DATA_DIR

# RUN mkdir geoserver-backup-plugin && cd geoserver-backup-plugin && \
#     wget  \\ && 
#     unzip geoserver-2.23-SNAPSHOT-backup-restore-plugin.zip && \
#     rm geoserver-2.23-SNAPSHOT-backup-restore-plugin.zip

# RUN cp geoserver-backup-plugin/* webapps/geoserver/WEB-INF/lib/ && \
#     rm -rf geoserver-backup-plugin

RUN mkdir netcdf-plugin  && cd netcdf-plugin  && \
    wget --no-check-certificate --progress=bar:force:noscroll  -c https://build.geoserver.org/geoserver/2.22.x/ext-latest/geoserver-2.22-SNAPSHOT-netcdf-plugin.zip && \
    /usr/bin/unzip geoserver-2.22-SNAPSHOT-netcdf-plugin.zip  && \
    rm geoserver-2.22-SNAPSHOT-netcdf-plugin.zip

RUN cp netcdf-plugin/* webapps/geoserver/WEB-INF/lib/ && \
    rm -rf netcdf-plugin

RUN mkdir /geoserver_netcdf_indexes && chmod -R 777 /geoserver_netcdf_indexes

ENV JAVA_OPTS="-DNETCDF_DATA_DIR=/geoserver_netcdf_indexes -Djava.awt.headless=true -XX:MaxPermSize=512m -XX:PermSize=256m -Xms512m -Xmx2048m -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:ParallelGCThreads=4 -Dfile.encoding=UTF8 -Duser.timezone=GMT -Djavax.servlet.request.encoding=UTF-8 -Djavax.servlet.response.encoding=UTF-8 -Duser.timezone=GMT -Dorg.geotools.shapefile.datetime=true"
