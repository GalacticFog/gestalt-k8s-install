# Gestalt Platform Kubernetes Install Quick Start

## Prerequisites

* Kubernetes 1.5+ with Helm installed
* Persistent Volume support, either static or dynamic

### Storage Requirements
* If you are running Kubernetes in a public cloud provider you may use a distribution that supports auto-allocating storage (dynamic volume provisioning), such as kubernetes.io on AWS or GKE.

* If you are running Kubernetes on-premise, you either need static volumes or a storage solution that supports dynamic provisioning.

## Install Gestalt Platform

### Step 1 - Install Kubernetes (or use an existing Kubernetes cluster)

Verify your cluster is available:
```
$ kubectl cluster-info
```


### Step 2 - Prepare kubernetes provider configuration file to be used by gestalt

Generate the configuration file:
```
$ ./gen_kubeconfig_yaml.sh /path/to/cluster/kubeconfig
```

### Step 3 - Create 'gestalt-system' namespace in the Kubernetes cluster

```
$ kubectl create namespace gestalt-system
```

### Step 4 - Run the installer

```
$ ./helm_install_gestalt.sh
```

## Access Gestalt Platform

Find the User Interface service endpoint, and navigate your browser to the URL:
```
$ kubectl describe service gestalt-ui --namespace=gestalt-system
...
LoadBalancer Ingress:	ad9f553e323f411e7bd9c0a5e7968435-1588235664.us-east-1.elb.amazonaws.com
...
```
