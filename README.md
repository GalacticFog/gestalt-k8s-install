# Installing Gestalt Platform on Kubernetes

Installer repository: https://github.com/GalacticFog/gestalt-k8s-install

## Prerequisites

Target Kubernetes Cluster:
* Kubernetes 1.7+ with Helm installed
* PV support on the underlying infrastructure, either dynamic (e.g. Kubernetes configured with Cloud Provider and Default Storage Provisioner) or static (e.g. Canonical Kubernetes using Ceph storage / RBD volumes)

Workstation running the Installer:
* Mac OS or Linux
* kubectl configured for the cluster
* helm client installed


## General Install Procedure
1\. Verify your cluster is available:
```sh
kubectl cluster-info
```

2\. Install helm on your workstation and the kubernetes cluster:
```sh
brew install helm
helm init
```

3\. Set Configuration options
```sh
vi gestalt-config.conf
```

4\. Run the installer
```sh
./install-gestalt-platform your_config_file.conf
```

## Quick Start for Minikube (on MacOS)

Recommend 4 CPUs and 8GB memory for the minikube cluster.

### Option 1 - Install Minikube with virtual-box VM driver
```sh
brew cask install minikube

```

```sh
# Start
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

### Install Gestalt Platform on Minikube

```sh
# Check that kubernetes is up
minikube dashboard

# Enable ingress
minikube addons enable ingress

# Show minikube cluster IP
minikube ip

# Add to /etc/hosts
(minikube IP)   gtw1.gestalt.local  gestalt.local

# Install helm on the cluster
helm init

# Run the Gestalt Platform installer
./install-gestalt-platform minikube.conf

```

### Example of Installing on Minikube

```
$ ./install-gestalt-platform minikube.conf
Checking environment...
OK - Required tools found.
OK - kubeconfig appears to be valid.
OK - Kubernetes cluster 'minikube' is accessible.
OK - Helm is installed.
OK - Kubernetes namespace 'gestalt-system' does not exist.
OK - No prior installation found.
Defaulting GESTALT_ADMIN_USERNAME to 'gestalt-admin'
Defaulting GESTALT_ADMIN_PASSWORD to random password
Defaulting DATABASE_NAME to 'postgres'
Obtaining kubeconfig from kubectl
Helm chart configuration generated.

Configuration Summary:
 - Kubernetes cluster: minikube
 - Kubernetes namespace: gestalt-system
 - Gestalt Admin: gestalt-admin
 - Gestalt User Interface: http://gestalt.local
 - Gestalt API Gateway: http://gtw1.gestalt.local
 - Database: Provisioning an internal database

Gestalt Platform is ready to be installed to Kubernetes cluster 'minikube'.

Proceed with Gestalt Platform installation? [y/n]: y
Creating namespace 'gestalt-system'...
namespace "gestalt-system" created
Namespace gestalt-system created.
Installing Gestalt Platform to Kubernetes using Helm...
Command: helm install --namespace gestalt-system ./gestalt -n gestalt -f gestalt-config.yaml
NAME:   gestalt
LAST DEPLOYED: Wed Nov  1 20:05:49 2017
NAMESPACE: gestalt-system
STATUS: DEPLOYED

RESOURCES:
==> v1/Pod
NAME               READY  STATUS             RESTARTS  AGE
gestalt-installer  0/1    ContainerCreating  0         2s

==> v1beta1/Deployment
NAME                DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
gestalt-postgresql  1        1        1           0          2s
gestalt-security    1        1        1           0          2s
gestalt-rabbit      1        1        1           0          2s
gestalt-meta        1        1        1           0          2s
gestalt-ui          1        1        1           0          2s

==> v1beta1/Ingress
NAME        HOSTS          ADDRESS  PORTS  AGE
gestalt-ui  gestalt.local  80       1s

==> v1/Secret
NAME                TYPE    DATA  AGE
gestalt-postgresql  Opaque  1     2s
gestalt-secrets     Opaque  4     2s

==> v1/PersistentVolumeClaim
NAME                STATUS  VOLUME                                    CAPACITY  ACCESSMODES  STORAGECLASS  AGE
gestalt-postgresql  Bound   pvc-95b38191-bf61-11e7-a858-3e307d755d53  100Mi     RWO          standard      2s

==> v1/Service
NAME                CLUSTER-IP  EXTERNAL-IP  PORT(S)             AGE
gestalt-ui          10.0.0.198  <nodes>      80:30513/TCP        2s
gestalt-security    10.0.0.109  <nodes>      9455:32607/TCP      2s
gestalt-rabbit      10.0.0.104  <none>       5672/TCP,15672/TCP  2s
gestalt-meta        10.0.0.124  <nodes>      10131:32126/TCP     2s
gestalt-postgresql  10.0.0.219  <none>       5432/TCP            2s


NOTES:
 - Gestalt Platform installation initiated to namespace 'gestalt-system', and will take a few minutes to complete.

 - Login credentials:

        User:      gestalt-admin
        Password:  f4TtOLIfiEYypuF1

 - You may access the Gestalt platform documentation at

        http://docs.galacticfog.com/

 - You may view a log of the installation with the following:

    ./view-installer-logs     (Ctrl-C to stop)


Running post install: minikube-post-install.sh ...
===========================================
   Minikube Post-Install Configuration
===========================================

Your minikube cluster IP is 192.168.64.3

Acess to Gestalt on minikube requires use of virtual hosts / ingress.
Please add the following to your /etc/hosts file:
---
# Gestalt configuration for minikube
192.168.64.3    gestalt.local gtw1.gestalt.local
---

Gestalt UI will be available at http://gestalt.local
Gestalt API Gateway will be available at http://gtw1.gestalt.local
```
