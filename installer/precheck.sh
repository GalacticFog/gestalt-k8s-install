#!/bin/bash
set -o pipefail

. helpers/install-functions.sh
. gestalt.conf

kube_type=$1

if [ -z "$kube_type" ]; then
    exit_with_error "Must specify a kubernetes environment type"
elif [ ! -d ./profiles/$kube_type ]; then
    exit_with_error "Invalid Kubernetes type: $kube_type" 
fi

envfile=profiles/$kube_type/env.conf

if [ ! -f "$envfile" ]; then
    exit_with_error "Configuration file '$envfile' not found, aborting."
fi

. $envfile

echo "Checking for required dependencies..."

check_for_required_tools

install_prefix=gestalt
install_namespace="gestalt-system"

# Environment checks
check_kubeconfig
check_for_kube
create_or_check_for_required_namespace
check_for_prior_install

check_cluster_capacity
