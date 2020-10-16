
ARG MDM_BASE_IMAGE_VERSION=develop
ARG TOMCAT_IMAGE_VERSION=9.0.27-jdk12-adoptopenjdk-openj9

FROM mdm/mdm_base:$MDM_BASE_IMAGE_VERSION AS mdm-build
LABEL maintainer="Oliver Freeman <oliver.freeman@bdi.ox.ac.uk>"

ARG MDM_APPLICATION_COMMIT=develop
ARG MDM_UI_COMMIT=develop
ARG ADDITIONAL_PLUGINS=""

# Checkout the desired versions
RUN cd "$MDM_APPLICATION_HOME" && git checkout "$MDM_APPLICATION_COMMIT" && git pull
RUN cd "$MDM_UI_HOME" && git checkout "$MDM_UI_COMMIT" && git pull

# Build the front and back ends
RUN build_frontend.sh
RUN copy_in_dependencies.sh $ADDITIONAL_PLUGINS
RUN build_backend.sh

# Build the full MDM application
WORKDIR $MDM_BUILD_HOME

RUN echo "$(ls $MDM_APPLICATION_BUILD_HOME/*.war | tail -1)" | xargs jar xvf
RUN cp -r $MDM_UI_BUILD_HOME/* .
RUN ls

FROM mdm/tomcat:$TOMCAT_IMAGE_VERSION
LABEL maintainer="Oliver Freeman <oliver.freeman@bdi.ox.ac.uk>"

ARG MDM_BUILD_HOME=/opt/mdm

ENV CATALINA_OPTS="-Xmx8g -Xms512m -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+UseCompressedOops" \
    DATABASE_HOST=postgres \
    DATABASE_PORT=5432 \
    DATABASE_NAME=maurodatamapper \
    DATABASE_USERNAME=maurodatamapperuser \
    DATABASE_PASSWORD=jF80LQyP4BbH \
    EMAIL_USERNAME="" \
    EMAIL_PASSWORD="" \
    MDM_FQ_HOSTNAME=localhost \
    MDM_PORT=8080 \
    MDM_AUTHORITY_URL="" \
    MDM_AUTHORITY_NAME="" \
    EMAIL_HOST=smtp.gmail.com \
    EMAIL_PORT=587 \
    EMAIL_TRANSPORTSTRATEGY=SMTP_TLS \
    SEARCH_INDEX_BASE="/lucene" \
    LUCENE_REBUILD_ON_START=true \
    EMAILSERVICE_USERNAME="" \
    EMAILSERVICE_PASSWORD="" \
    EMAILSERVICE_URL=""


COPY config/mauro-data-mapper.xml ${CATALINA_HOME}/conf/Catalina/localhost/ROOT.xml

COPY --from=mdm-build ${MDM_BUILD_HOME} ${CATALINA_HOME}/webapps/ROOT
