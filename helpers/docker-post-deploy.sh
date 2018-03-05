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

echo "==================================================="
echo "   Docker for Desktop Post-Install Configuration"
echo "==================================================="
echo
echo "Adding /etc/host entries for Gestalt (requires sudo, you may be asked for your password)..."
sudo true
if [ $? -eq 0 ]; then
  sudo ./helpers/remove-etc-hosts-entry.sh $gestalt_ui_ingress_host >/dev/null
  sudo ./helpers/remove-etc-hosts-entry.sh $external_gateway_host >/dev/null
  sudo ./helpers/add-etc-hosts-entry.sh 127.0.0.1 $gestalt_ui_ingress_host >/dev/null
  sudo ./helpers/add-etc-hosts-entry.sh 127.0.0.1 $external_gateway_host >/dev/null
  echo "Added Gestalt entries to /etc/hosts."
  gestalt_login_url="$gestalt_ui_ingress_protocol://$gestalt_ui_ingress_host:$kube_port"
else
  echo "Warning: failed to add entries to /etc/hosts.  These should be added manually:"
  echo "  127.0.0.1 $gestalt_ui_ingress_host"
  echo "  127.0.0.1 $external_gateway_host"
  gestalt_login_url="$gestalt_ui_ingress_protocol://localhost:$kube_port"
fi

# Form the Gateway URL
kong_namespace=$(kubectl get svc --all-namespaces -ojsonpath='{.items[?(@.metadata.name=="default-kong")].metadata.namespace}')
kong_port=$(kubectl get svc -n $kong_namespace default-kong -ojsonpath='{.spec.ports[?(@.name=="public-url")].nodePort}')
gestalt_api_gateway_url=$external_gateway_protocol://$external_gateway_host:$kong_port
