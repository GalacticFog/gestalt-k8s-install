# Installing Gestalt Platform on Kubernetes

## Requirements

Target Kubernetes Cluster:
* Kubernetes 1.5+ with Helm installed
* PV support on the underlying infrastructure, either dynamic (e.g. Kubernetes configured with Cloud Provider and Default Storage Provisioner) or static (e.g. Canonical Kubernetes using Ceph storage / RBD volumes)

Workstation running the Installer:
* Mac OS or Linux
* kubectl configured for the cluster
* helm client installed

## Gestalt Platform Installation

### Step 1 - Install Kubernetes (or use an existing Kubernetes cluster)

Verify your cluster is available:

```sh
$ kubectl cluster-info
```


### Step 2 - Install and initialize Helm
The installer utilizes helm.  Install helm with:

```sh
# Example for macOS
brew install helm

helm init
```

### Step 3 - Configure and Run the Installer
Set options to match the target Kubernetes cluster, and run the installer:

```sh
vi gestalt-config.rc

./install-gestalt-platform.sh
```

Note: for an automated install with no user prompts, set environment variable `GESTALT_AUTOMATED_INSTALL=1` prior to running the installer (this is used by the Conjure-Up Gestalt Installer for Kubernetes).

## Other Actions
### View install status
View the status of the Gestalt Platform installation:
```sh
./view-install-status.sh
```

### Access Gestalt Platform
View access information:
```sh
./view-access-info.sh
```

### Uninstall Gestalt Platform
Delete the Gestalt Platform:
```sh
./remove-gestalt-platform.sh
```
