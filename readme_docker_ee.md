# Installing Gestalt Platform on Docker Enterprise Edition Kubernetes

Installer repository: https://github.com/GalacticFog/gestalt-k8s-install

## Prerequisites

Target Kubernetes Cluster:
* Kubernetes 1.7+ with Helm installed
* PV support on the underlying infrastructure, either dynamic (e.g. Kubernetes configured with Cloud Provider and Default Storage Provisioner) or static

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

helm version # Should be version 2.8.2 or higher

helm init
```

3\. Create the `gestalt-system` namespace
```sh
kubectl create namespace gestalt-system
```

4\. Login to Docker EE, and configure the following:
 - `Full Control` grants for `kube-system/default` for all namespaces (for Helm)
 - `Full Control` grants for `gestalt-system/default` for all namespaces (for Gestalt Platform)

5\. Create a PV for Postgres.  This example uses a hostpath volume to a local directory on a worker node.
```
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gestalt-postgresql-volume
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Mi
  hostPath:
    path: /mnt/gestalt-postgresql-volume
    type: ""
  persistentVolumeReclaimPolicy: Delete
  storageClassName: hostpath
EOF
```

6\. Run the installer
```sh
./install-gestalt-platform docker-ee.conf
```
