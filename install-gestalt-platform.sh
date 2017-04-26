#!/bin/bash

exit_with_error() {
  echo "[Error] $1"
  exit 1
}

exit_on_error() {
  if [ $? -ne 0 ]; then
    exit_with_error $1
  fi
}

check_for_kube() {
  kubectl cluster-info > ./tmp/cluster-info
  exit_on_error "Kubernetes cluster not accessible, aborting."
}

check_for_helm() {
  helm >/dev/null 2>&1
  exit_on_error "'helm' could not be found. Install helm first."

  helm version
  exit_on_error "'helm' doesn't seem to be configured. Run 'helm init'"
}

process_kubeconfig() {
  echo "Processing kubeconfig..."

  os=`uname`
  outfile=./tmp/kubeconfig.yaml

  kubectl config view --raw > ./tmp/kubeconfig
  exit_on_error "Could not process kube config, aborting."

  if [ "$os" == "Darwin" ]; then
    data=`base64 ./tmp/kubeconfig`
  elif [ "$os" == "Linux" ]; then
    data=`base64 -w0 ./tmp/kubeconfig`
  else
    exit_with_error "Could not handle OS type '$os', aborting."
  fi

  echo "Writing kubernetes config to $outfile"

cat > $outfile << EOF
## Encoded kubernetes config file ($1) to $outfile.
##
## Pass with '-f' to helm install command, e.g.
##
##    helm install --namespace $namespace ./gestalt -n gestalt-platform -f kube_provider_config.yaml
##

# data encoded from $1
kubeconfig: $data
EOF
}

create_namespace() {
  echo "Checking for '$namespace' namespace"
  kubectl get namespace $namespace > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo ""
    echo "Namespace '$namespace' does not exist.  Creating..."
    echo ""
    kubectl create namespace $namespace
    if [ $? -ne 0 ]; then
      echo "Error creating namespace, aborting."
      exit 1
    fi
    sleep 5
    echo "Namespace $namespace created."
  fi
}


namespace=gestalt-system
logfile=gestalt-platform-install.log

mkdir -p ./tmp
exit_on_error "Could not create './tmp', aborting. Check filesystem permissions and try again."

check_for_kube

check_for_helm

process_kubeconfig

create_namespace

# read -p "Do you want to install? [y/N[]]" -n 1 -r
# echo    # (optional) move to a new line
# if [[ ! $REPLY =~ ^[Yy]$ ]]; then
echo "Installing using helm..."
cmd="helm install --namespace $namespace ./gestalt -n gestalt-platform -f ./tmp/kubeconfig.yaml"
echo "$cmd"
$cmd
