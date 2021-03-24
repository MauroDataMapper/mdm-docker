#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -b|--backend-branch)
    MDM_APPLICATION_BRANCH="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--frontend-branch)
    MDM_UI_BRANCH="$2"
    shift # past argument
    shift # past value
    ;;
    -u|--update-tomcat)
    TOMCAT_BUILD_ARGS='--no-cache'
    shift # past argument
    ;;
    -c|--clean-build)
    TOMCAT_BUILD_ARGS='--no-cache'
    BASE_IMAGE_ARGS='--no-cache'
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

##################
# Functions

getDate(){
  date +"%Y-%m-%d %H:%M:%S,%sZ"
}

outputLine(){
  echo
  eval printf '%.0s-' {1..$(tput cols)}
  echo
}

#################
# ENV Variables
# DO NOT CHANGE WITHOUT CHANGING Dockerfile versions as well
# This is merely to allow us to tag the images as theyre built
JAVA_VERSION=12
ADOPTOPENJDK_VARIANT=openj9
TOMCAT_VERSION=9.0.27
GRAILS_VERSION=4.0.6

MDM_IMAGE_VERSION=main
TOMCAT_IMAGE_VERSION="$TOMCAT_VERSION-jdk$JAVA_VERSION-adoptopenjdk-$ADOPTOPENJDK_VARIANT"
SDK_IMAGE_VERSION="grails-$GRAILS_VERSION-jdk$JAVA_VERSION-adoptopenjdk-$ADOPTOPENJDK_VARIANT"

#################
# Build Args

BUILD_ARGS="--build-arg CACHE_BURST=$(date +%s)"

if [ -n "$MDM_APPLICATION_BRANCH" ]
then
  echo "Using backend branch $MDM_APPLICATION_BRANCH"
  BUILD_ARGS="$BUILD_ARGS --build-arg MDM_APPLICATION_COMMIT=${MDM_APPLICATION_BRANCH}"
fi

if [ -n "$MDM_UI_BRANCH" ]
then
  echo "Using frontend branch $MDM_UI_BRANCH"
  BUILD_ARGS="$BUILD_ARGS --build-arg MDM_UI_COMMIT=${MDM_UI_BRANCH}"
fi

TOMCAT_BUILD_ARGS="${TOMCAT_BUILD_ARGS} \
  -t mdm/tomcat:$TOMCAT_IMAGE_VERSION"

SDK_BUILD_ARGS="${BASE_IMAGE_ARGS} \
  -t mdm/sdk_base:${SDK_IMAGE_VERSION}"

MDM_BUILD_ARGS="${BASE_IMAGE_ARGS} \
  -t mdm/mdm_base:$MDM_IMAGE_VERSION"

##################
# Run

set -e

outputLine

echo "Using docker >> $(docker --version) << [Required 19.03.0+]"
echo "Using docker-compose >> $(docker-compose -version) << [Recommended 1.27.0+]"


pushd base_images

outputLine

echo "$(getDate) : Making updated tomcat image $TOMCAT_IMAGE_VERSION"
echo
pushd tomcat
docker build ${TOMCAT_BUILD_ARGS} .
popd

outputLine

echo "$(getDate) : Making base build image $SDK_IMAGE_VERSION"
echo
pushd sdk_base
docker build ${SDK_BUILD_ARGS} .
popd

outputLine

echo "$(getDate) : Making mdm build image $MDM_IMAGE_VERSION"
echo
pushd mdm_base
docker build ${MDM_BUILD_ARGS} .
popd
popd

outputLine

echo "$(getDate) : Building docker compose"
echo
docker-compose build ${BUILD_ARGS}

outputLine
echo "$(getDate) : Make complete"
outputLine