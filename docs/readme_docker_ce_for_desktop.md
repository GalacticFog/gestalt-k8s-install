# Installing Gestalt Platform on Docker Community Edition Kubernetes

Gestalt uses a templated helm chart to install our platform onto Kubernetes.  The installation requires that Kubernetes is enabled in your target Docker EE or CE environment (Note you currently need the edge build of Docker CE for Desktop to enable Kubernetes).

**Note: It's recommended that Docker is configured with at least 2 CPU and 12 GB of memory.**

```
git clone https://github.com/GalacticFog/gestalt-k8s-install
cd gestalt-k8s-install
```

Once that is done verify your Kubernetes cluster is working:

```
kubectl cluster-info
```

Next make sure helm is initiated.

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

Then run the installation wizard and follow the instructions:
```
./install-gestalt-platform docker-for-desktop.conf
```
The installer will tell you where it is running at, typically: http://gestalt.local:31112 or http://localhost:31112 for Docker CE for Desktop.

To uninstall the software simply:
```
./remove-gestalt-platform
```

In the event of an installation error, you may inspect the output of `gestalt-installer.log`, or run `./run-diagnostics`.
