#!/bin/bash

source "$NVM_DIR/nvm.sh"
cd $MDM_UI_HOME || exit

echo 'Installing node and npm'
nvm install
#nvm install-latest-npm # we will need to update to v7 asap

echo 'Installing angular'
npm config set user 0
npm config set unsafe-perm true
npm install -g @angular/cli@9.1.7