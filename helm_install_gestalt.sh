#!/bin/bash

namespace=gestalt-system

echo "Checking for kube_provider_config.yaml"
echo ""
if [ ! -f kube_provider_config.yaml ]; then
  echo ""
  echo "A kube_provider_config.yaml file must be generated before installing Gestalt platform."
  echo "Generate one using the following command:"
  echo ""
  echo "  ./gen_kubeconfig_yaml.sh /path/to/.kube/config"
  echo ""
  echo "helm install aborted."
  echo ""
  exit 1
fi

echo "Checking for '$namespace' namespace"
kubectl get namespace $namespace
if [ $? -ne 0 ]; then
  echo ""
  echo "[ERROR] '$namespace' namespace must exist before installing gestalt platform.  Create by running"
  echo "the following command:"
  echo ""
  echo "  kubectl create namespace $namespace"
  echo ""
  exit 1
fi

echo "Invoking helm install..."
cmd="helm install --namespace $namespace ./gestalt -n gestalt-platform -f kube_provider_config.yaml"
echo "$cmd"
$cmd
