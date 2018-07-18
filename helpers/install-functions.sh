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
  which base64    >/dev/null 2>&1 ; exit_on_error "'base64' command not found, aborting."
  which tr        >/dev/null 2>&1 ; exit_on_error "'tr' command not found, aborting."
  which sed       >/dev/null 2>&1 ; exit_on_error "'sed' command not found, aborting."
  which seq       >/dev/null 2>&1 ; exit_on_error "'seq' command not found, aborting."
  which sudo      >/dev/null 2>&1 ; exit_on_error "'sudo' command not found, aborting."
  which true      >/dev/null 2>&1 ; exit_on_error "'true' command not found, aborting."
  # 'read' may be implemented as a shell function rather than a separate function
  # which read      >/dev/null 2>&1 ; exit_on_error "'read' command not found, aborting."
  which bc        >/dev/null 2>&1 ; exit_on_error "'bc' command not found, aborting."
  # which helm      >/dev/null 2>&1 ; exit_on_error "'helm' not found, aborting."
  which kubectl   >/dev/null 2>&1 ; exit_on_error "'kubectl' command not found, aborting."
  which curl      >/dev/null 2>&1 ; exit_on_error "'curl' command not found, aborting."
  which unzip     >/dev/null 2>&1 ; exit_on_error "'unzip' command not found, aborting."
  which tar       >/dev/null 2>&1 ; exit_on_error "'tar' command not found, aborting."
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
  local kubecontext="`kubectl config current-context`"

  if [ ! -z "$target_kube_context" ]; then
      if [ "$kubecontext" != "$target_kube_context" ]; then
      do_prompt_to_continue \
        "Warning - The current Kubernetes context name '$kubecontext' does not match the expected value, '$target_kube_context'" \
        "Proceed anyway?"
      fi
  fi

  kube_cluster_info=$(kubectl cluster-info)
  exit_on_error "Kubernetes cluster not accessible, aborting."

  echo "OK - Kubernetes cluster '$kubecontext' is accessible."
}

check_cluster_capacity() {
  echo "Checking cluster capacity..."
  ./helpers/check-cluster-capacity
  local check=$?
  if [ $check -eq 10 ]; then
    # Meets minimum capacity requirements, but not recommended.  Prompt to continue
      do_prompt_to_continue \
        "" \
        "Proceed anyway?"
  elif [ $check -ne 0 ]; then
    # Doesn't meet minimum capacity requirements
    exit_with_error "Cannot proceed with installation, not enough cluster resources."
  fi
}

check_for_helm() {
  helm=helm
  echo "Checking for Helm..."
  helm >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    download_helm
  else
    echo "OK - helm client present"
    helm=helm
  fi

  echo "Checking helm installation status..."
  $helm version --tiller-connection-timeout 10 > /dev/null
  if [ $? -ne 0 ]; then
    echo "Helm/Tiller not yet initialized in Kubernetes cluster. Running 'helm init --upgrade'..."
    $helm init --upgrade
    do_wait_for_helm
  fi

  echo "OK - Helm is ready."
}

check_for_helm_no_download() {
  echo "Checking for Helm..."
  helm >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    helm=helm
  elif [ -f ./helm ]; then
      helm=./helm
  fi

  [ -z $helm ] && exit_with_error "Helm not found."

  echo "OK - '$helm' found."
}

do_wait_for_helm() {
  echo -n "Waiting for Helm/Tiller to be ready "
  for i in `seq 1 10`; do
    sleep 10
    echo -n "."

    local status=$($helm version --tiller-connection-timeout 10 2>&1)
    if [ $? -eq 0 ]; then
      echo
      echo "$status"
      return 0
    fi
  done
  echo
  exit_with_error "Helm did not initialize within expected timeframe."
}


create_or_check_for_required_namespace() {
  # echo "Checking for existing Kubernetes namespace '$install_namespace'..."
  kubectl get namespace $install_namespace > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo ""
    echo "Kubernetes namespace '$install_namespace' doesn't exist, creating..."
    kubectl create namespace $install_namespace
    exit_on_error "Failed to create namespace '$install_namespace', aborting."
  fi
  echo "OK - Kubernetes namespace '$install_namespace' is present."
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

check_for_required_namespace() {
  # echo "Checking for existing Kubernetes namespace '$install_namespace'..."
  kubectl get namespace $install_namespace > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo ""
    echo "Kubernetes namespace '$install_namespace' doesn't exist, aborting.  To create the namespace, run the following command:"
    echo ""
    echo "  kubectl create namespace $install_namespace"
    echo ""
    echo "Then ensure that 'Full Control' grants are provided for the '$install_namespace/default' service account."
    echo ""
    exit_with_error "Kubernetes namespace '$install_namespace' doesn't exist, aborting."
  fi
  echo "OK - Kubernetes namespace '$install_namespace' is present."
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

  $helm status gestalt >/dev/null 2>&1
  if [ $? -eq 0 ]; then
      exit_with_error "Gestalt helm deployment found, aborting."
  fi

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
    echo "OK - No prior Gestalt installation found."
  fi
}

prompt_to_continue() {
  do_prompt_to_continue \
    "Gestalt Platform is ready to be installed to Kubernetes context '`kubectl config current-context`'.\n\nYou must accept the Gestalt Enterprise End User License Agreement (http://www.galacticfog.com/gestalt-eula.html) to continue." \
    "Accept EULA and proceed with Gestalt Platform installation?"
  if [ ! -f __skip_eula ]; then
      accept_eula
  fi
}

do_prompt_to_continue() {
  if [ ! -z "$1" ]; then
    echo ""
    echo -e $1
    echo ""
  fi 
  while true; do
      read -p "$2 [y/n]: " yn
      case $yn in
          [Yy]*) echo ; return 0  ;;
          [Nn]*) echo "Aborted" ; exit  1 ;;
      esac
  done
}

