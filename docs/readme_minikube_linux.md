
# Installing Minikube on Linux

Minikube can run directly on a Linux host using either the [VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads) or 
[KVM](https://www.linux-kvm.org/page/RunningKVM) hypervisor to manage its virtual machines.  When you're installing Gestalt directly on a 
PC running the Linux OS, we recommend using a hypervisor.

However, Minikube also supports a `--vm-driver=none` option to run containers on Linux without a hypervisor. You may want to try this if 
you're installing Gestalt on a Linux virtual machine. With this option there's no need for an additional virtualization layer, and 
Kubernetes containers will run within the host OS.

[You should not use the `--vm-driver=none` option to run Minikube directly on your Linux laptop or PC.](https://github.com/kubernetes/minikube/blob/master/docs/vmdriver-none.md)

The commands in the steps below are for CentOS or Red Hat Enterprise Linux, but you should be able to install all the same packages using your distro's package manager.

### Install [Docker Community Edition](https://store.docker.com/search?type=edition&offering=community&operating_system=linux)

Minikube requires [Docker Community Edition for Linux](https://docs.docker.com/install/linux/docker-ce/centos/), and will not launch with Docker EE installed.

#### Remove any previously installed Docker versions
```sh
# Check for an installed docker binary
which docker
# or
docker version

# Check for a running docker daemon
sudo netstat -lntp | grep dockerd
# the docker version command will also report the docker daemon version if it's running

# Stop docker if it's running
sudo systemctl stop docker.service

# Remove an existing docker install
sudo yum remove docker docker-client docker-client-latest docker-common docker-latest docker-logrotate docker-latest-logrotate docker-selinux docker-engine-selinux docker-engine
```
#### Install Yum utils
```sh
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```
#### Add the Docker CE Yum repo
```sh
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```
#### Install container-selinux
Go to http://mirror.centos.org/centos/7/extras/x86_64/Packages/ and search the page for *container-selinux*, then install the latest release version.
```sh
sudo yum install -y http://mirror.centos.org/centos/7/extras/x86_64/Packages/container-selinux-2.68-1.el7.noarch.rpm
```
#### Install the Docker CE package
```sh
sudo yum install docker-ce
```
### Start Docker
```sh
# start the docker daemon
sudo systemctl start docker.service

# start the docker daemon automatically when the system starts up
sudo systemctl enable docker.service

# the docker version command should return the installed client and running server versions
docker version
```
### Install ebtables
```sh
sudo yum install ebtables -y
```
### Install socat
```sh
sudo yum install socat -y
```

### Install Minikube and kubectl binaries

Check for an existing kubernetes or Minikube installation.
```sh
# If cwany of these directories exists and isn't empty, you'll want to delete them.
ls -alhF ~/.kube/
sudo ls -alhF /root/.kube/
sudo ls -alhF /etc/kubernetes

# Deleting the existing directories
rm -Rf ~/.kube
sudo rm -Rf /root/.kube/
sudo rm -Rf /etc/kubernetes

# If any of these commands returns the path to a minikube or kubectl executable, you may want to uninstall it first.
which minikube
sudo which minikube
which kubectl
sudo which kubectl
```

Use curl to download and install minikube and kubectl binaries
```sh
sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && sudo install minikube-linux-amd64 /usr/bin/minikube

sudo curl -LO kubectl https://storage.googleapis.com/kubernetes-release/release/v1.10.0/bin/linux/amd64/kubectl && sudo chmod +x kubectl && sudo cp kubectl /usr/bin/ && rm kubectl
```

### [Install crictl](https://kubernetes.io/docs/tasks/debug-application-cluster/crictl/#installing-crictl)
Go to https://github.com/kubernetes-sigs/cri-tools/releases to find the latest release version and use it to set the VERSION env variable below.
```sh
# You may need to install wget
sudo yum install wget zip unzip file

# Check for the latest version and set a shell variable to store it
VERSION="v1.12.0"

# Then download the latest version using wget and install it in /usr/bin
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/bin crictl
rm -f crictl-$VERSION-linux-amd64.tar.gz
```
### Add minikube as a localhost alias in the /etc/hosts file
```sh
# Use sudo to open a shell with root permissions
sudo bash

# Use your favorite text editor to add minkube to the end of the first line.
# It should look something like this:
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 minikube
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
```
### Set bridge network filtering to use iptables
```sh
# Use sudo to open a shell with root permissions
sudo bash

# Write "1" into the bridge-nf-call-iptables file
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

# Close your sudo bash shell
exit
```
### Start Minikube
```sh
sudo minikube start --vm-driver=none

# Wait a bit, and then verify that minikube is running
sudo minikube status

# Expected output should look something like this
minikube: Running
cluster: Running
kubectl: Correctly Configured: pointing to minikube-vm at 172.31.30.180
```
After a few minutes, minikube should be running 10 pods in the kube-system namespace
```sh
# List the running pods in the kube-system namespace
sudo kubectl get pods -n kube-system
```
### Configure kubectl to look for its cluster on localhost

Replace the IP address with “localhost” in the .kube/config file
```sh
# Use sudo to open a shell with root permissions
sudo bash

# Look for the cluster config section in your user's .kube/config file
clusters:
- cluster:
    certificate-authority: /root/.minikube/ca.crt
    server: https://172.31.30.180:8443
  name: minikube

# Edit the file to change that host IP to localhost using your favorite text editor
clusters:
- cluster:
    certificate-authority: /root/.minikube/ca.crt
    server: https://localhost:8443
  name: minikube

# Save the file and close your sudo bash shell
exit
```

If your server is assigned a new IP the next time it restarts, kubectl will now find its cluster on localhost instead of looking for it at the old IP address.

### Verify Minikube is Running

Minikube should be running on your host - try out some of these commands to start exploring your new Kubernetes cluster!
```sh
# Verify that minikube is running
minikube status

# List the Kubnernetes namespaces
sudo kubectl get namespaces

# List all running Kubnernetes services
sudo kubectl get services --all-namespaces

# List running Kubernetes pods in the kube-system namespace
sudo kubectl get pods -n kube-system
```

## Next Steps

[Install Gestalt Platform on a Running Minikube Cluster](./readme_minikube.md#install-gestalt-on-minikube)

