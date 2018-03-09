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
  which sed       >/dev/null 2>&1 ; exit_on_error "'sed' not found, aborting."
  which seq       >/dev/null 2>&1 ; exit_on_error "'seq' not found, aborting."
  which sudo      >/dev/null 2>&1 ; exit_on_error "'sudo' not found, aborting."
  which true      >/dev/null 2>&1 ; exit_on_error "'true' not found, aborting."
  which read      >/dev/null 2>&1 ; exit_on_error "'read' not found, aborting."
  which helm      >/dev/null 2>&1 ; exit_on_error "'helm' not found, aborting."
  which kubectl   >/dev/null 2>&1 ; exit_on_error "'kubectl' not found, aborting."
  echo "OK - Required tools found."
}

check_kubeconfig() {
  # echo "Checking Kubernetes config..."

  kubectl config view --raw --flatten --minify > /dev/null
  exit_on_error "'kubectl config view' command didn't succeed, aborting."
  echo "OK - kubeconfig appears to be valid."
}

check_for_kube() {
  echo "Checking for Kubernetes..."

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
  # echo "Checking for existing Kubernetes namespace '$install_namespace'..."
  kubectl get namespace $install_namespace > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo ""
    echo "Kubernetes namespace '$install_namespace' already exists, aborting.  To delete the namespace, run the following command:"
    echo ""
    echo "  kubectl delete namespace $install_namespace"
    echo ""
    exit_with_error "Kubernetes namespace '$install_namespace' already exists, aborting."
  fi
  echo "OK - Kubernetes namespace '$install_namespace' does not exist."
}

# check_for_existing_namespace_ask() {
#   echo "Checking for existing Kubernetes namespace '$install_namespace'..."
#   kubectl get namespace $install_namespace > /dev/null 2>&1
#   if [ $? -eq 0 ]; then
#     while true; do
#         read -p " Kubernetes namespace '$install_namespace' already exists, proceed? [y/n]: " yn
#         case $yn in
#             [Yy]*) return 0  ;;
#             [Nn]*) echo "Aborted" ; exit  1 ;;
#         esac
#     done
#   fi
#   echo "OK - Kubernetes namespace '$install_namespace' does not exist."
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
    "Gestalt Platform is ready to be installed to Kubernetes context '`kubectl config current-context`'." \
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

  # Set defalt URLs.  Post-install scripts can override these
  gestalt_login_url=$gestalt_ui_ingress_protocol://$gestalt_ui_ingress_host:$gestalt_ui_service_nodeport
  gestalt_api_gateway_url=$external_gateway_protocol://$external_gateway_host:$gestalt_kong_service_nodeport

  echo
  echo "Configuration Summary:"
  echo " - Kubernetes cluster: `kubectl config current-context`"
  echo " - Kubernetes namespace: $install_namespace"
  echo " - Gestalt Admin: $gestalt_admin_username"
  # TODO: Only output if not using dynamic LBs.
  echo " - Gestalt User Interface: $gestalt_login_url"
  echo " - Gestalt API Gateway: $gestalt_api_gateway_url"
  case $provision_internal_database in
    [YyTt1]*)
      echo " - Database: Provisioning an internal database"
      ;;
    *)
      echo " - Database:"
      echo "    Host: $database_hostname"
      echo "    Port: $database_port"
      echo "    Name: $database_name"
      echo "    User: $database_user"
      ;;
  esac
}

create_namespace() {
  # echo "Checking for existing Kubernetes namespace '$install_namespace'..."
  kubectl get namespace $install_namespace > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo "Creating namespace '$install_namespace'..."
    kubectl create namespace $install_namespace
    exit_on_error "Error creating namespace '$install_namespace', aborting."

    # Wait for namespace to be created
    sleep 5
    echo "Namespace $install_namespace created."
  fi
}

run_helm_install() {

  [ -z "$install_namespace" ] && exit_with_error "install_namespace not defined"
  [ -z "$install_prefix" ]    && exit_with_error "install_prefix  not defined"

  cmd="helm install --namespace $install_namespace ./gestalt -n $install_prefix -f $1"
  echo "Installing Gestalt Platform to Kubernetes using Helm..."
  echo "Command: $cmd"
  # $cmd > /dev/null 2>&1
  local status=$( $cmd )
  if [ $? -ne 0 ]; then
      echo "$status"
      exit_with_error "Installation failed!"
  fi

  # exit_on_error "Installation failed!"
}

run_pre_install() {
  if [ ! -z "$pre_install_script" ]; then
    echo ""
    echo "Running pre-install: $pre_install_script ..."
    . ./helpers/$pre_install_script
    exit_on_error "Pre-install script failed, aborting."
  fi
  echo
}

run_post_deploy() {
  if [ ! -z "$post_deploy_script" ]; then
    echo ""
    echo "Running post-install: $post_deploy_script ..."
    . ./helpers/$post_deploy_script
  fi
  echo
}

run_post_install() {
  if [ ! -z "$post_install_script" ]; then
    echo ""
    echo "Running post-install: $post_install_script ..."
    . ./helpers/$post_install_script
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

wait_for_install_completion() {
  echo "Waiting for Gestalt Platform installation to complete"
  for i in `seq 1 50`; do
    echo -n "."

    line=$(kubectl logs -n gestalt-system gestalt-installer --tail 10 2> /dev/null)

    echo "$line" | grep "^\[Success\] Gestalt platform installation completed." > /dev/null
    if [ $? -eq 0 ]; then
      echo
      echo "Installation complete."
      return
    fi
    # Check for failure - no success message, but end of file found
    echo "$line" | grep "^Sleeping forever so container stays running..." > /dev/null
    if [ $? -eq 0 ]; then
      echo
      exit_with_error "Installation failed."
    fi

    sleep 5
    # Show progress more frequently than actual check
    echo -n "."
    sleep 5
  done
  echo
  exit_with_error "Installation did not complete within expected timeframe."
}

display_summary() {
  echo ""
  echo "  - Login credentials:"
  echo ""
  echo "         URL:       $gestalt_login_url"
  echo "         User:      $gestalt_admin_username"
  echo "         Password:  $gestalt_admin_password"
  echo ""
  echo "         API Gateway:  $gestalt_api_gateway_url"
  echo ""
  echo "  - You may access the Gestalt platform documentation at"
  echo ""
  echo "         http://docs.galacticfog.com/"
  echo ""
  echo "  - You may view a log of the installation with the following:"
  echo ""
  echo "     ./view-installer-logs"
  echo ""
  echo "Done."
}
