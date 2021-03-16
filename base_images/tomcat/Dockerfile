# Update tomcat image
ARG TOMCAT_IMAGE_VERSION=9.0.27-jdk12-adoptopenjdk-openj9

FROM tomcat:$TOMCAT_IMAGE_VERSION
LABEL maintainer="Oliver Freeman <oliver.freeman@bdi.ox.ac.uk>"

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y postgresql-client curl ttf-dejavu fontconfig

COPY ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*
RUN mkdir /lucene

RUN rm -rf ${CATALINA_HOME}/webapps/*

VOLUME ${CATALINA_HOME}/logs
VOLUME /lucene
VOLUME /tmp

ENTRYPOINT ["wait-for-postgres.sh"]
CMD ["start-tomcat.sh"]
