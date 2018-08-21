# General Gestalt Install Procedure for Kubernetes

1\. Verify your cluster is available:
```sh
kubectl cluster-info
```

2\. Create Gestalt System namespace:
```sh
kubectl create namespace gestalt-system
```

3\. Edit the configuration file parameters to match your target environment:
```sh
vi [environment-specific configuration file]
```

4\. Run the installer using one of the provided configuration files:
```sh
./install-gestalt-platform [environment-specific configuration file]
```
