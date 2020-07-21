# Setup and install VMware Tanzu Application Service and VMware Tanzu GemFire for Kubernetes

This project was my attempt to automate the install of Tanzu Application Service TAS and Tanzu GemFire for Kubernetes for demos on some VM.   The project is not meant to be production quality since it does't check if something has been done correctly.   

The installed kubernetes cluster will be hosted on a single VM.   I am sure one could scale this out by following each projects instructions for production scale and assurance.

At the end of running `install.sh` you will have a Tanzu GemFire cluster as specified in the [tanzu-gemfire.yml](setup_tanzu_gemfire/tanzu_gemfire.yml) and a Tanzu Application Service ready to deploy applications to.

# Prerequisites
1. Docker account - TAS for K8s will use the docker account.
2. **A NEW Ubuntu based distribution VM**
 1. The scripts don't protect existing files.   Please fork/copy/cut and paste if you want to change behavior.
 2. The scripts use `snap` and `apt` to fetch missing packages.   So hece the requires Ubuntu based distribution.

# Setup
Before running please edit the files that need credentials for Docker and the Tanzu.    The same credentials may need to be added to more then one config file.   Please review so we don't have to restart the process.

## Passwordless login
The scripting here makes use of passwordless or certificate based logins.    So make sure you setup your `ssh` tools to handle that.   There are many tutorials out there so will skip it here.    The basics are upload your `public key` and append to your remote `~/.ssh/authorized_keys`.

I assumed `ssh-agent` has been loaded so the `private key` doesn't have to be referanced throughout the scripts.   So if you aren't using the default key-pair then you can add to the `ssh-agent`.

### Add a key to the SSH agent
```
eval `ssh-agent`
ssh-add ~/.ssh/my_private_key.pem
```

## Files
 The `install.sh` scripts are intended to be run on the local host.    Those `install.sh` scripts will upload and run the needed scripts and configuration files.   

```
$ tree
.
├── install.sh - Main script that calls the other two install.sh scripts
├── readme.md - A Read Me.
├── setup-tanzu-gemfire
│   ├── config.json - EDIT this before running install.sh (docker Tanzu Network credentials)
│   ├── install.sh - Run on the local machine
│   ├── repositories.yaml - EDIT this before running install.sh (helm Tanzu Network credentials)
│   ├── setup_tanzu_gemfire.sh - Executed on a VM - Installs the operator and creates a Tazu GemFire cluster.
│   └── tanzu-gemfire.yml - EDIT Before running install.sh The Tanzu GemFire configuration.
└── setup-tas-for-k8s
    ├── app_registry - EDIT this before running install.sh (docker repository credentials For TAS to build apps)
    ├── install.sh - Run on the local machine
    ├── install_dependancies.sh - Get all of the K8s tools needed.
    └── setup_tas4k8s.sh - Executed on a VM - Installs TAS.
```

## Edit these files and add your credentials

* `setup_tanzu_gemfire/tanzu-gemfire.yml` - This contains the configuration for the Tanzu GemFire cluster that will be instantiated at the end of the `install.sh` script.
* `setup-tanzu-gemfire/config.json` - This contains the docker logins for Tanzu Registry and can have docker account information.    This is file is what is contained at `~/.docker/config.json`
* `setup-tanzu-gemfire/repositories.yaml` - This is the helm login.   This is the same file that would be contained at `~/.config/helm/repositories.yaml`.
* `setup-tas-for-k8s/app_registry` - This contains the docker login for TAS to work with.   TAS will store some meta data about the cluster there and any apps that get `cf push`ed.

### Docker Auth Strings

If you don't want to upload your docker `cofig.json` you can base64 encode your username and password for Tanzu and Docker and only expose those to your secure VM.

#### Example encode
```
$ echo -n 'username:password' | base64
dXNlcm5hbWU6cGFzc3dvcmQ=
```
#### Example decode
```
$ echo 'dXNlcm5hbWU6cGFzc3dvcmQ=' | base64 --decode
username:password
```
