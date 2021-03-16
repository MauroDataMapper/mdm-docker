ARG SDK_IMAGE_VERSION=grails-4.0.6-jdk12-adoptopenjdk-openj9

FROM mdm/sdk_base:$SDK_IMAGE_VERSION
LABEL maintainer="Oliver Freeman <oliver.freeman@bdi.ox.ac.uk>"

# Set default build location environment variables
ENV MDM_BUILD_HOME=/opt/mdm
ENV MDM_APPLICATION_HOME=/opt/mdm-application-build
ENV MDM_APPLICATION_BUILD_HOME=$MDM_APPLICATION_HOME/build/libs
ENV MDM_UI_HOME=/opt/mdm-ui
ENV MDM_UI_BUILD_HOME=$MDM_UI_HOME/dist

# Copy in the building scripts
COPY build_scripts /usr/local/bin/

# Make the build home
RUN mkdir $MDM_BUILD_HOME

# Set the working directory
WORKDIR /opt

# Checkout the desired versions
RUN git clone -b main github-mdm-application:MauroDataMapper/mdm-application-build.git
RUN git clone -b main github-mdm-ui:MauroDataMapper/mdm-ui.git

# Install the front end dependencies
# Install node and npm and set config
RUN source "$NVM_DIR/nvm.sh" && \
    cd $MDM_UI_HOME || exit  && \
    echo 'Installing node and npm' && \
    nvm install && \
    npm config set user 0  && \
    npm config set unsafe-perm true  && \
    npm config set progress false && \
    nvm install --latest-npm

# Fix ownership issues of node directories after install
# Dont know why but nvm installs as user 1001
RUN chown -R root:root $NVM_DIR

# Install angular CLI
RUN echo 'Installing angular'  && \
    source "$NVM_DIR/nvm.sh" && \
    npm install -g @angular/cli@9.1.12

# Install the back end dependencies by building the war file
# This makes sure all the most likely dependencies are pre-downloaded
RUN build_backend.sh

# Clean the back end build to make sure theres no potential conflict later
RUN clean_backend.sh