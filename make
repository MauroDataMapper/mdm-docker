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
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

##################

JAVA_VERSION=12
ADOPTOPENJDK_VARIANT=openj9
TOMCAT_VERSION=9.0.27
GRAILS_VERSION=4.0.6
NVM_VERSION=0.37.2

MDM_IMAGE_VERSION=main
TOMCAT_IMAGE_VERSION="$TOMCAT_VERSION-jdk$JAVA_VERSION-adoptopenjdk-$ADOPTOPENJDK_VARIANT"
JDK_IMAGE_VERSION="$JAVA_VERSION-jdk-$ADOPTOPENJDK_VARIANT"
SDK_IMAGE_VERSION="grails-$GRAILS_VERSION-jdk$JAVA_VERSION-adoptopenjdk-$ADOPTOPENJDK_VARIANT"

BUILD_ARGS="--build-arg CACHE_BURST=$(date +%s) \
  --build-arg MDM_BASE_IMAGE_VERSION=${MDM_IMAGE_VERSION} \
  --build-arg TOMCAT_IMAGE_VERSION=${TOMCAT_IMAGE_VERSION}"

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

##################

set -e

pushd base_images

echo
echo "Making updated tomcat image $TOMCAT_IMAGE_VERSION"
echo
pushd tomcat
docker build \
  --build-arg TOMCAT_IMAGE_VERSION=${TOMCAT_IMAGE_VERSION} \
  -t mdm/tomcat:$TOMCAT_IMAGE_VERSION .
popd

echo
echo "-----------------------"
echo

echo "Making base build image $SDK_IMAGE_VERSION"
echo
pushd sdk_base
docker build \
  --build-arg JDK_IMAGE_VERSION=${JDK_IMAGE_VERSION} \
  --build-arg GRAILS_VERSION=${GRAILS_VERSION} \
  --build-arg NVM_VERSION=${NVM_VERSION} \
  -t mdm/sdk_base:${SDK_IMAGE_VERSION} .
popd

echo
echo "-----------------------"
echo

echo "Making mdm build image $MDM_IMAGE_VERSION"
echo
pushd mdm_base
docker build \
  --build-arg SDK_IMAGE_VERSION=${SDK_IMAGE_VERSION} \
  -t mdm/mdm_base:$MDM_IMAGE_VERSION .
popd
popd

echo
echo "-----------------------"
echo

echo "Building docker compose"
echo
docker-compose build $BUILD_ARGS