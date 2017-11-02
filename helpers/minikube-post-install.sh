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

minikube_ip=`minikube ip`
exit_on_error "Unable to get minikube IP address"

echo "==========================================="
echo "   Minikube Post-Install Configuration"
echo "==========================================="
echo
echo "Your minikube cluster IP is $minikube_ip"
echo
echo "Acess to Gestalt on minikube requires use of virtual hosts / ingress."
echo "Please add the following to your /etc/hosts file:"
echo ---
echo "# Gestalt configuration for minikube"
echo "$minikube_ip    $GESTALT_UI_INGRESS_HOST $EXTERNAL_GATEWAY_HOST"
echo ---
echo
echo "Gestalt UI will be available at $GESTALT_UI_INGRESS_PROTOCOL://$GESTALT_UI_INGRESS_HOST"
echo "Gestalt API Gateway will be available at $EXTERNAL_GATEWAY_PROTOCOL://$EXTERNAL_GATEWAY_HOST"
