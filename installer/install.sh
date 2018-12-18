#!/bin/bash

# Source common project configuration and utilities
utility_file='./scripts/utilities/utility-project-check.sh'
if [ -f ${utility_file} ]; then
  . ${utility_file}
else
  echo "[ERROR] Project initialization script '${utility_file}' can not be located, aborting. "
  exit 1
fi

# Run the install container with ConfigMaps
cmd="kubectl create -n ${kube_namespace} -f ${kube_install}"
$cmd
exit_on_error "Failed install: '$cmd', aborting."

echo
echo "Gestalt Platform installer deployed to '${kube_namespace}'.  To view the installer progress, run the following:"
echo
echo "  kubectl logs -n gestalt-system gestalt-installer --follow"
echo
echo "Done."