accept_eula() {

  while true; do

    local company
    local name
    local email
    local yn

    echo "Please provide the following to accept the EULA (press Ctrl-C to abort)"

    while [ -z "$name" ];    do read -p "  Your Name: " name ; done
    while [ -z "$company" ]; do read -p "  Your Company name: " company ; done
    while [ -z "$email" ];   do read -p "  Your Email: " email ; done

    echo
    echo "Please verify your information:"
    echo "  Name:    $name"
    echo "  Company: $company"
    echo "  Email:   $email"
    echo
    read -p "Is your information correct? [y/n] " yn

    case $yn in
        [Yy]*)

        local payload="{\
                \"eventName\": \"gestalt-k8s-installer-eula-accepted\",\
                \"payload\": {\
                    \"name\": \"$name\",\
                    \"company\": \"$company\",\
                    \"email\": \"$email\",\
                    \"message\": \"Gestalt Kubernetes Installer: EULA Accepted\",\
                    \"slackMessage\": \"\
                        \n        EULA Accepted during Gestalt Platform install on Kubernetes. \
                        \n\n          version: release-2.1.0 ($(uname))\
                        \n\n          name: $name\
                        \n\n          company: $company\
                        \n\n          email: $email\"\
                }\
            }"

            curl -H "Content-Type: application/json" -X POST -d "$payload" https://gtw1.demo.galacticfog.com/gfsales/message > /dev/null 2>&1

            echo "EULA Accepted, proceeding with Gestalt Platform installation." ;
            return 0
            ;;
        [Nn]*)
            unset name
            unset email
            unset company
            echo
            ;;
    esac

  done
}

prompt_for_executor_config() {

    echo
    echo "Gestalt Platform's FaaS engine (Gestalt Laser) provides a number of out-of-box language runtimes for executing lambda functions.  The 'js' runtime is enabled by default."
    echo

    if do_prompt_to_enable_all_executors; then
        echo
    else
        do_prompt_for_executor_config 'nodejs'
        do_prompt_for_executor_config 'dotnet'
        do_prompt_for_executor_config 'golang'
        do_prompt_for_executor_config 'jvm'
        do_prompt_for_executor_config 'python'
        do_prompt_for_executor_config 'ruby'
    fi

    echo
}

do_prompt_to_enable_all_executors() {
    while true; do
        read -p "  Do you want to enable all lambda runtimes (nodejs, dotnet, golang, jvm, python, ruby)? [y/n]: " yn
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
        esac
    done
}

do_prompt_for_executor_config() {

  # If executor image variable is already unset, don't prompt for additional variables
  local ee="gestalt_laser_executor_${1}_image"
  if [ -z "${!ee}" ]; then
      return 0
  fi

  while true; do
      read -p "  Enable the '$1' runtime? [y/n]: " yn
      case $yn in
          [Yy]*) return 0 ;;
          [Nn]*) unset gestalt_laser_executor_${1}_image ; return 0 ;;
      esac
  done
}

