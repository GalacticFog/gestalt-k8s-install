# Quick Start for Minikube (on MacOS)

Recommend 4 CPUs and 8GB memory for the minikube cluster.

### Option 1 - Install Minikube with virtual-box VM driver
```sh
brew cask install minikube

minikube start --memory 8192 --cpus 4 --vm-driver virtualbox

```


### Option 2 - Install Minikube with xhyve VM driver

```sh
brew cask install minikube

brew install docker-machine-driver-xhyve

# docker-machine-driver-xhyve need root owner and uid
sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve

minikube start --memory 8192 --cpus 4 --vm-driver xhyve
```

### Minikube settings adjustment

Elasticsearch requires that the vm.max_map_count be set to at least 262144.
Due https://github.com/kubernetes/minikube/issues/2367 we are unable set this as part of startup.

```sh
# Get current vm.max_map_count value. By default it is 65530 that is too low.
minikube ssh 'sysctl vm.max_map_count'

# Set vm.max_map_count to be persistant across restarts
minikube ssh 'echo "sysctl -w vm.max_map_count=262144" | sudo tee -a /var/lib/boot2docker/bootlocal.sh'

# Restart minikube
minikube stop
minikube start

# Make sure after restart vm.max_map_count value is as expected

# Alternative: you could have also set vm.max_map_count to expected, however it would not persist after restart
minikube ssh 'sudo sysctl -w vm.max_map_count=262144'
```

### Install Gestalt Platform on a Running Minikube Cluster

```sh
# Ensure kubectl is pointing to minikube
kubectl config current-context   # should report 'minikube'

# Check that kubernetes is up
minikube dashboard

# Enable ingress
minikube addons enable ingress

# Run the Gestalt Platform installer
./install-gestalt-platform minikube.conf

```

## Removing Gestalt Platform from Minikube

Remove Gestalt Platform:
```sh
./remove-gestalt-platform
```

Remove the Gestalt database persistent volume:
```sh
minikube ssh 'sudo rm -rf /tmp/gestalt-postgresql-volume'
```
