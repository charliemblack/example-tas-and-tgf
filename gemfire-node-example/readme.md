# Example book service

This demo assumes that a Tanzu GemFire and Tanzu Application Service environment has been created.


<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Install NodeJS Libraries](#install-nodejs-libraries)
- [Run Locally](#run-locally)
	- [Run some Tanzu GemFire servers](#run-some-tanzu-gemfire-servers)
	- [Expose the `VCAP_SERVICES` to the application through the environment](#expose-the-vcapservices-to-the-application-through-the-environment)
	- [Run the NodeJS server](#run-the-nodejs-server)
	- [Add a book locally](#add-a-book-locally)
	- [Lookup a book locally](#lookup-a-book-locally)
- [Run on TAS](#run-on-tas)
	- [Create the User Provided Service `cups`](#create-the-user-provided-service-cups)
	- [Push the app](#push-the-app)
	- [Add a book](#add-a-book)
	- [Get a book by ISBN](#get-a-book-by-isbn)
	- [Remove All of the Books](#remove-all-of-the-books)

<!-- /TOC -->
## Install NodeJS Libraries

Download the Tanzu GemFire NodeJS client libraries from Tanzu Network.

* GemFire - https://network.pivotal.io/products/tanzu-gemfire-for-vms

Once you have downloaded the right artifact, copy it to your own `<project>/gemfire-node-example` directory. This is important for the pushing the app to PCF.

```bash
$ cd <project>/gemfire-node-example/scripts
$ ./startGemFire.sh
$ cd ..
$ npm install gemfire-nodejs-all-v2.0.1-build.33.tgz
```

## Run Locally

It is very common for developers to want to run locally.   Running locally enables the developer so they can iterate quickly and with out being distrubed with data actions in the cloud.

Since we are going to eventually push the app to Pivotal Cloud Foundry, we are going to target our local environment to mock a Cloud Foundry environment.  Cloud Foundry injects the services binding through a `VCAP_SERVICES` environment variable.    So we are going to mock that environment variable to do local testing so our application doesn't have to handle any environment differently.

### Run some Tanzu GemFire servers

The scripts directory contains `startGemFire.sh`, which will start up two locators and two cache servers.  The locators allow clients to find the cache servers.  To simplify local development, script also creates the regions.

### Expose the `VCAP_SERVICES` to the application through the environment
```
export VCAP_SERVICES='{{"user-provided":[{"label": "user-provided","name": "gemfire-service","tags": [],"instance_name": "gemfire-service","binding_name": null,"credentials": {"locators": ["localhost[10334]","localhost[10335]"]},"syslog_drain_url": "","volume_mounts": []}]}'
```
### Run the NodeJS server

```
$ cd <project>/gemfire-node-example
$ node src/server.js
```
### Add a book locally
```
curl -X PUT \
  'http://localhost:8080/book/put?isbn=0525565329' \
  -H 'Content-Type: application/json' \
  -d '{
  "FullTitle": "The Shining",
  "ISBN": "0525565329",
  "MSRP": "9.99",
  "Publisher": "Anchor",
  "Authors": "Stephen King"
}'
```
### Lookup a book locally

```
curl -X GET \
  'http://localhost:8080/book/get?isbn=0525565329'
```

## Run on TAS

Edit the `manifest.yml` file to update the service instance that the app will be bound to.  In this repository the service instance is called `gemfire-service`.


### Create the region in Tanzu GemFire

In order to store data in Tanzu GemFire we first need to create something called a region.  There are two main region types replicated and partitioned.   Most applications will be using partitioned.  

We create the regions using the `gfsh` cli.   

```
$ kubectl exec --stdin --tty gemfire-locator-0 -- gfsh
    _________________________     __
   / _____/ ______/ ______/ /____/ /
  / /  __/ /___  /_____  / _____  /
 / /__/ / ____/  _____/ / /    / /  
/______/_/      /______/_/    /_/  

Monitor and Manage Apache Geode
gfsh>connect
Connecting to Locator at [host=localhost, port=10334] ..
Connecting to Manager at [host=gemfire-locator-0.gemfire-locator.default.svc.cluster.local, port=1099] ..
Successfully connected to: [host=gemfire-locator-0.gemfire-locator.default.svc.cluster.local, port=1099]

gfsh>create region --name=books --type=PARTITION
     Member      | Status | Message
---------------- | ------ | --------------------------------------------
gemfire-server-0 | OK     | Region "/books" created on "gemfire-server-0"
gemfire-server-1 | OK     | Region "/books" created on "gemfire-server-1"

Cluster configuration for group 'cluster' is updated.

gfsh>exit
```

### Create the User Provided Service `cups`
The fully qualified hostname of the locators will be dependent on `name` of the cluster and the name space its in.   

```
 <cluster name>-locator-{replica-index}.<cluster name>-locator.{namespace}.svc.cluster.local
 ```

Check this [file](../install-tas-and-tgf/setup-tanzu-gemfire/tanzu-gemfire.yml) for `name`

Using the default install the below `cf cups` command is valid.

```
cf cups gemfire-service -p '{"locators":["gemfire-locator-0.gemfire-locator.default.svc.cluster.local[10334]","gemfire-locator-1.gemfire-locator.default.svc.cluster.local[10334]"]}'
```

### Push the app

```
$ cf push
```

### Add a book
```
curl -k -X PUT \
  'https://gemfire-node-sample.apps.vcap.me/book/put?isbn=0525565329' \
  -H 'Content-Type: application/json' \
  -d '{
  "FullTitle": "The Shining",
  "ISBN": "0525565329",
  "MSRP": "9.99",
  "Publisher": "Anchor",
  "Authors": "Stephen King"
}'
```

### Get a book by ISBN
```
curl -k -X GET \
  'https://gemfire-node-sample.apps.vcap.me/book/get?isbn=0525565329'
```
### Remove All of the Books
```
curl -k -X PUT \
  'https://gemfire-node-sample.apps.vcap.me/book/removeall'
```
