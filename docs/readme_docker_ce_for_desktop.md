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

Then run the installation wizard and follow the instructions:
```
./install-gestalt-platform docker-for-desktop.conf
```
The installer will tell you where Gestalt is running, typically http://localhost:31112 for Docker CE for Desktop.

To uninstall the software simply:
```
./remove-gestalt-platform
```

In the event of an installation error, you may inspect the output of `gestalt-installer.log`, or run `./run-diagnostics`.
