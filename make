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


if [ -n "$MDM_APPLICATION_BRANCH" ]
then
  echo "Using backend branch $MDM_APPLICATION_BRANCH"
else
  MDM_APPLICATION_BRANCH='develop'
  echo "Using default backend branch $MDM_APPLICATION_BRANCH"
fi

if [ -n "$MDM_UI_BRANCH" ]
then
  echo "Using frontend branch $MDM_UI_BRANCH"
else
  MDM_UI_BRANCH='develop'
  echo "Using default frontend branch $MDM_UI_BRANCH"
fi

TOMCAT_VERSION=9.0.27-jdk12-adoptopenjdk-openj9
JDK_VERSION=12-jdk-openj9
GRAILS_VERSION=4.0.3
NVM_VERSION=v0.35.3
SDK_VERSION="grails-$GRAILS_VERSION-adoptopenjdk-$JDK_VERSION"
MDM_VERSION=$MDM_APPLICATION_BRANCH

##################

pushd base_images

echo Making updated tomcat image $TOMCAT_VERSION
pushd tomcat
docker build \
  --build-arg TOMCAT_VERSION=${TOMCAT_VERSION} \
  -t mdm/tomcat:$TOMCAT_VERSION .
popd

echo
echo -----------------------
echo

echo Making base build image $SDK_VERSION
pushd sdk_base
docker build \
  --build-arg JDK_VERSION=${JDK_VERSION} \
  --build-arg GRAILS_VERSION=${GRAILS_VERSION} \
  --build-arg NVM_VERSION=${NVM_VERSION} \
  -t mdm/sdk_base:${SDK_VERSION} .
popd

echo
echo -----------------------
echo

echo Making mdm build image $MDM_VERSION
pushd mdm_base
docker build \
  --build-arg SDK_VERSION=${SDK_VERSION} \
  -t mdm/mdm_base:$MDM_VERSION .
popd

echo
echo -----------------------
echo

popd

echo Builing docker compose
docker-compose build \
  --build-arg MDM_BASE_VERSION=${MDM_VERSION} \
  --build-arg MDM_APPLICATION_COMMIT=${MDM_APPLICATION_BRANCH} \
  --build-arg MDM_UI_COMMIT=${MDM_UI_BRANCH} \
  --build-arg TOMCAT_VERSION=${TOMCAT_VERSION}