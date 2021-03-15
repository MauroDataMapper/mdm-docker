#!/bin/bash

source "$NVM_DIR/nvm.sh"
cd $MDM_UI_HOME || exit

echo 'Installing node and npm'
nvm install
nvm install --latest-npm # we will need to update to v7 asap

npm config set user 0
npm config set unsafe-perm true
npm config set progress false
echo 'Installing angular'
npm install -g @angular/cli@9.1.7