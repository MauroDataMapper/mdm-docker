FROM tomcat:9.0-jdk11-openjdk-slim-buster AS updated_tomcat
LABEL maintainer="Oliver Freeman <oliver.freeman@bdi.ox.ac.uk>"

RUN apt-get update
RUN apt-get upgrade
RUN apt-get install -y postgresql-client curl ttf-dejavu

COPY ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/*
RUN mkdir /lucene

RUN rm -rf ${CATALINA_HOME}/webapps/*

VOLUME ${CATALINA_HOME}/logs
VOLUME /lucene
VOLUME /tmp

ENTRYPOINT ["wait-for-postgres.sh"]
CMD ["start-tomcat.sh"]

####
FROM updated_tomcat

ENV CATALINA_OPTS="-Xmx8g -Xms512m -server -XX:+UseConcMarkSweepGC -XX:+UseStringDeduplication -XX:+UseCompressedOops" \
    DATABASE_HOST=postgres \
    DATABASE_PORT=5432 \
    DATABASE_NAME=catalogue \
    DATABASE_USERNAME=catalogueuser \
    DATABASE_PASSWORD=jF80LQyP4BbH \
    EMAIL_USERNAME=REPLACE_ME \
    EMAIL_PASSWORD=REPLACE_ME \
    EMAIL_HOST=smtp.gmail.com \
    EMAIL_PORT=587 \
    EMAIL_TRANSPORTSTRATEGY=SMTP_TLS \
    SEARCH_INDEX_BASE="/lucene" \
    LUCENE_REBUILD_ON_START=true \
    EMAILSERVICE_USERNAME="" \
    EMAILSERVICE_PASSWORD="" \
    EMAILSERVICE_URL=""

COPY config/mauro-data-mapper.xml ${CATALINA_HOME}/conf/Catalina/localhost/ROOT.xml

COPY lib/build ${CATALINA_HOME}/webapps/ROOT