summarize_config() {

  # Set defalt URLs.  Post-install scripts can override these
  gestalt_login_url=$gestalt_ui_ingress_protocol://$gestalt_ui_ingress_host:$gestalt_ui_service_nodeport
  gestalt_api_gateway_url=$external_gateway_protocol://$external_gateway_host:$gestalt_kong_service_nodeport

  echo
  echo "=============================================="
  echo "  Configuration Summary"
  echo "=============================================="
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

  # Summarize executors
  echo
  echo "Enabled executor runtimes:"
  for e in 'js' 'nodejs' 'dotnet' 'golang' 'jvm' 'python' 'ruby'; do
      local ee="gestalt_laser_executor_${e}_image"
      if [ ! -z "${!ee}" ]; then
        echo " - $e"
      # else
      #   echo " - $e (not enabled)"
      fi
  done
  echo ""
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

  cmd="$helm install --namespace $install_namespace ./gestalt -n $install_prefix -f $1"
  echo "Installing Gestalt Platform to Kubernetes using Helm..."
  echo "Command: $cmd"
  # $cmd > /dev/null 2>&1
  local status=$( $cmd 2>&1)
  if [ $? -ne 0 ]; then
      echo "$status"
      exit_with_error "Error running helm (error code returned), installation failed."
  fi

  # Check for error in case helm error'd but didn't return an error code
  if echo $status | grep -i error; then
      echo "$status"
      exit_with_error "Error running helm (error detected), installation failed."
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
  for i in `seq 1 100`; do
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
  echo
  echo "Gestalt Platform installation complete!  Next Steps:"
  echo ""
  echo "  1) Login to Gestalt:"
  echo ""
  echo "         URL:       $gestalt_login_url"
  echo "         User:      $gestalt_admin_username"
  echo "         Password:  $gestalt_admin_password"
  # echo ""
  # echo "         API Gateway:  $gestalt_api_gateway_url"
  echo ""
  echo "  2) Next, navigate to the developer sandbox at:"
  echo ""
  echo "         $gestalt_login_url -> Sandboxes -> Developer Sandbox -> Development"
  echo ""
  echo "     Or via URL:"
  echo ""
  echo "         `./fog context get-browser-url`"
  echo ""
  echo "  3) You may access the Gestalt platform documentation at"
  echo ""
  echo "         http://docs.galacticfog.com/"
  echo ""
  echo "Done."
}

download_helm() {
    echo "Checking for 'helm'"

    if [ ! -f ./helm ]; then
        local os=`uname`

        if [ "$os" == "Darwin" ]; then
            local helm_os="darwin"
        elif [ "$os" == "Linux" ]; then
            local helm_os="linux"
        else
            echo
            echo "Warning: unknown OS type '$os', treating as Linux"
            local helm_os="linux"
        fi

        local helm_version="2.9.1"

        local url="https://storage.googleapis.com/kubernetes-helm/helm-v$helm_version-$helm_os-amd64.tar.gz"

        if [ ! -z "$url" ]; then
            echo
            echo "Downloading helm version $helm_version..."

            curl -L $url -o helm.tar.gz
            exit_on_error "Failed to download helm, aborting."

            echo
            echo "Extracting..."

            tar xfzv helm.tar.gz
            exit_on_error "Failed to unzip helm package, aborting."

            if [ "$os" == "Darwin" ]; then
                cp darwin-amd64/helm .
                rm -r darwin-amd64
            elif [ "$os" == "Linux" ]; then
                cp linux-amd64/helm .
                rm -r linux-amd64
            else
                echo
                echo "Warning: unknown OS type '$os', treating as Linux"
                cp linux-amd64/helm .
            fi
            chmod +x ./helm
            helm="./helm"

            rm helm.tar.gz
        fi
    else
      helm=./helm
    fi

    echo "OK - $helm present."
}

download_fog_cli() {
    echo "Checking for 'fog' CLI..."

    if [ -f './fog' ]; then
        local version=$(./fog --version)
        if [ "$gestalt_cli_version" == "$version" ]; then
            echo "OK - fog version $version found."
        else
            echo "fog version $version does not match required version $gestalt_cli_version, removing."
            rm ./fog
        fi
    else 
        echo "'fog' CLI not present."
    fi

    if [ ! -f './fog' ]; then
        local os=`uname`

        if [ "$os" == "Darwin" ]; then
            local url="https://github.com/GalacticFog/gestalt-fog-cli/releases/download/${gestalt_cli_version}/gestalt-fog-cli-macos-${gestalt_cli_version}.zip"
        elif [ "$os" == "Linux" ]; then
            local url="https://github.com/GalacticFog/gestalt-fog-cli/releases/download/${gestalt_cli_version}/gestalt-fog-cli-linux-${gestalt_cli_version}.zip"
        else
            echo
            echo "Warning: unknown OS type '$os', treating as Linux"
        fi

        if [ ! -z "$url" ]; then
            echo
            echo "Downloading Gestalt fog CLI $gestalt_cli_version..."

            curl -L $url -o fog.zip
            exit_on_error "Failed to download 'fog' CLI, aborting."

            echo
            echo "Unzipping..."

            unzip -o fog.zip
            exit_on_error "Failed to unzip 'fog' CLI package, aborting."

            rm fog.zip
        fi
    fi

    local version=$(./fog --version)
    exit_on_error "Error running 'fog' CLI, aborting."

    echo "OK - fog CLI $version present."
}

cleanup() {
    local file=./logs/gestalt-installer.log

    echo "Capturing installer logs to '$file'"
    date > $file
    kubectl logs -n gestalt-system gestalt-installer >> $file

    echo "Deleting 'gestalt-installer' pod..."
    kubectl delete pod -n gestalt-system gestalt-installer
}
