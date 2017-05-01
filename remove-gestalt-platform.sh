#!/bin/bash

. helpers/install-functions.sh

check_for_gestalt() {
  echo "Checking for existing Gestalt Platform..."

  name=gestalt-platform

  helm status $name >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    exit_with_error "Helm deployment '$name' not found, aborting."
  fi
  echo "OK - Helm deployment '$name' found."

  kubectl get namespace $namespace > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    exit_with_error "Kubernetes namespace '$namespace' isn't present, aborting."
  fi
  echo "OK - Kubernetes namespace '$namespace' found."

}

prompt_to_continue(){
  echo ""
  echo "Gestalt Platform will be removed and namespace '$namespace' will be deleted."
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


namespace=gestalt-system

# Check for pre-reqs
check_for_required_tools
check_for_kube
check_for_helm

# Sanity check that gestalt-platform exists
check_for_gestalt

prompt_to_continue

remove_gestalt_platform

echo "Done."
