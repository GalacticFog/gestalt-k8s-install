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

## Known Issues

* **Kubernetes not available until restart** - After installing Docker CE for the first time, Kubernetes may not function until a system restart.  Please restart MacOS after the initial install of Docker CE if you encounter problems with the install.

* **Docker pull error** - The `docker pull` command may fail with `Error response from daemon: Get unauthorized: incorrect username or password` if you are logged into DockerHub using an email address rather than an Docker ID.  Please either `docker logout`, or re-login using your Docker ID instead of email address.  The issue is here: https://github.com/docker/hub-feedback/issues/935