#!/bin/bash

############################################
# Utilities: Index
############################################



############################################
# Utilities: START
############################################


check_for_required_tools_gestalt_installer() {

  log_debug "Check presence of: base64 tr sed seq sudo true kubectl curl unzip tar"
  check_if_installed "base64 tr sed seq sudo true kubectl curl unzip tar"

}

gestalt_install_help () {

  echo ""
  echo "Help: `basename $0`"
  echo ""

}

gestalt_install_validate_preconditions() {

    echo "Expectation, that user already successfully ran ./configure.sh"

    file_array="${conf_install} ${kube_install}"
    log_debug "[${FUNCNAME[0]}] Check for required files: '${file_array[@]}'"
    check_for_required_files "${file_array[@]}"

    log_debug "[${FUNCNAME[0]}] Validate that expected json files are in json format: '${conf_install}'"
    validate_json ${conf_install}

    log_debug "[${FUNCNAME[0]}] Validate that expected json files are in json format: '${conf_install}'"
    validate_json ${gestalt_license}

    log_debug "[${FUNCNAME[0]}] Validate that expected environment variables are set ..."

    check_for_required_variables \
      kube_namespace conf_install \
      gestalt_license \
      gestalt_custom_resources

    echo "Precondition check succeeded"

}

gestalt_install_create_configmaps() {

  # Create a configmap with the generated install config
  kubectl create configmap -n ${kube_namespace} installer-config --from-file ${conf_install}
  exit_on_error "Failed create configmap \
  'kubectl create configmap -n ${kube_namespace} installer-config --from-file ${conf_install}', aborting."

  # Create a configmap with gestal license
  kubectl create configmap -n ${kube_namespace} gestalt-license --from-file ${gestalt_license}
  exit_on_error "Failed create configmap \
  'kubectl create configmap -n ${kube_namespace} gestalt-license --from-file ${gestalt_license}', aborting."

  # Create configmap from './custom_resource_templates' folder contents if want custom
  if [ ${gestalt_custom_resources} == "true" ]; then

    kubectl create configmap -n ${kube_namespace} gestalt-resources --from-file ./resource_templates/
    exit_on_error "Failed create configmap \
    'kubectl create configmap -n ${kube_namespace} gestalt-resources --from-file ./resource_templates/', aborting."

  else

    echo "No custom resources: skipping 'gestalt-resources' configmap creation"

  fi

}


# Run the install container with ConfigMaps


############################################
# Utilities: END
############################################

