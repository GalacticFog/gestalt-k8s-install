# Installation Steps

## Simple

```sh
vi config/install-config.yaml           # Customize options

./install-gestalt-platform <profile>    # Run installation.  profile = docker-for-desktop, minikube, etc
```

## Advanced

## Step 1: Pre-Install Configuration

1. Ensure `config/gestalt-license.json` is present.
2. Modify `config/install-config.yaml` for the target environment and desired configuration.
3. Ensure the kubectl current context is set to the target Kubernetes cluster.  Check with `kubectl config current-context`, and set with `kubectl config use-context <context name>`.
4. Run `./pre-check.sh`

**Advanced configuration:**

4. Modify `config/install-config.yaml` to change any fine-grained settings.
5. Modify the Resource Templates at `../src/resource_templates/*` if necessary.
6. Modify the Helm chart at `../src/gestalt-helm-chart/*` if necessary.
7. Modify the `config/installer.yaml` if necessary.

## Step 2: Stage the Install Configuration

1. Run `./stage.sh`

This step creates an installer ConfigMap in the `gestalt-system` namespace.

## Step 3: Initiate the Installation

1. Run `./install.sh`

This step deploys `installer.yaml` to the Kubernetes cluster, which runs an installer Pod.  The Pod utilizes the ConfigMap resources defined in the previous step.

2. Run `./follow_log.sh` to follow the Gestalt installation logs emitted by the installer Pod.  When the installation is complete (or fails), press `Ctrl-C` to stop following the logs.

# Removing Gestalt Platform

Run `./remove.sh` and follow the prompts.


# Troubleshooting

View installer logs:
```
kubectl logs --namespace gestalt-system  gestalt-installer
```

Get a shell to the installer Pod:
```
kubectl exec --namespace gestalt-system -ti gestalt-installer -- bash
```

View logs:
```
ls logs/*
```

Run diagnostics:
```
./run-diagnostics
```
