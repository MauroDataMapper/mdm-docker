
ARG MDM_BASE_IMAGE_VERSION=grails-5.1.7-jdk17.0.3_7-node-14.18.1-npm-8.3.0
ARG TOMCAT_IMAGE_VERSION=9.0.62-jre17-temurin

FROM maurodatamapper/mdm_base:$MDM_BASE_IMAGE_VERSION AS mdm-build
LABEL maintainer="Oliver Freeman <oliver.freeman@bdi.ox.ac.uk>"

ARG MDM_APPLICATION_COMMIT=main
ARG MDM_UI_COMMIT=main
ARG ADDITIONAL_PLUGINS=""
ARG MDM_UI_THEME_NAME="default"
ARG MDM_UI_FEATURE_SUBSCRIBED_CATALOGUES="true"
# This is needed to ensure the fetch and checkout are always run
# If the arg is passed in using a random value then it will invalidate the docker cache and force the following steps to re-run
ARG CACHE_BURST=1

# Uncomment if needing to bypass a SSH firewall
#COPY ssh/config "/root/.ssh/config"
#RUN chmod 600 "/root/.ssh/config"

# Checkout the desired versions
RUN cd "$MDM_APPLICATION_HOME" && git fetch && git checkout "$MDM_APPLICATION_COMMIT" && if [[ `git status` != HEAD\ detached* ]]; then git pull; fi
RUN cd "$MDM_UI_HOME" && git fetch && git checkout "$MDM_UI_COMMIT" && if [[ `git status` != HEAD\ detached* ]]; then git pull; fi

# Copy in build.yml
COPY config/build.yml $MDM_APPLICATION_HOME/grails-app/conf/build.yml

# Allow customisation of the UI
COPY mdm-ui $MDM_UI_HOME/

# Build the front and back ends
# The front end build will try to use precompiled sources or it will build locally from the given commit/tagU
RUN build_frontend.sh

# The only way to include plugins is to build the API manually, however this actually takes very little time as we already have all the
# dependencies downloaded
RUN copy_in_dependencies.sh $ADDITIONAL_PLUGINS
RUN build_backend.sh

# Build the full MDM application
WORKDIR $MDM_BUILD_HOME

RUN echo "$(ls $MDM_APPLICATION_BUILD_HOME/*.war | tail -1)" | xargs jar xvf
RUN cp -r $MDM_UI_BUILD_HOME/* .
RUN ls

FROM maurodatamapper/tomcat:$TOMCAT_IMAGE_VERSION
LABEL maintainer="Oliver Freeman <oliver.freeman@bdi.ox.ac.uk>"

ARG MDM_BUILD_HOME=/opt/mdm

ENV CATALINA_OPTS="-Xmx8g -Xms512m -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+UseCompressedOops"

COPY --from=mdm-build ${MDM_BUILD_HOME} ${CATALINA_HOME}/webapps/ROOT
