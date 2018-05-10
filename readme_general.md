# General Gestalt Install Procedure for Kubernetes

1\. Verify your cluster is available:
```sh
kubectl cluster-info
```

2\. Install Helm

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


3\. Create Gestalt System namespace:
```sh
kubectl create namespace gestalt-system
```

4\. Edit the configuration file parameters to match your target environment:
```sh
vi [environment-specific configuration file]
```

5\. Run the installer using one of the provided configuration files:
```sh
./install-gestalt-platform [environment-specific configuration file]
```
