# Gestalt Platform Kubernetes Install Quick Start

## Prerequisites

* Kubernetes 1.5+ with Helm installed
* Persistent Volume support, either static or dynamic

<<<<<<< HEAD
## Installation
=======
### Storage Requirements
* If you are running Kubernetes in a public cloud provider you may use a distribution that supports auto-allocating storage (dynamic volume provisioning), such as kubernetes.io on AWS or GKE.

* If you are running Kubernetes on-premise, you either need static volumes or a storage solution that supports dynamic provisioning.

## Install Gestalt Platform
>>>>>>> master

### Step 1 - Install Kubernetes (or use an existing Kubernetes cluster)

Verify your cluster is available:
```
$ kubectl cluster-info
```


### Step 2 - Install and initialize Helm

```
# Example for macOS
$ brew install helm

$ helm init
```

### Step 3 - Run the installer

```
$ ./install-gestalt-platform.sh
```

## Other Actions
### View install status

```
$ ./view-install-status.sh
```

### Access Gestalt Platform

```
$ ./view-access-info.sh
```

### Uninstall Gestalt Platform

```
<<<<<<< HEAD
$ ./remove-gestalt-platform.sh
=======
$ kubectl describe service gestalt-ui --namespace=gestalt-system
...
LoadBalancer Ingress:	ad9f553e323f411e7bd9c0a5e7968435-1588235664.us-east-1.elb.amazonaws.com
...
>>>>>>> master
```
