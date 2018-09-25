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

# TODO: Make generic function if we use it somewhere else
wait_for_ui_service() {
  secs=5
  for i in `seq 1 10`; do
    echo "Polling for gestalt-ui service (attempt $i)"
    output=$(kubectl get service -n gestalt-system gestalt-ui --no-headers 2>/dev/null | wc -l)
    if [ $output -eq 0 ]; then
      sleep $secs
    else
      echo "gestalt-ui service found"
      return 0
    fi
  done

  exit_with_error "gestalt-ui service not found, aborting".
}

wait_for_ui_service

kube_ip=localhost
kube_port=$(kubectl get svc -n gestalt-system gestalt-ui -ojsonpath='{.spec.ports[].nodePort}')
exit_on_error "Unable to get Gestalt UI service port"

gestalt_ui_ingress_protocol=${gestalt_ui_ingress_protocol-http}

# Form the Gestalt login URL
gestalt_login_url="$gestalt_ui_ingress_protocol://$gestalt_ui_ingress_host:$kube_port"

# Form the Gateway URL
kong_namespace=$(kubectl get svc --all-namespaces -ojsonpath='{.items[?(@.metadata.name=="kng")].metadata.namespace}')
kong_port=$(kubectl get svc -n $kong_namespace kng -ojsonpath='{.spec.ports[?(@.name=="public-url")].nodePort}')
gestalt_api_gateway_url=$external_gateway_protocol://$external_gateway_host:$kong_port
