#!/bin/bash
mkdir tmp_dir
export TMP_DIR=~/tmp_dir
echo "export TMP_DIR=~/tmp_dir" >> ~/.profile
echo "export KUBECONFIG=~/.kube/config" >> ~/.profile

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
chmod +x ./kind
mkdir -p .local/bin
mv kind .local/bin/
git clone https://github.com/cloudfoundry/cf-for-k8s.git
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
sudo apt-get update
sudo apt-get install -y kubectl
wget -O- https://k14s.io/install.sh | sudo bash
wget https://github.com/cloudfoundry/bosh-cli/releases/download/v6.3.0/bosh-cli-6.3.0-linux-amd64
mv bosh-cli-6.3.0-linux-amd64 ~/.local/bin/bosh
chmod a+x /home/ubuntu/.local/bin/bosh
sudo apt-get install -y cf-cli
sudo apt-get install -y docker.io
sudo snap install yq
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo snap install helm --classic
sudo snap install k9s
mkdir -p ~/.k9s
