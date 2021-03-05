ARG SDK_IMAGE_VERSION=grails-4.0.6-jdk12-adoptopenjdk-openj9

FROM mdm/sdk_base:$SDK_IMAGE_VERSION
LABEL maintainer="Oliver Freeman <oliver.freeman@bdi.ox.ac.uk>"

# Set default build location environment variables
ENV MDM_BUILD_HOME=/opt/mdm
ENV MDM_APPLICATION_HOME=/opt/mdm-application-build
ENV MDM_APPLICATION_BUILD_HOME=$MDM_APPLICATION_HOME/build/libs
ENV MDM_UI_HOME=/opt/mdm-ui
ENV MDM_UI_BUILD_HOME=$MDM_UI_HOME/dist

# Make the build home
RUN mkdir $MDM_BUILD_HOME

# Set the working directory
WORKDIR /opt

# Checkout the desired versions
RUN git clone -b main github-mdm-application:MauroDataMapper/mdm-application-build.git
RUN git clone -b main github-mdm-ui:MauroDataMapper/mdm-ui.git

# Install the front and back end dependencies
RUN build_backend.sh
RUN install_frontend.sh
RUN clean_backend.sh