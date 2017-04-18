# Gestalt Platform Quick Start

## Step 1 - Install Kubernetes (or use an existing Kubernetes cluster)

Verify your cluster is available:
```
$ kubectl cluster-info
```


## Step 2 - Prepare kubernetes provider configuration file to be used by gestalt

Generate the configuration file:
```
$ ./gen_kubeconfig_yaml.sh /path/to/cluster/kubeconfig
```

## Step 3 - Create 'gestalt-system' namespace in the Kubernetes cluster

```
$ kubectl create namespace gestalt-system
```


## Step 4 - Run the installer

```
$ ./helm_install_gestalt.sh
```
