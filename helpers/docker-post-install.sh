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
kube_port=$(kubectl get svc -n gestalt-system gestalt-ui -ojson | jq '.spec.ports[].nodePort')
exit_on_error "Unable to get Gestalt UI service port"

echo "==================================================="
echo "   Docker for Desktop Post-Install Configuration"
echo "==================================================="
echo
echo "Adding /etc/host entries (requires sudo, you may be asked for your password)..."

sudo ./helpers/add-etc-hosts-entry.sh 127.0.0.1 $GESTALT_UI_INGRESS_HOST
sudo ./helpers/add-etc-hosts-entry.sh 127.0.0.1 $EXTERNAL_GATEWAY_HOST

GESTALT_LOGIN_URL="$GESTALT_UI_INGRESS_PROTOCOL://$GESTALT_UI_INGRESS_HOST:$kube_port"
