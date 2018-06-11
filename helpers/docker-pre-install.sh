pull_image() {
  # echo Pulling $1...
  docker pull $1
  echo
}

echo "==========================================="
echo "  Docker Pre-Install Configuration"
echo "==========================================="
echo

## Pull docker images

echo
echo "Pulling Gestalt Platform images to local Docker environment..."

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
