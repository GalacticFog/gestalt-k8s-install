pull_image() {
  echo Pulling $1...
  docker pull $1
  echo
}

echo "==========================================="
echo "  Docker Pre-Install Configuration"
echo "==========================================="
echo
echo "Adding /etc/host entries for Gestalt (requires sudo, you may be asked for your password)..."
sudo true
if [ $? -eq 0 ]; then
  sudo ./helpers/remove-etc-hosts-entry.sh $gestalt_ui_ingress_host >/dev/null
  sudo ./helpers/remove-etc-hosts-entry.sh $external_gateway_host >/dev/null
  sudo ./helpers/add-etc-hosts-entry.sh 127.0.0.1 $gestalt_ui_ingress_host >/dev/null
  sudo ./helpers/add-etc-hosts-entry.sh 127.0.0.1 $external_gateway_host >/dev/null
  echo "Added Gestalt entries to /etc/hosts."
else
  echo "Warning: failed to add entries to /etc/hosts.  These should be added manually:"
  echo "  127.0.0.1 $gestalt_ui_ingress_host"
  echo "  127.0.0.1 $external_gateway_host"
fi

## Pull docker images

echo
echo "Pulling Gestalt Platform images to Docker environment"

pull_image $gestalt_installer_image

pull_image $gestalt_rabbit_image
pull_image $gestalt_kong_image
pull_image $gestalt_gateway_manager_image
pull_image $gestalt_policy_image
pull_image $gestalt_meta_image

pull_image $gestalt_security_image
pull_image $gestalt_ui_image
pull_image $gestalt_laser_image

pull_image $gestalt_laser_executor_js_image
[ ! -z "$gestalt_laser_executor_nodejs_image" ] && pull_image $gestalt_laser_executor_nodejs_image
[ ! -z "$gestalt_laser_executor_dotnet_image" ] && pull_image $gestalt_laser_executor_dotnet_image
[ ! -z "$gestalt_laser_executor_golang_image" ] && pull_image $gestalt_laser_executor_golang_image
[ ! -z "$gestalt_laser_executor_jvm_image" ] && pull_image $gestalt_laser_executor_jvm_image
[ ! -z "$gestalt_laser_executor_python_image" ] && pull_image $gestalt_laser_executor_python_image
[ ! -z "$gestalt_laser_executor_ruby_image" ] && pull_image $gestalt_laser_executor_ruby_image
