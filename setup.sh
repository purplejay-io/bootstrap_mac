#!/bin/bash

mkdir -p ~/.config
cd ~/.config/

if [[ ! -d ~/.config/bootstrap-mac ]];then
    git clone git@github.com:purplejay-io/bootstrap_mac.git
else
    git pull

./run.sh