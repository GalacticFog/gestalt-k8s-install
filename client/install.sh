#!/bin/bash

############################################
# SETUP
############################################

# Source common project configuration and utilities
. ./scripts/utilities/utility-project-check.sh

# Validate that all pre-conditions are met
gestalt_install_validate_preconditions

# Check that the `gestalt-system` namespace exists.  If not, print some commands to create it
kube_check_for_required_namespace ${kube_namespace}

# Create (if applicable) 'installer-config', 'gestalt-license' and 'gestalt-resources' configmaps 
gestalt_install_create_configmaps

# TODO: Add function that check whether config maps were created and whether has actual content
# kubectl get configmap -n gestalt-system

# Run the install container with ConfigMaps
kubectl apply -n ${kube_namespace} -f ${kube_install}
exit_on_error "Failed install \
'kubectl apply -n ${kube_namespace} -f ${kube_install}', aborting."

echo
echo "Gestalt Platform installer deployed to '${kube_namespace}'.  To view the installer logs, run the following:"
echo
echo "  kubectl logs -n gestalt-system gestalt-installer --follow"
echo
echo "Done."