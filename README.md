# Installing Gestalt Platform on Kubernetes

Installer repository: [https://github.com/GalacticFog/gestalt-k8s-install](https://github.com/GalacticFog/gestalt-k8s-install)

## Prerequisites

A target Kubernetes cluster:
* Kubernetes 1.7+
* PV support on the underlying infrastructure

A workstation for running the installer:
* Mac OS or Linux
* kubectl configured for the target cluster
* Helm (helm will be downloaded by the installer if not already present on your system)

## Quick Start

```sh
git clone https://github.com/GalacticFog/gestalt-k8s-install

cd gestalt-k8s-install/installer

./install-gestalt-platform docker-for-desktop    # for docker for desktop

./install-gestalt-platform minikube              # for minikube

```

## Installation instructions

Refer to the installation instructions appropriate for your environment:

- [General Installation Instructions](./docs/readme_general.md)

- [Installation for Docker EE Kubernetes](./docs/readme_docker_ee.md)

- [Installation for Docker CE for Desktop with Kubernetes](./docs/readme_docker_ce_for_desktop.md)

- [Installation for Minikube](./docs/readme_minikube.md)


## Additional resources

 - [Gestalt Platform Documentation](http://docs.galacticfog.com)

 - [Galactic Fog Website](http://www.galacticfog.com)
