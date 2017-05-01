#!/bin/bash

# Constant. namespace cannot be changed from 'gestalt-system' for now
# as other scripts assume it.
namespace=gestalt-system

. helpers/install-functions.sh

check_for_required_tools

mkdir -p ./tmp
exit_on_error "Could not create './tmp', aborting. Check filesystem permissions and try again."

# Include configuration
. gestalt-config.sh

check_for_kube
check_for_helm
check_for_existing_namespace

prompt_or_wait_to_continue

process_kubeconfig
generate_gestalt_config > ./tmp/gestalt-config.yaml
create_namespace
run_helm_install          ./tmp/gestalt-config.yaml
run_post_install
