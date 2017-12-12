# This file is sourced into the installer

exit_with_error() {
  echo "[Error] $@"
  exit 1
}

exit_on_error() {
  if [ $? -ne 0 ]; then
    exit_with_error $1
  fi
}

check_for_required_environment_variables() {
  retval=0

  for e in $@; do
    if [ -z "${!e}" ]; then
      echo "Required environment variable \"$e\" not defined."
      retval=1
    fi
  done

  if [ $retval -ne 0 ]; then
    echo "One or more required environment variables not defined, aborting."
    exit 1
  else
    echo "All required environment variables found."
  fi
}


check_for_required_tools() {
  # echo "Checking for required tools..."
  which base64    >/dev/null 2>&1 ; exit_on_error "'base64' not found, aborting."
  which tr        >/dev/null 2>&1 ; exit_on_error "'tr' not found, aborting."
  which helm      >/dev/null 2>&1 ; exit_on_error "'helm' not found, aborting."
  which kubectl   >/dev/null 2>&1 ; exit_on_error "'kubectl' not found, aborting."
  echo "OK - Required tools found."
}

check_kubeconfig() {
  # echo "Checking Kubernetes config..."

  kubectl config view --raw --flatten=true --minify=true > /dev/null
  exit_on_error "'kubectl config view' command didn't succeed, aborting."
  echo "OK - kubeconfig appears to be valid."
}

check_for_kube() {
  # echo "Checking for Kubernetes..."

  kube_cluster_info=$(kubectl cluster-info)
  exit_on_error "Kubernetes cluster not accessible, aborting."

  echo "OK - Kubernetes cluster '`kubectl config current-context`' is accessible."
}

check_for_helm() {
  # echo "Checking for Helm..."
  helm >/dev/null 2>&1
  exit_on_error "'helm' could not be found. Install helm first."

  helm version > /dev/null
  exit_on_error "'helm' doesn't seem to be configured. Try running 'helm version' or 'helm init'"

  echo "OK - Helm is installed."
}

check_for_existing_namespace() {
  # echo "Checking for existing Kubernetes namespace '$INSTALL_NAMESPACE'..."
  kubectl get namespace $INSTALL_NAMESPACE > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo ""
    echo "Kubernetes namespace '$INSTALL_NAMESPACE' already exists, aborting.  To delete the namespace, run the following command:"
    echo ""
    echo "  kubectl delete namespace $INSTALL_NAMESPACE"
    echo ""
    exit_with_error "Kubernetes namespace '$INSTALL_NAMESPACE' already exists, aborting."
  fi
  echo "OK - Kubernetes namespace '$INSTALL_NAMESPACE' does not exist."
}

# check_for_existing_namespace_ask() {
#   echo "Checking for existing Kubernetes namespace '$INSTALL_NAMESPACE'..."
#   kubectl get namespace $INSTALL_NAMESPACE > /dev/null 2>&1
#   if [ $? -eq 0 ]; then
#     while true; do
#         read -p " Kubernetes namespace '$INSTALL_NAMESPACE' already exists, proceed? [y/n]: " yn
#         case $yn in
#             [Yy]*) return 0  ;;
#             [Nn]*) echo "Aborted" ; exit  1 ;;
#         esac
#     done
#   fi
#   echo "OK - Kubernetes namespace '$INSTALL_NAMESPACE' does not exist."
# }

check_for_prior_install() {
  # echo "Checking for prior installation..."

  kubectl get services --all-namespaces | grep default-kong > /dev/null
  if [ $? -eq 0 ]; then
    exit_with_error "'default-kong' service already present, aborting."
  fi

  # Note: using the local keyword in 'local existing_namespaces=$( ... ) returns zero, unexpectedly.. so not using it.
  existing_namespaces=$( kubectl get namespaces | grep -E '[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}' )
  if [ $? -eq 0 ]; then
    echo ""
    echo "Warning: There are existing namespaces that appear to be from a prior install:"
    echo "$existing_namespaces"
    echo ""

    if [ -z "$GESTALT_AUTOMATED_INSTALL" ]; then
      do_prompt_to_continue \
        "There appear to be existing namespaces. Recommand inspecting and deleting these namespaces before continuing." \
        "Proceed anyway?"
    else
      echo "Continuing anyway since this is an automated install, press Ctrl-C to cancel..."
      sleep 5
    fi
  else
    echo "OK - No prior installation found."
  fi
}

