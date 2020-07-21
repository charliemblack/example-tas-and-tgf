#!/bin/bash

# I put this command in so I wouldn't have to type my password in a video
# The instructions  would typically have the password in the helm install command.
docker cp ~/.docker/config.json kind-control-plane:/var/lib/kubelet/config.json

# From the `install.sh` we have uploaded our helm file to `~/.config/helm/repositories.yaml`
# mimicing a helm login.   So we need helm to update from that repo.   Again so I wouldn't
# record entering a password.
helm repo update

# Install the operator
helm install geode-cluster-operator tanzugemfire/geode-cluster-operator --version 0.0.1-beta1

# Create a Tanzu GemFire Cluster
kubectl apply -f ~/tanzu-gemfire.yml
