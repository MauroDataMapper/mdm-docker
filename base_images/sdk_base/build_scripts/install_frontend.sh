#!/bin/bash

source "$NVM_DIR/nvm.sh"
cd $MDM_UI_HOME
nvm install
npm config set user 0
npm config set unsafe-perm true
npm install -g @angular/cli@9.1.7