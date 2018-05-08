# General Gestalt Install Procedure for Kubernetes

1\. Verify your cluster is available:
```sh
kubectl cluster-info
```

2\. Install helm on your workstation and the kubernetes cluster:
```sh
brew install helm
helm init
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
