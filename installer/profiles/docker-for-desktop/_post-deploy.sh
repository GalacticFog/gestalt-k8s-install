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

kube_ip=localhost
kube_port=$(kubectl get svc -n gestalt-system gestalt-ui -ojsonpath='{.spec.ports[].nodePort}')
exit_on_error "Unable to get Gestalt UI service port"


# Form the Gestalt login URL
gestalt_login_url="$gestalt_ui_ingress_protocol://$gestalt_ui_ingress_host:$kube_port"

# Form the Gateway URL
kong_namespace=$(kubectl get svc --all-namespaces -ojsonpath='{.items[?(@.metadata.name=="kng")].metadata.namespace}')
kong_port=$(kubectl get svc -n $kong_namespace kng -ojsonpath='{.spec.ports[?(@.name=="public-url")].nodePort}')
gestalt_api_gateway_url=$external_gateway_protocol://$external_gateway_host:$kong_port
