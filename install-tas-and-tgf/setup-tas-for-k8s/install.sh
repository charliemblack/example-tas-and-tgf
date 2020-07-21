#!/bin/bash
instance=$1
user_host=(${instance//@/ })

ssh-keyscan -H ${user_host[1]}  >> ~/.ssh/known_hosts

scp install_dependancies.sh ${instance}:~/
scp setup_tas4k8s.sh ${instance}:~/
scp app_registry ${instance}:~/

ssh ${instance} '/usr/bin/env bash --login'  << ENDSSH
       chmod a+x *.sh
       ./install_dependancies.sh
ENDSSH
ssh ${instance} '/usr/bin/env bash --login'  << ENDSSH
       ./setup_tas4k8s.sh
ENDSSH
