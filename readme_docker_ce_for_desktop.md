# Installing Gestalt Platform on Docker Community Edition Kubernetes

Gestalt uses a templated helm chart to install our platform onto Kubernetes.  The installation requires that Kubernetes is enabled in your target Docker EE or CE environment (Note you currently need the edge build of Docker CE for Desktop to enable Kubernetes).

git clone https://github.com/GalacticFog/gestalt-k8s-install
cd gestalt-k8s-install
There are different install configurations for Docker EE (docker-ee.conf) and Docker CE (docker-for-desktop.conf). Please edit the appropriate one like this:

```
vi docker-for-desktop.conf
```

Once that is done verify your Kubernetes cluster is working:

```
kubectl cluster-info
```

Next make sure helm is initiated. (you may need to install it ala "brew install kubernetes-helm")

helm init

Finally run the command to install the platform:
```
./install-gestalt-platform docker-for-desktop.conf
```
The installer will tell you where it is running at, typically: http://gestalt.local:31112 or http://localhost:31112 for Docker CE for Desktop.

To uninstall the software simply:
```
./remove-gestalt-platform
```
