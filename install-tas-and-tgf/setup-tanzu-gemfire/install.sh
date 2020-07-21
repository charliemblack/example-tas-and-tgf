#!/bin/bash
instance=$1
user_host=(${instance//@/ })

ssh-keyscan -H ${user_host[1]}  >> ~/.ssh/known_hosts

ssh ${instance} '/usr/bin/env bash --login'  << ENDSSH
      mkdir -p ~/.config/helm
      mkdir -p ~/.docker
ENDSSH

scp repositories.yaml ${instance}:~/.config/helm/repositories.yaml
scp setup_tanzu_gemfire.sh ${instance}:~/
scp config.json ${instance}:~/.docker/config.json
scp tanzu-gemfire.yml ${instance}:~/tanzu-gemfire.yml

ssh ${instance} '/usr/bin/env bash --login'  << ENDSSH
       chmod a+x *.sh
       ./setup_tanzu_gemfire.sh
ENDSSH
