# Gestalt Platform Kubernetes Install Quick Start

## Prerequisites

* Kubernetes 1.5+ with Helm installed
* PV support on the underlying infrastructure
* Volumes configured or Dynamic Storage Provisioning enabled

## Installation

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
$ ./remove-gestalt-platform.sh
```
