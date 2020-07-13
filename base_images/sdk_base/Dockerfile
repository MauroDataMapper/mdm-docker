ARG JDK_VERSION=12-jdk-openj9
FROM adoptopenjdk:$JDK_VERSION
LABEL maintainer="Oliver Freeman <oliver.freeman@bdi.ox.ac.uk>"

ARG GRAILS_VERSION=4.0.3
ARG NVM_VERSION=v0.35.3

ENV SDKMAN_DIR="/root/.sdkman"
ENV NVM_DIR="/root/.nvm"
ENV NODE_OPTIONS="--max-old-space-size=8192"

# Use bash to ensure sdk commands work
SHELL ["/bin/bash", "-c"]

# Update and install SDK tools
RUN apt-get update
RUN apt-get install -y unzip zip git
RUN curl -s "https://get.sdkman.io" | bash
RUN curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash

## Make runnable and install grails
RUN chmod a+x "$SDKMAN_DIR/bin/sdkman-init.sh"
RUN source "$SDKMAN_DIR/bin/sdkman-init.sh" && sdk install grails "$GRAILS_VERSION"

# Copy in the ssh configuration to allow connection to Github
COPY ssh /opt/ssh
RUN mv /opt/ssh "/root/.ssh" && chmod 700 "/root/.ssh"
RUN ls -al "/root/.ssh"

# Copy in the building scripts
COPY build_scripts /usr/local/bin/