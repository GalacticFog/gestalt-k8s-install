# Installing Minikube on MacOS

We recommend allocating 4 CPUs and 12GB memory for the Minikube cluster. Your system may need more depending on your 
circumstances. If you have trouble launching Minikube or Gestalt, try increasing the memory allocation to the VM.

### Option 1 - Install Minikube with virtual-box VM driver
```sh
brew cask install minikube

minikube start --memory 12288 --cpus 4 --vm-driver virtualbox

```


### Option 2 - Install Minikube with xhyve VM driver

```sh
brew cask install minikube

brew install docker-machine-driver-xhyve

# docker-machine-driver-xhyve need root owner and uid
sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve

minikube start --memory 12288 --cpus 4 --vm-driver xhyve
```

### Verify that your Minikube installation is running.

```sh
# Ensure kubectl is pointing to Minikube
kubectl config current-context   # should report 'minikube'

# Verify that Minikube is running
minikube status

# List your running Kubnernetes services
sudo kubectl get services --all-namespaces

# List your running Kubernetes pods
sudo kubectl get pods --all-namespaces

# Optional - open the Minikube dashboard in your local browser.
minikube dashboard
```

### Next Steps

[Install Gestalt Platform on a Running Minikube Cluster](./readme_minikube.md#install-gestalt-on-minikube)
