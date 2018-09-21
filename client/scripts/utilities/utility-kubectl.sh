#!/bin/bash

############################################
# Utilities: Index
############################################

# kube_process_kubeconfig - Obtains kubectl configuration and stores into variable
#                             '${kubeconfig_data}' with kubeurl properly manipulated for installer
# kube_check_for_required_namespace - Validates whether specified kubernetes namespace exists

############################################
# Utilities: START
############################################

kube_process_kubeconfig() {

  os=`uname`

  if [ -z "${kubeconfig_data}" ]; then

    log_debug "[${FUNCNAME[0]}] Obtaining kubeconfig from kubectl context '`kubectl config current-context`'"
    data=$(kubectl config view --raw --flatten=true --minify=true)
    kubeurl='https://kubernetes.default.svc'
    log_debug "[${FUNCNAME[0]}] Converting server URL to '${kubeurl}'"
    # for 'http'
    data=$(echo "${data}" | sed "s;server: http://.*;server: ${kubeurl};g")
    # for 'https'
    data=$(echo "${data}" | sed "s;server: https://.*;server: ${kubeurl};g")

    exit_on_error "[${FUNCNAME[0]}] Could not process kube config, aborting."

    if [ "${os}" == "Darwin" ]; then
      kubeconfig_data=`echo "${data}" | base64`
    elif [ "${os}" == "Linux" ]; then
      kubeconfig_data=`echo "${data}" | base64 | tr -d '\n'`
    else
      log_info "[${FUNCNAME[0]}] Warning: unknown OS type '${os}', treating as Linux"
      kubeconfig_data=`echo "${data}" | base64 | tr -d '\n'`
    fi

    exit_on_error "[${FUNCNAME[0]}] Could not base64 encode kube config, aborting."

    echo "OK - Obtain kubectl configuration and set kubeurl for intaller"

  fi

}

kube_check_for_required_namespace() {

  [[ $# -ne 1 ]] && echo && exit_with_error "[${FUNCNAME[0]}] Function expects 1 parameter ($# provided) [$@], aborting."
  f_namespace_name=$1 

  # echo "Checking for existing Kubernetes namespace '$install_namespace'..."
  kubectl get namespace ${f_namespace_name} > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo ""
    echo "Kubernetes namespace '${f_namespace_name}' doesn't exist, aborting.  To create the namespace, run the following command:"
    echo ""
    echo "  kubectl create namespace ${f_namespace_name}"
    echo ""
    echo "Then ensure that 'Full Control' grants are provided for the '${f_namespace_name}/default' service account."
    echo ""
    exit_with_error "Kubernetes namespace '${f_namespace_name}' doesn't exist, aborting."
  fi
  echo "OK - Kubernetes namespace '${f_namespace_name}' is present."
}

############################################
# Utilities: END
############################################
