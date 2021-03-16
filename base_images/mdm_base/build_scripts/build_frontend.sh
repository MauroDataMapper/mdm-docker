#!/bin/bash

source "$NVM_DIR/nvm.sh"
cd $MDM_UI_HOME
npm clean-install
ng build --prod
