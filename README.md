# Installing Gestalt Platform on Kubernetes

Installer repository: https://github.com/GalacticFog/gestalt-k8s-install

## Prerequisites

Target Kubernetes Cluster:
* Kubernetes 1.7+ with Helm installed
* PV support on the underlying infrastructure, either dynamic (e.g. Kubernetes configured with Cloud Provider and Default Storage Provisioner) or static (e.g. Canonical Kubernetes using Ceph storage / RBD volumes)

Workstation running the Installer:
* Mac OS or Linux
* kubectl configured for the cluster
* Helm installed


## General Gestalt Install Procedure for Kubernetes
1\. Verify your cluster is available:
```sh
kubectl cluster-info
```

2\. Install helm on your workstation and the kubernetes cluster:
```sh
brew install helm
helm init
```

3\. Run the installer using one of the provided configuration files:
```sh
./install-gestalt-platform [environment-specific configuration file]
```

## Quick Start for Kubernetes on Docker for Desktop (on MacOS)
```sh
./install-gestalt-platform docker-for-desktop.conf
```


## Quick Start for Minikube (on MacOS)

Recommend 4 CPUs and 8GB memory for the minikube cluster.

### Option 1 - Install Minikube with virtual-box VM driver
```sh
brew cask install minikube

minikube start --memory 8192 --cpus 4 --vm-driver virtualbox

```


### Option 2 - Install Minikube with xhyve VM driver

```sh
brew cask install minikube

brew install docker-machine-driver-xhyve

# docker-machine-driver-xhyve need root owner and uid
sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve

minikube start --memory 8192 --cpus 4 --vm-driver xhyve
```

### Install Gestalt Platform on a Running Minikube Cluster

```sh
# Ensure kubectl is pointing to minikube
kubectl config current-context   # should report 'minikube'

# Check that kubernetes is up
minikube dashboard

# Enable ingress
minikube addons enable ingress

# Install helm on the cluster
helm init

# Run the Gestalt Platform installer
./install-gestalt-platform minikube.conf

```
