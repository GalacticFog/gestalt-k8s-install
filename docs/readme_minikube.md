# Quickstart for Gestalt on Minikube

[Minikube](https://kubernetes.io/docs/setup/minikube/) creates a single-node Kubernetes cluster on a single PC or virtual machine, and
Gestalt can run on a Minikube instance.  We recommend that you allocate at least 4 CPUs and 12GB of memory to the Minikube cluster.  You 
may experience startup failures or performance issues when running Gestalt on a smaller cluster.

While __we don't recommend that you use Minikube to support a production Gestalt deployment__, it's well-suited for demonstration purposes.

## Install Minikube on your host OS

In order to run Gestalt on a Minikube Kubernetes cluster, you'll first need to install Minikube.

- [Install Minikube on MacOS](./readme_minikube_macos.md)

- [Install Minikube on Linux](./readme_minikube_linux.md)

## Install Gestalt on Minikube

Once your Minikube cluster is up and running, you can proceed to install Gestalt on the cluster.

First, make sure that your Minikube installation is up and running, if you haven't already done so.

```sh
# Ensure kubectl is pointing to minikube
kubectl config current-context   # should report 'minikube'

# Verify that minikube is running
minikube status

# List your running Kubnernetes services
sudo kubectl get services --all-namespaces

# List your running Kubernetes pods
sudo kubectl get pods --all-namespaces

# Optional - open the Minikube dashboard in your local browser.
minikube dashboard
```

Next, you may need to [increase the vm.max_map_count setting to at least 262144](https://github.com/kubernetes/minikube/issues/2367) so that Elastisearch work properly.

```sh
# Get current vm.max_map_count value. By default it is 65530 that is too low.
minikube ssh 'sysctl vm.max_map_count'

# Set vm.max_map_count to be persistant across restarts
minikube ssh 'echo "sysctl -w vm.max_map_count=262144" | sudo tee -a /var/lib/boot2docker/bootlocal.sh'

# Restart minikube
minikube stop
minikube start

# Make sure after restart vm.max_map_count value is as expected

# Alternative: you could have also set vm.max_map_count with a single command, however it would not persist after restart
minikube ssh 'sudo sysctl -w vm.max_map_count=262144'
```

Then, allow [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) traffic on your Minikube cluster by enabling the
included [NGINX Ingress Controller Add-on](https://github.com/kubernetes/ingress-nginx/).

```sh
# Enable ingress
minikube addons enable ingress

```

Finally, just run the `install-gestalt-platform` script against the `minikube` profile.  The installer script should complete the 
rest of the Gestalt install procedure for you.

```sh
# Run the Gestalt Platform installer
./install-gestalt-platform minikube

```

## Removing Gestalt Platform from Minikube

You may occasionally need to remove the Gestalt platform from Minikube either to restart a failed installation or to install something else.
The `remove-gestalt-platform` script should take care of most of the removal process automatically.

```sh
./remove.sh
```

If you want to delete all of Gestalt's data as well, simply remove the persistent volume used by Gestalt's postgres database.

```sh
minikube ssh 'sudo rm -rf /tmp/gestalt-postgresql-volume'
```
