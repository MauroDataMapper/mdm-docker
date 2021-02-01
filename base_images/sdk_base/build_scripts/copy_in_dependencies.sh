#!/bin/bash

ADDITIONAL_PLUGINS=$1

if [ -n "$ADDITIONAL_PLUGINS" ]
then
  echo "Adding $ADDITIONAL_PLUGINS to $MDM_APPLICATION_HOME/dependencies.gradle"
else
  echo "No additional plugins to add"
  exit
fi

IFS=';' read -ra DEPS <<< "$ADDITIONAL_PLUGINS"
for DEP in "${DEPS[@]}"; do
    echo "Adding $DEP"
    sed -i "s;//DOCKER_HOOK;runtimeOnly '$DEP'\\n    //DOCKER_HOOK;" $MDM_APPLICATION_HOME/dependencies.gradle

done