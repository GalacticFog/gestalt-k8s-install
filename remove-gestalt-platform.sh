#!/bin/bash

. helpers/install-functions.sh

check_for_gestalt() {
  echo "Checking for existing Gestalt Platform..."

  name=gestalt-platform

  helm status $name >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Nothing to do - Helm deployment '$name' not found."
    exit 1
  fi
  echo "OK - Helm deployment '$name' found."

  kubectl get namespace $namespace > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Nothing to do - Kubernetes namespace '$namespace' isn't present."
    exit 1
  fi
  echo "OK - Kubernetes namespace '$namespace' found."
}

prompt_to_continue(){
  echo ""
  echo "Gestalt Platform will be removed from Kubernetes cluster '`get_kube_context`' and namespace '$namespace' will be deleted."
  echo "This cannot be undone."
  echo ""

  while true; do
      read -p "$* Proceed? [y/n]: " yn
      case $yn in
          [Yy]*) return 0  ;;
          [Nn]*) echo "Aborted" ; exit  1 ;;
      esac
  done
}

remove_gestalt_platform() {
  echo "Removing gestalt-platform ..."
  helm delete --purge gestalt-platform

  echo "Deleting namespace '$namespace'..."
  kubectl delete namespace $namespace
}

remove_gestalt_namespaces() {

  local namespaces=$( kubectl get namespaces | grep -E '[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}' | awk '{print $1}')
  if [ $? -eq 0 ] && [ ! -z "$namespaces" ]; then
    echo ""
    echo "Warning: There are existing namespaces that appear to be from a prior install:"
    echo "$namespaces"
    echo ""

    while true; do
        read -p "$* Delete these namespaces? [y/n]: " yn
        case $yn in
            [Yy]*) do_delete_namespaces $namespaces ; break ;;
            [Nn]*) break ;;
        esac
    done
  else
    echo "No gestalt namespaces found"
  fi
}

do_delete_namespaces() {
  kubectl delete namespace $@
  echo "Done deleting namespaces."
}

mkdir -p ./tmp

namespace=gestalt-system

# Check for pre-reqs
check_for_required_tools
check_for_kube
check_for_helm

# Sanity check that gestalt-platform exists
check_for_gestalt

prompt_to_continue

remove_gestalt_platform

remove_gestalt_namespaces

echo "Done."
