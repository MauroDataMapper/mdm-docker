# Build the defined version
ARG SDK_VERSION=grails-4.0.3-adoptopenjdk-12-jdk-openj9
FROM mdm/sdk_base:$SDK_VERSION
LABEL maintainer="Oliver Freeman <oliver.freeman@bdi.ox.ac.uk>"

ENV MDM_BUILD_HOME=/opt/mdm
ENV MDM_APPLICATION_HOME=/opt/mdm-application-build
ENV MDM_APPLICATION_BUILD_HOME=$MDM_APPLICATION_HOME/build/libs
ENV MDM_UI_HOME=/opt/mdm-ui
ENV MDM_UI_BUILD_HOME=$MDM_UI_HOME/dist

RUN mkdir $MDM_BUILD_HOME
WORKDIR /opt

# Checkout the desired versions
RUN git clone -b develop github-mdm-application:MauroDataMapper/mdm-application-build.git
RUN git clone -b develop github-mdm-ui:MauroDataMapper/mdm-ui.git

# Build the front and back ends
RUN build_backend.sh
RUN install_frontend.sh
RUN clean_backend.sh