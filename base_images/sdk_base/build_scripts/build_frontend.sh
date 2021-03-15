#!/bin/bash

source "$NVM_DIR/nvm.sh"
cd $MDM_UI_HOME || exit

echo 'Removing node_modules'
rm -rf node_modules

echo 'Installing dependencies'
npm ci

echo 'Building'
ng build --prod
