#!/bin/bash

gestalt_install_validate_preconditions() {

    echo "Expectation, that user already successfully ran ./configure.sh"

    file_array="${kube_install}"
    log_debug "[${FUNCNAME[0]}] Check for required files: '${file_array[@]}'"
    check_for_required_files "${file_array[@]}"

    log_debug "[${FUNCNAME[0]}] Validate that expected environment variables are set ..."

    check_for_required_variables \
      kube_namespace
      
    # check_for_kube

    echo "Precondition check succeeded"
}


############################################
# Utilities: END
############################################

