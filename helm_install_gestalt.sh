#!/bin/bash
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

echo "Checking for 'gestalt-system' namespace"
kubectl get namespace gestalt-system
if [ $? -ne 0 ]; then
  echo ""
  echo "'gestalt-system' namespace must exist before installing gestalt platform.  Create by running"
  echo "the following command:"
  echo ""
  echo "  kubectl create namespace gestalt-system"
  echo ""
  exit 1
fi

echo "Invoking helm install..."
cmd="helm install --namespace gestalt-system ./gestalt -n gestalt-platform -f kube_provider_config.yaml"
echo "$cmd"
$cmd
