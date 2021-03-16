ARG JDK_IMAGE_VERSION=12-jdk-openj9

FROM adoptopenjdk:$JDK_IMAGE_VERSION
LABEL maintainer="Oliver Freeman <oliver.freeman@bdi.ox.ac.uk>"

# Default versions
ARG GRAILS_VERSION=4.0.6
ARG NVM_VERSION=0.37.2

# Set environment variables for SDKs
ENV SDKMAN_DIR="/root/.sdkman"
ENV NVM_DIR="/root/.nvm"
ENV NODE_OPTIONS="--max_old_space_size=2048"

# Use bash to ensure sdk commands work
SHELL ["/bin/bash", "-c"]

# Update and install SDK tools
RUN apt-get update
RUN apt-get install -y unzip zip git
RUN curl -s "https://get.sdkman.io" | bash
RUN curl -s "https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh" | bash

## Make runnable and install grails
RUN chmod a+x "$SDKMAN_DIR/bin/sdkman-init.sh"
RUN source "$SDKMAN_DIR/bin/sdkman-init.sh" && sdk install grails "$GRAILS_VERSION"

# Copy in the ssh configuration to allow connection to Github
COPY ssh /opt/ssh
RUN mv /opt/ssh "/root/.ssh"
RUN chmod 700 "/root/.ssh"
RUN chmod 600 "/root/.ssh/config"
RUN chmod 600 "/root/.ssh/id_rsa_application"
RUN chmod 644 "/root/.ssh/id_rsa_application.pub"
RUN chmod 600 "/root/.ssh/id_rsa_ui"
RUN chmod 644 "/root/.ssh/id_rsa_ui.pub"
RUN chmod 644 "/root/.ssh/known_hosts"