prompt_to_continue() {
  do_prompt_to_continue \
    "Gestalt Platform is ready to be installed to Kubernetes cluster '`kubectl config current-context`'." \
    "Proceed with Gestalt Platform installation?"
}

do_prompt_to_continue() {
  echo ""
  echo $1
  echo ""

  while true; do
      read -p "$2 [y/n]: " yn
      case $yn in
          [Yy]*) return 0  ;;
          [Nn]*) echo "Aborted" ; exit  1 ;;
      esac
  done
}

summarize_config() {
  echo
  echo "Configuration Summary:"
  echo " - Kubernetes cluster: `kubectl config current-context`"
  echo " - Kubernetes namespace: $INSTALL_NAMESPACE"
  echo " - Gestalt Admin: $GESTALT_ADMIN_USERNAME"
  # TODO: Only output if not using dynamic LBs.
  echo " - Gestalt User Interface: $GESTALT_UI_INGRESS_PROTOCOL://$GESTALT_UI_INGRESS_HOST"
  echo " - Gestalt API Gateway: $EXTERNAL_GATEWAY_PROTOCOL://$EXTERNAL_GATEWAY_HOST"
  case $PROVISION_INTERNAL_DATABASE in
    [YyTt1]*)
      echo " - Database: Provisioning an internal database"
      ;;
    *)
      echo " - Database:"
      echo "    Host: $DATABASE_HOSTNAME"
      echo "    Port: $DATABASE_PORT"
      echo "    Name: $DATABASE_NAME"
      echo "    User: $DATABASE_USER"
      ;;
  esac
}

create_namespace() {
  # echo "Checking for existing Kubernetes namespace '$INSTALL_NAMESPACE'..."
  kubectl get namespace $INSTALL_NAMESPACE > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo "Creating namespace '$INSTALL_NAMESPACE'..."
    kubectl create namespace $INSTALL_NAMESPACE
    exit_on_error "Error creating namespace '$INSTALL_NAMESPACE', aborting."

    # Wait for namespace to be created
    sleep 5
    echo "Namespace $INSTALL_NAMESPACE created."
  fi
}

run_helm_install() {

  [ -z "$INSTALL_NAMESPACE" ] && exit_with_error "INSTALL_NAMESPACE not defined"
  [ -z "$INSTALL_PREFIX" ]    && exit_with_error "INSTALL_PREFIX  not defined"

  cmd="helm install --namespace $INSTALL_NAMESPACE ./gestalt -n $INSTALL_PREFIX -f $1"
  echo "Installing Gestalt Platform to Kubernetes using Helm..."
  echo "Command: $cmd"
  $cmd

  exit_on_error "Installation failed!"
}

run_pre_install() {
  if [ ! -z "$PRE_INSTALL_SCRIPT" ]; then
    echo ""
    echo "Running pre-install: $PRE_INSTALL_SCRIPT ..."
    . ./helpers/$PRE_INSTALL_SCRIPT
    exit_on_error "Pre-install script failed, aborting."
  fi
  echo
}

run_post_install() {
  if [ ! -z "$POST_INSTALL_SCRIPT" ]; then
    echo ""
    echo "Running post-install: $POST_INSTALL_SCRIPT ..."
    . ./helpers/$POST_INSTALL_SCRIPT
  fi
  echo
}

prompt_or_wait_to_continue() {
  if [ -z "$GESTALT_AUTOMATED_INSTALL" ]; then
      prompt_to_continue
  else
    echo "About to proceed with installation, press Ctrl-C to cancel..."
    sleep 5
  fi
}
