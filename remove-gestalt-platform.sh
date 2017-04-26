#!/bin/bash

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


namespace=gestalt-system

prompt_to_continue

echo "Removing gestalt-platform ..."
helm delete --purge gestalt-platform

echo "Deleting namespace '$namespace'..."
kubectl delete namespace $namespace

echo "Done."
