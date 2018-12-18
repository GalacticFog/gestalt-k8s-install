#!/bin/bash
#
# Removes Gestalt Platform components from the Kubernetes cluster in the current kubectl context
#
# First deletes Gestalt components from the 'gestalt-system' namespace, then prompts user to 
# delete namespaces in UUID format, assuming those namespaces were created as part of the
# Gestalt Platform installation.

exit_with_error() {
  echo "[Error] $@"
  exit 1
}

exit_on_error() {
  if [ $? -ne 0 ]; then
    exit_with_error $1
  fi
}

check_for_required_tools() {
  which kubectl   >/dev/null 2>&1 ; exit_on_error "'kubectl' command not found, aborting."
}

check_for_kube() {
  echo "Checking for Kubernetes..."
  local kubecontext="`kubectl config current-context`"

  if [ ! -z "$target_kube_context" ]; then
      if [ "$kubecontext" != "$target_kube_context" ]; then
      do_prompt_to_continue \
        "Warning - The current Kubernetes context name '$kubecontext' does not match the expected value, '$target_kube_context'" \
        "Proceed anyway?"
      fi
  fi

  kube_cluster_info=$(kubectl cluster-info)
  exit_on_error "Kubernetes cluster not accessible, aborting."

  echo "OK - Kubernetes cluster '$kubecontext' is accessible."
}

prompt_to_continue(){
  echo ""
  echo "Gestalt Platform will be removed from Kubernetes cluster '`kubectl config current-context`'."
  echo "This cannot be undone."
  echo ""

  while true; do
      read -p "$* Proceed? [y/n]: " yn
      case $yn in
          [Yy]*) break;;
          [Nn]*) echo "Aborted" ; exit  1 ;;
      esac
  done
  
  echo
#  read -p "Enter the name of the cluster to confirm deletion [`kubectl config current-context`]: " value
#  case $value in
#      `kubectl config current-context`) return 0  ;;
#      *) echo "Aborted" ; exit  1 ;;
#  esac
}

remove_gestalt_platform() {

  # First, check if the namespace is even present

  kubectl get namespace $install_namespace > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Nothing to do - Kubernetes namespace '$install_namespace' isn't present."
    return 0
  fi

  # Remove Gestalt Platform

  echo ""
  echo "Removing Gestalt Platform components from '$install_namespace' namespace..."
  kubectl delete daemonsets,replicasets,statefulsets,services,deployments,pods,rc,secrets,configmaps,pvc,ingresses \
    --timeout=30s --all --namespace $install_namespace

  if [ $? -ne 0 ]; then
  
    # Removal was unsuccessful, try force removal

    echo ""
    echo "Warning: 'kubectl delete' failed, re-attempting with forceful delete..."
    echo ""
    
    # The --force flag helps clean up pods stuck in the 'Terminating' state
    kubectl delete daemonsets,replicasets,statefulsets,services,deployments,pods,rc,secrets,configmaps,pvc,ingresses \
      --grace-period=0 --force --all --namespace $install_namespace
  fi
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

install_prefix=$1
install_namespace=$2

if [ -z "$install_prefix" ]; then
  install_prefix=gestalt
fi

if [ -z "$install_namespace" ]; then
  install_namespace=${install_prefix}-system
fi


# Check for pre-reqs
check_for_required_tools
check_for_kube

prompt_to_continue

remove_gestalt_platform

remove_gestalt_namespaces

echo "Done."
