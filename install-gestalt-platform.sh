#!/bin/bash

. helpers/install-functions.sh

# ------------ Main -----------------

check_for_required_tools

# Include configuration
. gestalt-config.sh

# Constant. namespace cannot be changed from 'gestalt-system' for now
# as other scripts assume it.
namespace=gestalt-system

mkdir -p ./tmp
exit_on_error "Could not create './tmp', aborting. Check filesystem permissions and try again."

check_for_kube
check_for_helm
check_for_existing_namespace

prompt_or_wait_to_continue

process_kubeconfig
generate_gestalt_config > ./tmp/gestalt-config.yaml
create_namespace
run_helm_install
run_post_install
