# Installing Gestalt Platform on Docker Enterprise Edition Kubernetes

Installer repository: [https://github.com/GalacticFog/gestalt-k8s-install](https://github.com/GalacticFog/gestalt-k8s-install)

## Prerequisites

Target Kubernetes Cluster:

* Docker EE with Kubernetes enabled

* PV support on the underlying infrastructure

Workstation running the Installer:

* Mac OS or Linux

* kubectl configured for the cluster

## Docker EE Configuration

### 1\. Set Permission Grants for Service Accounts

First, create the `gestalt-system` namespace
```sh
kubectl create namespace gestalt-system
```

Next, login to Docker EE, and configure the following:

 - `Full Control` grants for `kube-system/default` for all namespaces (for Helm)

 - `Full Control` grants for `gestalt-system/default` for all namespaces (for Gestalt Platform)

If you've enabled [Role Based Access Control](https://kubernetes.io/docs/reference/access-authn-authz/rbac/), you will need to add a 
[ClusterRoleBinding object](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#default-roles-and-role-bindings) to map the 
`gestalt-system:default` service account to the Kubernetes `cluster-admin` role.

This YAML defines the required ClusterRoleBinding object:
```sh
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: gestalt-system-cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: gestalt-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

You can apply the mapping using `kubectl` with the following command:
```
kubectl apply -f - <<EOF
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: gestalt-system-cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: gestalt-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF
```

### 2\. Persistent Volume for Gestalt Database

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
