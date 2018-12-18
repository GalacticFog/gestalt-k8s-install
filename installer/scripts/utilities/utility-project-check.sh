#!/bin/bash

############################################
# General Settings and References
############################################

  # Credentials and Configs
  conf_gestalt_conf="./gestalt.conf"
  
  # Scripts and Utilities
  script_folder="./scripts"
  
  utility_folder="./scripts/utilities"
  utility_bash="${utility_folder}/utility-bash.sh"
  utility_gestalt_install="${utility_folder}/utility-gestalt-installer-run.sh"
  utility_kubectl="${utility_folder}/utility-kubectl.sh"

  #Generated Files
  kube_install="./installer.yaml"

############################################
# Main base utility script
############################################

  if [ ! -f "${utility_bash}" ]; then
    echo "[ERROR] Utility file '${utility_bash}' not found, aborting."
    exit 1
  else
    . "${utility_bash}"
    exit_on_error "Unable source utility file '${utility_bash}', aborting."
    log_debug "Sourced '${utility_bash}'"
  fi

############################################
# Other common configurations and utilities / scripts
############################################

source_required_files "${utility_gestalt_install} ${utility_kubectl} ${conf_gestalt_conf}"

########################################################################################
# END
########################################################################################
