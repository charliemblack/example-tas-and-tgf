#!/bin/bash

cd ~/cf-for-k8s
kind create cluster --config=./deploy/kind/cluster.yml
kubectl cluster-info --context kind-kind
./hack/generate-values.sh -d vcap.me > ${TMP_DIR}/cf-values.yml
cat ~/app_registry >> ${TMP_DIR}/cf-values.yml
ytt -f config -f config-optional/remove-resource-requirements.yml -f config-optional/remove-ingressgateway-service.yml -f config-optional/add-metrics-server-components.yml -f config-optional/patch-metrics-server.yml -f ${TMP_DIR}/cf-values.yml > ${TMP_DIR}/cf-for-k8s-rendered.yml
kapp deploy -a cf -f ${TMP_DIR}/cf-for-k8s-rendered.yml -y
cf api api.vcap.me --skip-ssl-validation
cf auth admin "$(yq  r  ${TMP_DIR}/cf-values.yml 'cf_admin_password')"
cf enable-feature-flag diego_docker
cf create-org test-org
cf create-space -o test-org test-space
cf target -o "test-org" -s "test-space"
