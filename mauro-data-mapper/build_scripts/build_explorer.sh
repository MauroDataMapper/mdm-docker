#!/bin/bash

precompiledBuild(){
   echo 'Using pre-compiled source'

  if [[ $MDM_EXPLORER_VERSION == *SNAPSHOT ]]
  then
    MDM_EXPLORER_LIBRARY='artifacts-snapshots'
   else
     MDM_EXPLORER_LIBRARY='artifacts'
   fi

  MDM_EXPLORER_URL="http://jenkins.cs.ox.ac.uk/artifactory/${MDM_EXPLORER_LIBRARY}/mauroDataMapper/mdm-explorer/mdm-explorer-${MDM_EXPLORER_VERSION}.tgz"

  echo "Downloading precompiled sources ${MDM_EXPLORER_URL}"

  cd /opt || exit
  curl -LO "$MDM_EXPLORER_URL"
  tar xzf "mdm-explorer-${MDM_EXPLORER_VERSION}.tgz"
  mkdir "$MDM_EXPLORER_BUILD_HOME"
  cp -r "mdm-explorer-${MDM_EXPLORER_VERSION}"/* "$MDM_EXPLORER_BUILD_HOME"

  find "$MDM_EXPLORER_BUILD_HOME" -name main.*.js -exec sed -e "s|apiEndpoint:\"api\",|apiEndpoint:\"${MDM_EXPLORER_API_ENDPOINT}\",|g" -i {} \;
}

precompiledBuild