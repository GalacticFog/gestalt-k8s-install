# Installing Gestalt Platform on Docker Enterprise Edition Kubernetes

Installer repository: https://github.com/GalacticFog/gestalt-k8s-install

## Prerequisites

Target Kubernetes Cluster:
* Docker EE with Kubernetes enabled
* PV support on the underlying infrastructure

Workstation running the Installer:
* Mac OS or Linux
* kubectl configured for the cluster
* Helm installed


## Docker EE Configuration

### 1\. Set Permission Grants for Service Accounts

First, create the `gestalt-system` namespace
```sh
kubectl create namespace gestalt-system
```

Next, login to Docker EE, and configure the following:
 - `Full Control` grants for `kube-system/default` for all namespaces (for Helm)
 - `Full Control` grants for `gestalt-system/default` for all namespaces (for Gestalt Platform)

### 2\. Install Helm

Download your desired version (e.g.  https://github.com/kubernetes/helm/releases/tag/v2.8.2) and install to a location in your system PATH:

```sh
# Example for MacOS

curl -O https://storage.googleapis.com/kubernetes-helm/helm-v2.8.2-darwin-amd64.tar.gz

tar xfzv helm-v2.8.2-darwin-amd64.tar.gz

cp darwin-amd64/helm /usr/local/bin/helm

helm init
```

Verify Helm is working (there should be no errors with the following commands):
```
helm version
helm list
```

### 3\. Persistent Volume for Gestalt Database

**Note: The installer performs this step automatically by default.**  The behavior can be altered by modifying the `docker-ee.conf` configuration file.

Gestalt Platform requires a Postgres database instance, which can be hosted in Kubernetes, or externally.  If hosting on Kubernetes, the database needs a persistent volume.

**Hostpath PV Example:**
This example uses a hostpath volume to a local directory on a worker node.  Alternatively, NFS or another supported PV type may be used.
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: hostpath-volume-01
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Mi
  hostPath:
    path: /tmp/hostpath-volume-01
    type: ""
  persistentVolumeReclaimPolicy: Delete
  storageClassName: hostpath
EOF
```

## Infrastructure Setup

### Load balancer for Kubernetes Worker(s).

A load balancer should be set up fronting the Kubernetes worker node(s), with two listeners configured:
 * One listener for Gestalt UI (default port 33000)
 * One listener for API Gateway (default port 33001)

## Install Gestalt Platform

1\. Obtain the Installer from GitHub
```
git clone https://github.com/GalacticFog/gestalt-k8s-install.git
cd gestalt-k8s-install/
```

Modify the docker-ee.conf config file for your environment:
```
vi docker-ee.conf
```

Specifically, note the following configuration parameters:

* `external_gateway_host` - This should be set to a DNS name for the external load balancer fronting the Kubernetes worker(s).
* `external_gateway_protocol` - Set to 'http' or 'https' depending on the load balancer listener configuration.
* `gestalt_ui_service_nodeport` - The nodeport to serve the Gestalt UI on (default 33000).
* `gestalt_kong_service_nodeport` - The nodeport to serve the Kong API Gateway on (default 33001).

The Gestalt UI will be accessible from `${external_gateway_protocol}://${external_gateway_host}:${gestalt_ui_service_nodeport}`.

The Kong API Gateway will be accessible from `${external_gateway_protocol}://${external_gateway_host}:${gestalt_kong_service_nodeport}`.


2\. Verify your cluster is available:
```sh
kubectl cluster-info
```

3\. Run the installer
```sh
./install-gestalt-platform docker-ee.conf
```

## Removing Gestalt Platform from Docker EE

Remove Gestalt Platform:
```sh
./remove-gestalt-platform
```

Remove the Gestalt database persistent volume:
```sh
kubectl get pv

(shows list of volumes)

kubectl delete pv <name of volume>
```

Finally, remove the `gestalt-system` namespace:
```sh
kubectl delete namespace gestalt-system
```
